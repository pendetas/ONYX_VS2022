using System;
using System.Web.UI;

namespace ONYX_DDAC.auth_page
{
    public partial class onyx_forgotpassword : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void ResetButton_Click(object sender, EventArgs e)
        {
            string email = (EmailTextBox.Text ?? string.Empty).Trim();

            if (string.IsNullOrWhiteSpace(email) || !LooksLikeEmail(email))
            {
                ShowMessage("Enter a valid email address connected to your ONYX account.", false);
                return;
            }

            ShowMessage("If that email matches an ONYX account, reset instructions will be prepared. For urgent access, contact support@onyxgaming.com.", true);
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
