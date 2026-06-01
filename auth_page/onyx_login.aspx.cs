using System;
using System.Web.Security;
using System.Web.UI;
using ONYX_DDAC.Helpers;
using ONYX_DDAC.Models;
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
                User user = authService.Login(EmailTextBox.Text.Trim(), PasswordTextBox.Text);

                if (user == null)
                {
                    ShowMessage("Invalid email or password.");
                    return;
                }

                Session["UserId"] = user.Id;
                Session["Username"] = user.Username;
                Session["Role"] = user.Role;
                FormsAuthentication.SetAuthCookie(user.Email, false);

                Response.Redirect(
                    string.Equals(user.Role, "admin", StringComparison.OrdinalIgnoreCase)
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
