using System;
using System.Web.UI;
using BCrypt.Net;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.auth_page
{
    public partial class onyx_admin_register : Page
    {
        private readonly UserRepository _repo = new UserRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack &&
                string.Equals(Convert.ToString(Session["Role"]), "admin", StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("~/admin_page/onyx_admin_dashboard.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            string fullName  = txtFullName.Text.Trim();
            string username  = txtUsername.Text.Trim();
            string email     = txtEmail.Text.Trim();
            string password  = txtPassword.Text;
            string confirm   = txtConfirm.Text;

            // Basic validation
            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(username) ||
                string.IsNullOrEmpty(email)    || string.IsNullOrEmpty(password))
            {
                ShowError("All fields are required.");
                return;
            }

            if (password != confirm)
            {
                ShowError("Passwords do not match.");
                return;
            }

            if (password.Length < 8)
            {
                ShowError("Password must be at least 8 characters.");
                return;
            }

            // Duplicate check
            string duplicate = _repo.CheckDuplicate(username, email);
            if (duplicate == "username")
            {
                ShowError("That username is already taken.");
                return;
            }
            if (duplicate == "email")
            {
                ShowError("An account with that email already exists.");
                return;
            }

            // Hash and create
            string hash = BCrypt.Net.BCrypt.EnhancedHashPassword(password, 12);

            var user = new User
            {
                FullName     = fullName,
                Username     = username,
                Email        = email,
                PasswordHash = hash,
                Role         = "admin",
                Dob          = DateTime.Today,
                Address      = null,
                PhoneNumber  = null
            };

            bool created = _repo.CreateUser(user);
            if (!created)
            {
                ShowError("Registration failed. Please try again.");
                return;
            }

            lblError.Visible   = false;
            lblSuccess.Visible = true;
            lblSuccess.Text    = "Account created. <a href=\"onyx_Admin_Login.aspx\" style=\"color:rgba(255,255,255,0.55);text-decoration:underline;\">Sign in now</a>";
        }

        private void ShowError(string message)
        {
            lblError.Text    = Server.HtmlEncode(message);
            lblError.Visible = true;
            lblSuccess.Visible = false;
        }
    }
}
