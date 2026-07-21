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

        protected void Page_Load(object sender, EventArgs e)
        {
            if (TryGetAuthenticatedUser(out User currentUser))
            {
                string requestedTarget = Request.QueryString["profile"] == "true"
                    ? "~/customer_page/onyx_profile.aspx"
                    : null;
                string target = PostAuthRedirectHelper.GetTarget(this, currentUser, requestedTarget);
                Response.Redirect(target, false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (Request.QueryString["registered"] == "true")
            {
                ShowMessage("Registration successful. You can now sign in.", true);
            }

            ShowOAuthMessage();
        }

        protected void LoginButton_Click(object sender, EventArgs e)
        {
            string emailOrUser = EmailTextBox.Text.Trim();
            string password = PasswordTextBox.Text;

            if (string.IsNullOrEmpty(emailOrUser) || string.IsNullOrEmpty(password))
            {
                ShowMessage("Please enter both email and password.", false);
                return;
            }

            if (!authService.IsAuthRequestAllowed(
                "login",
                AuthService.BuildRateLimitKey(emailOrUser, Request.UserHostAddress),
                5,
                TimeSpan.FromMinutes(15),
                TimeSpan.FromMinutes(15)))
            {
                ShowMessage("Too many login attempts. Please wait 15 minutes and try again.", false);
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
                authService.QueueLoginDetectedNotice(user, Request.UserHostAddress, BuildForgotPasswordUrl());
                string destination = Request.QueryString["profile"] == "true"
                    ? "~/customer_page/onyx_profile.aspx"
                    : null;

                PostAuthRedirectHelper.Redirect(this, user, destination);
                return;
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

            return AppUrlHelper.BuildAbsoluteUrl(this, callbackPath);
        }

        private string BuildForgotPasswordUrl()
        {
            return AppUrlHelper.BuildAbsoluteUrl(this, "~/auth_page/onyx_forgotpassword.aspx");
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

        private bool TryGetAuthenticatedUser(out User user)
        {
            user = null;

            object sessionUserId = Session["UserId"];
            if (sessionUserId == null)
            {
                return false;
            }

            long userId;
            if (sessionUserId is long longValue)
            {
                userId = longValue;
            }
            else if (!long.TryParse(sessionUserId.ToString(), out userId))
            {
                return false;
            }

            user = new User
            {
                Id = userId,
                Role = Convert.ToString(Session["Role"])
            };

            return true;
        }

    }
}
