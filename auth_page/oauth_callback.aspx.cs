using System;
using System.Configuration;
using System.IO;
using System.Threading.Tasks;
using System.Web.UI;
using Npgsql;
using ONYX_DDAC.Helpers;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.auth_page
{
    public partial class oauth_callback : Page
    {
        private readonly AuthService _authService = new AuthService();
        private readonly OAuthService _oauthService = new OAuthService();

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            ViewStateUserKey = AuthHelper.GetOrCreateViewStateUserKey(this);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            RegisterAsyncTask(new PageAsyncTask(HandleCallbackAsync));
        }

        private async Task HandleCallbackAsync()
        {
            string actualState = Request.QueryString["state"];
            string provider = GetProviderFromState(actualState);
            string mode = GetModeFromState(actualState);

            if (!string.IsNullOrWhiteSpace(Request.QueryString["error"]))
            {
                RemoveModeFromState(actualState);
                RemoveCodeVerifier(provider, actualState);
                RedirectToLogin(BuildReason(provider, "error"));
                return;
            }

            if (string.IsNullOrWhiteSpace(provider) || !IsExpectedState(provider, actualState))
            {
                RemoveModeFromState(actualState);
                RemoveCodeVerifier(provider, actualState);
                RedirectToLogin("oauth_state");
                return;
            }

            try
            {
                string codeVerifier = GetCodeVerifier(provider, actualState);
                RemoveCodeVerifier(provider, actualState);
                RemoveModeFromState(actualState);
                OAuthProfile profile = await _oauthService.ExchangeCodeForProfileAsync(
                    provider,
                    Request.QueryString["code"],
                    BuildRedirectUri(),
                    codeVerifier);

                bool created;
                User user;
                if (string.Equals(mode, "register", StringComparison.OrdinalIgnoreCase))
                {
                    user = _authService.LoginOrCreateOAuthUser(profile, out created);
                }
                else
                {
                    created = false;
                    user = _authService.LoginExistingOAuthUser(profile);
                    if (user == null)
                    {
                        RedirectToLogin(BuildReason(provider, "not_registered"));
                        return;
                    }
                }

                if (created)
                {
                    OAuthProviderOptions options = OAuthProviderRegistry.GetRequired(profile.Provider);
                    _authService.QueueAccountCreatedNotice(
                        profile.Email,
                        profile.FullName,
                        options.DisplayName);
                }

                AuthHelper.EstablishAuthenticatedSession(this, user);
                PostAuthRedirectHelper.Redirect(this, user);
            }
            catch (Exception exception)
            {
                WriteOAuthDebugLog(provider, exception);
                System.Diagnostics.Trace.TraceError(
                    "OAuth callback failed for " + provider + ": " +
                    exception.GetType().Name + ": " + exception.Message);
                RedirectToLogin(GetFailureReason(provider, exception));
            }
        }

        private string GetProviderFromState(string state)
        {
            if (string.IsNullOrWhiteSpace(state))
                return null;

            return Session[OAuthProviderRegistry.GetStateProviderSessionKey(state)] as string;
        }

        private string GetModeFromState(string state)
        {
            if (string.IsNullOrWhiteSpace(state))
                return null;

            return Session[OAuthProviderRegistry.GetStateModeSessionKey(state)] as string;
        }

        private void RemoveModeFromState(string state)
        {
            if (!string.IsNullOrWhiteSpace(state))
                Session.Remove(OAuthProviderRegistry.GetStateModeSessionKey(state));
        }

        private bool IsExpectedState(string provider, string actualState)
        {
            string expectedState = Session[OAuthProviderRegistry.GetStateSessionKey(provider)] as string;
            Session.Remove(OAuthProviderRegistry.GetStateSessionKey(provider));
            if (!string.IsNullOrWhiteSpace(actualState))
            {
                Session.Remove(OAuthProviderRegistry.GetStateProviderSessionKey(actualState));
            }

            return !string.IsNullOrWhiteSpace(expectedState) &&
                   string.Equals(expectedState, actualState, StringComparison.Ordinal);
        }

        private string GetCodeVerifier(string provider, string state)
        {
            if (string.IsNullOrWhiteSpace(provider) || string.IsNullOrWhiteSpace(state))
                return null;

            return Session[OAuthProviderRegistry.GetCodeVerifierSessionKey(provider, state)] as string;
        }

        private void RemoveCodeVerifier(string provider, string state)
        {
            if (string.IsNullOrWhiteSpace(provider) || string.IsNullOrWhiteSpace(state))
                return;

            Session.Remove(OAuthProviderRegistry.GetCodeVerifierSessionKey(provider, state));
        }

        private string BuildRedirectUri()
        {
            return Request.Url.GetLeftPart(UriPartial.Authority) +
                   ResolveUrl("~/auth_page/oauth_callback.aspx");
        }

        private void RedirectToLogin(string reason)
        {
            Response.Redirect("~/auth_page/onyx_login.aspx?oauth=" + reason, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private static string BuildReason(string provider, string suffix)
        {
            if (string.IsNullOrWhiteSpace(provider))
                return "oauth_" + suffix;

            return OAuthProviderRegistry.NormalizeProvider(provider) + "_" + suffix;
        }

        private static string GetFailureReason(string provider, Exception exception)
        {
            if (exception is ConfigurationErrorsException)
                return BuildReason(provider, "config");

            if (exception is PostgresException ||
                exception is NpgsqlException ||
                exception.GetType().FullName.IndexOf("Npgsql", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                return BuildReason(provider, "database");
            }

            string message = exception.Message ?? string.Empty;
            if (message.IndexOf("token", StringComparison.OrdinalIgnoreCase) >= 0 ||
                message.IndexOf("OAuth", StringComparison.OrdinalIgnoreCase) >= 0 ||
                message.IndexOf("Google", StringComparison.OrdinalIgnoreCase) >= 0 ||
                message.IndexOf("Discord", StringComparison.OrdinalIgnoreCase) >= 0 ||
                message.IndexOf("Facebook", StringComparison.OrdinalIgnoreCase) >= 0 ||
                message.IndexOf("X", StringComparison.OrdinalIgnoreCase) >= 0 ||
                message.IndexOf("PKCE", StringComparison.OrdinalIgnoreCase) >= 0 ||
                message.IndexOf("audience", StringComparison.OrdinalIgnoreCase) >= 0 ||
                message.IndexOf("issuer", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                return BuildReason(provider, "token");
            }

            return BuildReason(provider, "failed");
        }

        private void WriteOAuthDebugLog(string provider, Exception exception)
        {
            try
            {
                string path = Server.MapPath("~/App_Data/oauth_debug.log");
                var postgresException = exception as PostgresException;
                string sqlState = postgresException == null ? "" : " SQLSTATE=" + postgresException.SqlState;

                File.AppendAllText(
                    path,
                    "[" + DateTime.UtcNow.ToString("u") + "] " +
                    "[" + (provider ?? "unknown") + "] " +
                    exception.GetType().FullName +
                    sqlState +
                    Environment.NewLine +
                    exception +
                    Environment.NewLine +
                    Environment.NewLine);
            }
            catch
            {
                // Diagnostics must never break the OAuth callback path.
            }
        }
    }
}
