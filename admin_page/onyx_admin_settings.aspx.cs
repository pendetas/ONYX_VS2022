using System;
using System.Web.UI;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.admin_page
{
    public partial class onyx_admin_settings : Page
    {
        private readonly UserService _svc  = new UserService();
        private readonly AuthService _auth = new AuthService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindAdminList();

                if (Request.QueryString["pw"] == "1")
                    ShowMessage(pwMsgBox, pnlPwMsg, "Password updated successfully.", isError: false);
            }
        }

        private void BindAdminList()
        {
            var admins = _svc.GetAdminList();

            if (admins.Count == 0)
            {
                pnlNoAdmins.Visible   = true;
                AdminRepeater.Visible = false;
            }
            else
            {
                pnlNoAdmins.Visible      = false;
                AdminRepeater.DataSource = admins;
                AdminRepeater.DataBind();
            }
        }

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            string username = Session["Username"]?.ToString();
            if (string.IsNullOrEmpty(username))
            {
                ShowMessage(pwMsgBox, pnlPwMsg, "Session expired. Please log in again.", isError: true);
                return;
            }

            string error = _auth.ChangePassword(
                username,
                txtCurrent.Text,
                txtNewPass.Text,
                txtConfirm.Text);

            if (error != null)
            {
                ShowMessage(pwMsgBox, pnlPwMsg, error, isError: true);
                BindAdminList();
                return;
            }

            Response.Redirect("onyx_admin_settings.aspx?pw=1");
        }

        private static void ShowMessage(
            System.Web.UI.HtmlControls.HtmlGenericControl container,
            System.Web.UI.WebControls.Panel panel,
            string message,
            bool isError)
        {
            panel.Visible = true;
            container.Attributes["class"] = isError ? "alert-error" : "alert-success";
            container.InnerHtml = System.Web.HttpUtility.HtmlEncode(message);
        }
    }
}
