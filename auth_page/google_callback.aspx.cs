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
    public partial class google_callback : Page
    {
        private const string StateSessionKey = "GoogleOAuthState";
        private readonly AuthService _authService = new AuthService();
        private readonly GoogleOAuthService _googleOAuthService = new GoogleOAuthService();

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
            WriteOAuthFlowLog("callback_start");

            string error = Request.QueryString["error"];
            if (!string.IsNullOrWhiteSpace(error))
            {
                WriteOAuthFlowLog("provider_error error=" + error);
                RedirectToLogin("google_error");
                return;
            }

            string expectedState = Session[StateSessionKey] as string;
            string actualState = Request.QueryString["state"];
            Session.Remove(StateSessionKey);

            if (string.IsNullOrWhiteSpace(expectedState) ||
                !string.Equals(expectedState, actualState, StringComparison.Ordinal))
            {
                WriteOAuthFlowLog("state_failed");
                RedirectToLogin("google_state");
                return;
            }

            try
            {
                GoogleOAuthProfile profile =
                    await _googleOAuthService.ExchangeCodeForProfileAsync(
                        Request.QueryString["code"],
                        BuildRedirectUri());

                WriteOAuthFlowLog("profile_received email=" + profile.Email);
                bool created;
                User user = _authService.LoginOrCreateOAuthUser(profile, out created);
                WriteOAuthFlowLog(
                    "account_ready userId=" + user.Id +
                    " created=" + created +
                    " email=" + profile.Email);

                if (created)
                {
                    _authService.QueueAccountCreatedNotice(
                        profile.Email,
                        profile.FullName,
                        OAuthProviderRegistry.GetRequired("google").DisplayName);
                    WriteOAuthFlowLog("welcome_email_queued email=" + profile.Email);
                }
                else
                {
                    WriteOAuthFlowLog("welcome_email_skipped_existing_account email=" + profile.Email);
                }

                AuthHelper.EstablishAuthenticatedSession(this, user);
                RedirectForRole(user.Role);
            }
            catch (Exception exception)
            {
                WriteOAuthDebugLog(exception);
                System.Diagnostics.Trace.TraceError(
                    "Google OAuth callback failed: " + exception.GetType().Name + ": " + exception.Message);
                RedirectToLogin(GetFailureReason(exception));
            }
        }

        private string BuildRedirectUri()
        {
            return Request.Url.GetLeftPart(UriPartial.Authority) +
                   ResolveUrl("~/auth_page/google_callback.aspx");
        }

        private void RedirectForRole(string role)
        {
            string target = GoogleOAuthRedirectHelper.GetSuccessTarget(role);

            Response.Redirect(target, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private void RedirectToLogin(string reason)
        {
            Response.Redirect("~/auth_page/onyx_login.aspx?oauth=" + reason, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private static string GetFailureReason(Exception exception)
        {
            if (exception is ConfigurationErrorsException)
                return "google_config";

            if (exception is PostgresException ||
                exception is NpgsqlException ||
                exception.GetType().FullName.IndexOf("Npgsql", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                return "google_database";
            }

            string message = exception.Message ?? string.Empty;
            if (message.IndexOf("token", StringComparison.OrdinalIgnoreCase) >= 0 ||
                message.IndexOf("Google", StringComparison.OrdinalIgnoreCase) >= 0 ||
                message.IndexOf("audience", StringComparison.OrdinalIgnoreCase) >= 0 ||
                message.IndexOf("issuer", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                return "google_token";
            }

            return "google_failed";
        }

        private void WriteOAuthDebugLog(Exception exception)
        {
            try
            {
                string basePath = Server.MapPath("~/App_Data");
                Directory.CreateDirectory(basePath);
                string path = Path.Combine(basePath, "google_oauth_debug.log");
                var postgresException = exception as PostgresException;
                string sqlState = postgresException == null ? "" : " SQLSTATE=" + postgresException.SqlState;

                File.AppendAllText(
                    path,
                    "[" + DateTime.UtcNow.ToString("u") + "] " +
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

        private void WriteOAuthFlowLog(string message)
        {
            try
            {
                string basePath = Server.MapPath("~/App_Data");
                Directory.CreateDirectory(basePath);
                string path = Path.Combine(basePath, "google_oauth_debug.log");
                File.AppendAllText(
                    path,
                    "[" + DateTime.UtcNow.ToString("u") + "] " + message + Environment.NewLine);
            }
            catch
            {
                // Diagnostics must never break the OAuth callback path.
            }
        }
    }
}
