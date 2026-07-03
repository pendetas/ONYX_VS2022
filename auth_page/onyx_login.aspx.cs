using System;
using System.Web.UI;
using ONYX_DDAC.Helpers;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.auth_page
{
    public partial class onyx_login : Page
    {
        private readonly AuthService authService = new AuthService();
        private readonly OAuthService oauthService = new OAuthService();
        private readonly CaptchaService captchaService = new CaptchaService();

        protected string TurnstileSiteKey { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            TurnstileSiteKey = CaptchaService.GetSiteKey();

            if (Session["UserId"] != null)
            {
                Response.Redirect("~/customer_page/onyx_home.aspx");
                return;
            }

            if (Request.QueryString["registered"] == "true")
            {
                ShowMessage("Registration successful. You can now sign in.", true);
            }

            ShowOAuthMessage();
        }

        protected async void LoginButton_Click(object sender, EventArgs e)
        {
            string emailOrUser = EmailTextBox.Text.Trim();
            string password = PasswordTextBox.Text;

            if (string.IsNullOrEmpty(emailOrUser) || string.IsNullOrEmpty(password))
            {
                ShowMessage("Please enter both email and password.", false);
                return;
            }

            string captchaToken = Request.Form["cf-turnstile-response"];
            bool captchaValid = await captchaService.VerifyCaptchaAsync(
                captchaToken,
                Request.UserHostAddress);

            if (!captchaValid)
            {
                ShowMessage("Please complete the Cloudflare verification before signing in.", false);
                return;
            }

            try
            {
                // Normal Database Authentication Flow
                User user = authService.Login(emailOrUser, password);

                if (user == null)
                {
                    ShowMessage("Invalid credentials. Access denied.", false);
                    return;
                }

                AuthHelper.EstablishAuthenticatedSession(this, user);

                // Auto-detect role and route
                if (string.Equals(user.Role, "admin", StringComparison.OrdinalIgnoreCase))
                {
                    RedirectAfterLogin("~/admin_page/onyx_admin_dashboard.aspx");
                    return;
                }
                else
                {
                    string destination = Request.QueryString["profile"] == "true"
                        ? "~/customer_page/onyx_profile.aspx"
                        : "~/customer_page/onyx_home.aspx";

                    RedirectAfterLogin(destination);
                    return;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Login Error: " + ex);
                ShowMessage("Login is temporarily unavailable. Please check your database connection and try again.", false);
            }
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            MessagePanel.Visible = true;
            MessageLiteral.Text = $"<span class=\"auth-alert\" style=\"color: {(isSuccess ? "#c0c0c0" : "#ff4444")};\">{Server.HtmlEncode(message)}</span>";
        }

        protected void GoogleLoginButton_Click(object sender, EventArgs e)
        {
            StartOAuth("google");
        }

        protected void DiscordLoginButton_Click(object sender, EventArgs e)
        {
            StartOAuth("discord");
        }

        protected void FacebookLoginButton_Click(object sender, EventArgs e)
        {
            StartOAuth("facebook");
        }

        private void StartOAuth(string provider)
        {
            try
            {
                provider = OAuthProviderRegistry.NormalizeProvider(provider);
                OAuthProviderOptions options = OAuthProviderRegistry.GetRequired(provider);
                string state = OAuthService.CreateStateToken();
                string codeChallenge = null;

                Session[OAuthProviderRegistry.GetStateSessionKey(provider)] = state;
                Session[OAuthProviderRegistry.GetStateProviderSessionKey(state)] = provider;
                Session[OAuthProviderRegistry.GetStateModeSessionKey(state)] = "login";
                if (provider == "google")
                    Session["GoogleOAuthState"] = state;

                if (options.RequiresPkce)
                {
                    string codeVerifier = OAuthPkceHelper.CreateVerifier();
                    Session[OAuthProviderRegistry.GetCodeVerifierSessionKey(provider, state)] = codeVerifier;
                    codeChallenge = OAuthPkceHelper.CreateChallenge(codeVerifier);
                }

                string url = oauthService.BuildAuthorizationUrl(
                    provider,
                    BuildOAuthRedirectUri(provider),
                    state,
                    codeChallenge);

                Response.Redirect(url, false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("OAuth start failed: " + ex);
                ShowMessage("This sign-in provider is not configured yet.", false);
            }
        }

        private string BuildOAuthRedirectUri(string provider)
        {
            string callbackPath = provider == "google"
                ? "~/auth_page/google_callback.aspx"
                : "~/auth_page/oauth_callback.aspx";

            return Request.Url.GetLeftPart(UriPartial.Authority) +
                   ResolveUrl(callbackPath);
        }

        private void ShowOAuthMessage()
        {
            string reason = Request.QueryString["oauth"];
            if (string.IsNullOrWhiteSpace(reason))
                return;

            if (reason.EndsWith("_database", StringComparison.OrdinalIgnoreCase))
            {
                ShowMessage("OAuth reached ONYX, but the database could not create or link the account.", false);
                return;
            }

            if (reason.EndsWith("_not_registered", StringComparison.OrdinalIgnoreCase))
            {
                ShowMessage("No account uses this email yet. Please register first, then sign in.", false);
                return;
            }

            if (reason.EndsWith("_config", StringComparison.OrdinalIgnoreCase))
            {
                ShowMessage("This OAuth provider is not configured yet.", false);
                return;
            }

            if (reason.EndsWith("_state", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(reason, "oauth_state", StringComparison.OrdinalIgnoreCase))
            {
                ShowMessage("OAuth session expired. Please try again.", false);
                return;
            }

            ShowMessage("OAuth sign-in could not be completed. Please try again.", false);
        }

        private void RedirectAfterLogin(string url)
        {
            Response.Redirect(url, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
