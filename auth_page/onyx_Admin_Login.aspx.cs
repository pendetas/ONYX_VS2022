using System;
using System.Web.UI;
using ONYX_DDAC.Helpers;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.auth_page
{
    public partial class onyx_Admin_Login : Page
    {
        private readonly AuthService _authService = new AuthService();

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            ViewStateUserKey = AuthHelper.GetOrCreateViewStateUserKey(this);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack && AuthHelper.IsAdmin(this))
            {
                Response.Redirect("~/admin_page/onyx_admin_dashboard.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            try
            {
                User user = _authService.Login(
                    txtUser.Text,
                    txtPass.Text,
                    Request.UserHostAddress);

                if (user == null ||
                    !string.Equals(user.Role, "admin", StringComparison.OrdinalIgnoreCase))
                {
                    ShowError(AuthService.LoginFailureMessage);
                    return;
                }

                AuthHelper.EstablishAuthenticatedSession(this, user);
                Response.Redirect("~/admin_page/onyx_admin_dashboard.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception exception)
            {
                System.Diagnostics.Trace.TraceError(
                    "Admin login page failure: " + exception.GetType().Name);
                ShowError(AuthService.LoginFailureMessage);
            }
        }

        private void ShowError(string message)
        {
            lblError.Text = Server.HtmlEncode(message);
            lblError.Visible = true;
        }
    }
}
