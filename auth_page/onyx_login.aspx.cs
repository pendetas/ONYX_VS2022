using System;
using System.Web.UI;
using ONYX_DDAC.Helpers;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.auth_page
{
    public partial class onyx_login : Page
    {
        private readonly AuthService authService = new AuthService();

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            ViewStateUserKey = AuthHelper.GetOrCreateViewStateUserKey(this);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] != null)
            {
                RedirectForRole(Session["Role"] as string);
                return;
            }

            if (!IsPostBack && Request.QueryString["registered"] == "true")
                ShowMessage("Registration successful. You can now sign in.", true);
        }

        protected void LoginButton_Click(object sender, EventArgs e)
        {
            try
            {
                User user = authService.Login(
                    EmailTextBox.Text,
                    PasswordTextBox.Text,
                    Request.UserHostAddress);

                if (user == null)
                {
                    ShowMessage(AuthService.LoginFailureMessage, false);
                    return;
                }

                AuthHelper.EstablishAuthenticatedSession(this, user);
                RedirectForRole(user.Role);
            }
            catch (Exception exception)
            {
                System.Diagnostics.Trace.TraceError(
                    "Login page failure: " + exception.GetType().Name);
                ShowMessage(AuthService.LoginFailureMessage, false);
            }
        }

        private void RedirectForRole(string role)
        {
            string target = string.Equals(
                role,
                "admin",
                StringComparison.OrdinalIgnoreCase)
                ? "~/admin_page/onyx_admin_dashboard.aspx"
                : "~/customer_page/onyx_catalog.aspx";

            Response.Redirect(target, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            MessagePanel.Visible = true;
            MessageLiteral.Text =
                "<span class=\"auth-alert\" style=\"color: " +
                (isSuccess ? "#c0c0c0" : "#ff4444") +
                ";\">" +
                Server.HtmlEncode(message) +
                "</span>";
        }
    }
}
