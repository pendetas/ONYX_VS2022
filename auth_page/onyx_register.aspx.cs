using System;
using System.Web.UI;
using ONYX_DDAC.Helpers;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.auth_page
{
    public partial class onyx_register : System.Web.UI.Page
    {
        private readonly AuthService _authService = new AuthService();
        private readonly OAuthService _oauthService = new OAuthService();
        private readonly CaptchaService _captchaService = new CaptchaService();

        protected string TurnstileSiteKey { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            TurnstileSiteKey = CaptchaService.GetSiteKey();

            if (Session["UserId"] != null)
            {
                Response.Redirect("~/customer_page/onyx_home.aspx");
            }
        }

        protected async void btnRegister_Click(object sender, EventArgs e)
        {
            string fullName = txtFullName.Text.Trim();
            string username = txtUsername.Text.Trim();
            string email = txtEmail.Text.Trim();
            string dobString = txtDob.Text;
            string phoneNumber = txtPhone.Text.Trim();
            string address = txtAddress.Text.Trim();
            string password = txtPassword.Text;
            string confirmPassword = txtConfirmPassword.Text;

            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(username) ||
                string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password) ||
                string.IsNullOrEmpty(dobString))
            {
                ShowMessage("Please fill in all required fields.", false);
                return;
            }

            if (password != confirmPassword)
            {
                ShowMessage("Passwords do not match.", false);
                return;
            }

            DateTime dob;
            if (!DateTime.TryParse(dobString, out dob))
            {
                ShowMessage("Invalid Date of Birth format.", false);
                return;
            }

            string captchaToken = Request.Form["cf-turnstile-response"];
            bool captchaValid = await _captchaService.VerifyCaptchaAsync(
                captchaToken,
                Request.UserHostAddress);

            if (!captchaValid)
            {
                ShowMessage("Please complete the Cloudflare verification before registering.", false);
                return;
            }

            // Defaults to "customer" role via PostgreSQL DB schema DEFAULT as per PRD
            string error = _authService.Register(fullName, username, email, password, dob, address, phoneNumber);

            if (error == null)
            {
                Response.Redirect("onyx_login.aspx?registered=true");
            }
            else
            {
                ShowMessage(error, false);
            }
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            lblMessage.Text = $"<span class=\"auth-alert\" style=\"color: {(isSuccess ? "#c0c0c0" : "#ff4444")};\">{Server.HtmlEncode(message)}</span>";
            lblMessage.Visible = true;
        }

        protected void GoogleRegisterButton_Click(object sender, EventArgs e)
        {
            StartOAuth("google");
        }

        protected void DiscordRegisterButton_Click(object sender, EventArgs e)
        {
            StartOAuth("discord");
        }

        protected void FacebookRegisterButton_Click(object sender, EventArgs e)
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
                Session[OAuthProviderRegistry.GetStateModeSessionKey(state)] = "register";
                if (provider == "google")
                    Session["GoogleOAuthState"] = state;

                if (options.RequiresPkce)
                {
                    string codeVerifier = OAuthPkceHelper.CreateVerifier();
                    Session[OAuthProviderRegistry.GetCodeVerifierSessionKey(provider, state)] = codeVerifier;
                    codeChallenge = OAuthPkceHelper.CreateChallenge(codeVerifier);
                }

                string url = _oauthService.BuildAuthorizationUrl(
                    provider,
                    BuildOAuthRedirectUri(provider),
                    state,
                    codeChallenge);

                Response.Redirect(url, false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("OAuth signup start failed: " + ex);
                ShowMessage("This sign-up provider is not configured yet.", false);
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
    }
}
