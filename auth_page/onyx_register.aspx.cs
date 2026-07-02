using System;
using System.Web.UI;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.auth_page
{
    public partial class onyx_register : System.Web.UI.Page
    {
        private readonly AuthService _authService = new AuthService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] != null)
            {
                Response.Redirect("~/customer_page/onyx_catalog.aspx");
            }
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            string fullName = txtFullName.Text.Trim();
            string username = txtUsername.Text.Trim();
            string email = txtEmail.Text.Trim();
            string dobString = txtDob.Text;
            string phoneNumber = txtPhone.Text.Trim();
            string address = txtAddress.Text.Trim();
            string password = txtPassword.Text;
            string confirmPassword = txtConfirmPassword.Text;

            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(username) ||
                string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password) ||
                string.IsNullOrEmpty(dobString))
            {
                ShowMessage("Please fill in all required fields.", false);
                return;
            }

            if (password != confirmPassword)
            {
                ShowMessage("Passwords do not match.", false);
                return;
            }

            DateTime dob;
            if (!DateTime.TryParse(dobString, out dob))
            {
                ShowMessage("Invalid Date of Birth format.", false);
                return;
            }

            // Defaults to "customer" role via PostgreSQL DB schema DEFAULT as per PRD
            string error = _authService.Register(fullName, username, email, password, dob, address, phoneNumber);

            if (error == null)
            {
                Response.Redirect("onyx_login.aspx?registered=true");
            }
            else
            {
                ShowMessage(error, false);
            }
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            lblMessage.Text = $"<span class=\"auth-alert\" style=\"color: {(isSuccess ? "#c0c0c0" : "#ff4444")};\">{Server.HtmlEncode(message)}</span>";
            lblMessage.Visible = true;
        }
    }
}