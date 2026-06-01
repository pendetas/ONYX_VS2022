using System;
using System.Web.UI;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.auth_page
{
    public partial class onyx_register : System.Web.UI.Page
    {
        // Instantiate the AuthService
        private readonly AuthService _authService = new AuthService();

        protected void Page_Load(object sender, EventArgs e)
        {
            // If the user is already logged in, redirect them away from the register page
            if (Session["UserId"] != null)
            {
                Response.Redirect("~/customer_page/onyx_catalog.aspx");
            }
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            // Grab the text from the UI controls
            string fullName = txtFullName.Text.Trim();
            string username = txtUsername.Text.Trim();
            string email = txtEmail.Text.Trim();
            string dobString = txtDob.Text;
            string phoneNumber = txtPhone.Text.Trim();
            string address = txtAddress.Text.Trim();
            string password = txtPassword.Text;
            string confirmPassword = txtConfirmPassword.Text;

            // 1. Basic Validation
            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(username) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password) || string.IsNullOrEmpty(dobString))
            {
                ShowMessage("Please fill in all required fields.", false);
                return;
            }

            if (password != confirmPassword)
            {
                ShowMessage("Passwords do not match.", false);
                return;
            }

            // Parse the Date of Birth safely
            DateTime dob;
            if (!DateTime.TryParse(dobString, out dob))
            {
                ShowMessage("Invalid Date of Birth.", false);
                return;
            }

            // 2. Call the Business Logic Layer
            bool isSuccess = _authService.Register(fullName, username, email, password, dob, address, phoneNumber);

            // 3. Handle the Result
            if (isSuccess)
            {
                // Redirect to login page with a success query string
                Response.Redirect("onyx_login.aspx?registered=true");
            }
            else
            {
                // This usually fails if the username or email already exists in the database
                ShowMessage("Registration failed. The username or email might already be taken.", false);
            }
        }

        // Helper method to display messages on the UI
        private void ShowMessage(string message, bool isSuccess)
        {
            lblMessage.Text = message;
            lblMessage.CssClass = "onyx-alert d-block";
            lblMessage.Visible = true;
        }
    }
}
