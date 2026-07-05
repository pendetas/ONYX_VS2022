using System;
using System.Web.UI;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.auth_page
{
    public partial class onyx_resetpassword : Page
    {
        private readonly AuthService authService = new AuthService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
                return;

            if (!authService.IsPasswordResetTokenValid(ResetToken))
            {
                ResetFormPanel.Visible = false;
                ShowMessage("This reset link is invalid or has expired. Request a new password reset to continue.", false);
            }
        }

        protected void ResetPasswordButton_Click(object sender, EventArgs e)
        {
            string error = authService.ResetPassword(
                ResetToken,
                NewPasswordTextBox.Text,
                ConfirmPasswordTextBox.Text);

            if (error != null)
            {
                ShowMessage(error, false);
                return;
            }

            ResetFormPanel.Visible = false;
            ShowMessage("Your password has been updated. You can now sign in with the new password.", true);
        }

        private string ResetToken
        {
            get { return Request.QueryString["token"] ?? string.Empty; }
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
    }
}
