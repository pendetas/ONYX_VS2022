using System;
using System.Web.Security;
using System.Web.UI;
using BCrypt.Net;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.auth_page
{
    public partial class onyx_Admin_Login : Page
    {
        private readonly UserRepository _repo = new UserRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack && Session["Role"] != null && Session["Role"].ToString() == "admin")
                Response.Redirect("~/admin_page/onyx_admin_dashboard.aspx");
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string username = txtUser.Text.Trim();
            string password = txtPass.Text;

            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
            {
                ShowError("Please enter your username and password.");
                return;
            }

            User user = _repo.GetUserByUsername(username);

            if (user == null || !user.Role.Equals("admin", StringComparison.OrdinalIgnoreCase))
            {
                ShowError("Invalid credentials. Access denied.");
                return;
            }

            bool valid = BCrypt.Net.BCrypt.EnhancedVerify(password, user.PasswordHash);
            if (!valid)
            {
                ShowError("Invalid credentials. Access denied.");
                return;
            }

            Session["UserId"]   = user.Id;
            Session["Username"] = user.Username;
            Session["Role"]     = "admin";
            FormsAuthentication.SetAuthCookie(user.Email, false);
            Response.Redirect("~/admin_page/onyx_admin_dashboard.aspx");
        }

        private void ShowError(string message)
        {
            lblError.Text    = Server.HtmlEncode(message);
            lblError.Visible = true;
        }
    }
}
