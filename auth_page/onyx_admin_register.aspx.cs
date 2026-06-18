using System;
using System.Web.UI;
using ONYX_DDAC.Helpers;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.auth_page
{
    public partial class onyx_admin_register : Page
    {
        private readonly AuthService _authService = new AuthService();

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            ViewStateUserKey = AuthHelper.GetOrCreateViewStateUserKey(this);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            AuthHelper.RequireAdmin(Page);
            if (!AuthHelper.IsAdmin(Page))
                return;
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            string fullName  = txtFullName.Text.Trim();
            string username  = txtUsername.Text.Trim();
            string email     = txtEmail.Text.Trim();
            string password  = txtPassword.Text;
            string confirm   = txtConfirm.Text;

            string error = _authService.RegisterAdmin(
                fullName,
                username,
                email,
                password,
                confirm);
            if (error != null)
            {
                ShowError(error);
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
