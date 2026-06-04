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
            if (Request.QueryString["registered"] == "true")
            {
                ShowMessage("Registration successful. You can now sign in.", true);
            }
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

            try
            {
                // Normal Database Authentication Flow
                User user = authService.Login(emailOrUser, password);

                if (user == null)
                {
                    ShowMessage("Invalid credentials. Access denied.", false);
                    return;
                }

                var savedCart = Session["Cart"] as System.Collections.Generic.List<CartItem>;

                
                Session["UserId"] = user.Id;
                Session["Username"] = user.Username;
                Session["Role"] = user.Role;
                FormsAuthentication.SetAuthCookie(user.Email, false);

                new CartService().MergeSessionCartForUser(user.Id, savedCart);

                // Auto-detect role and route
                if (string.Equals(user.Role, "admin", StringComparison.OrdinalIgnoreCase))
                {
                    Response.Redirect("~/admin_page/onyx_admin_dashboard.aspx", true);
                }
                else
                {
                    Response.Redirect("~/customer_page/Home.aspx", true);
                }
            }
            catch (Exception ex)
            {
                ShowMessage(ex.Message, false);
            }
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            MessagePanel.Visible = true;
            MessageLiteral.Text = $"<span class=\"auth-alert\" style=\"color: {(isSuccess ? "#00ff87" : "#ff4444")};\">{Server.HtmlEncode(message)}</span>";
        }
    }
}
