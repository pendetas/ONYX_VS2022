using System;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using ONYX_DDAC.Helpers;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.auth_page
{
    public partial class onyx_forgotpassword : Page
    {
        private readonly AuthService authService = new AuthService();

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void ResetButton_Click(object sender, EventArgs e)
        {
            RegisterAsyncTask(new PageAsyncTask(RequestResetAsync));
        }

        private async Task RequestResetAsync()
        {
            string email = (EmailTextBox.Text ?? string.Empty).Trim();

            if (string.IsNullOrWhiteSpace(email) || !LooksLikeEmail(email))
            {
                ShowMessage("Enter a valid email address connected to your ONYX account.", false);
                return;
            }

            if (!authService.IsAuthRequestAllowed(
                "forgot_password",
                AuthService.BuildRateLimitKey(email, Request.UserHostAddress),
                3,
                TimeSpan.FromMinutes(15),
                TimeSpan.FromMinutes(30)))
            {
                ShowMessage("Too many reset requests. Please wait 30 minutes and try again.", false);
                return;
            }

            try
            {
                await authService.RequestPasswordResetAsync(email, BuildResetPasswordUrl);
            }
            catch (Exception exception)
            {
                System.Diagnostics.Trace.TraceWarning(
                    "Password reset request failed: " + exception.GetType().Name);
            }

            ShowMessage("If that email matches an ONYX account, reset instructions will be prepared. For urgent access, contact support@onyxgaming.com.", true);
        }

        private string BuildResetPasswordUrl(string token)
        {
            return AppUrlHelper.BuildAbsoluteUrl(this, "~/auth_page/onyx_resetpassword.aspx") +
                   "?token=" +
                   HttpUtility.UrlEncode(token);
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            MessagePanel.Visible = true;
            string color = isSuccess ? "#d8dde3" : "#ff2a5f";
            MessageLiteral.Text = string.Format(
                "<span class=\"auth-alert\" style=\"color: {0};\">{1}</span>",
                color,
                Server.HtmlEncode(message));
        }

        private static bool LooksLikeEmail(string email)
        {
            int atIndex = email.IndexOf('@');
            return atIndex > 0 && atIndex < email.Length - 1 && email.IndexOf('.', atIndex) > atIndex + 1;
        }
    }
}
