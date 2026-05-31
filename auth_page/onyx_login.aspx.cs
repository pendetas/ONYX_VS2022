using System;
using System.Web.Security;
using System.Web.UI;
using ONYX_DDAC.Helpers;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.auth_page
{
    public partial class onyx_login : Page
    {
        private readonly AuthService authService = new AuthService();

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void LoginButton_Click(object sender, EventArgs e)
        {
            if (!ValidationHelper.IsValidEmail(EmailTextBox.Text))
            {
                ShowMessage("Enter a valid email address.");
                return;
            }

            try
            {
                LoginResult result = authService.Login(EmailTextBox.Text.Trim(), PasswordTextBox.Text);

                if (!result.Succeeded)
                {
                    ShowMessage(result.Message);
                    return;
                }

                Session["UserId"] = result.User.Id;
                Session["Username"] = result.User.Username;
                Session["Role"] = result.User.Role;
                FormsAuthentication.SetAuthCookie(result.User.Email, false);

                Response.Redirect(
                    string.Equals(result.User.Role, "admin", StringComparison.OrdinalIgnoreCase)
                        ? "~/admin_page/onyx_admin_dashboard.aspx"
                        : "~/customer_page/onyx_catalog.aspx",
                    true);
            }
            catch (Exception ex)
            {
                ShowMessage(ex.Message);
            }
        }

        private void ShowMessage(string message)
        {
            MessagePanel.Visible = true;
            MessageLiteral.Text = Server.HtmlEncode(message);
        }
    }
}
