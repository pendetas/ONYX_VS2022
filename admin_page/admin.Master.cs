using System;
using System.Web.Security;
using System.Web.UI;
using ONYX_DDAC.Helpers;

namespace ONYX_DDAC.admin_page
{
    public partial class admin : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Optional: AuthHelper.RequireAdmin(Page);
        }

        protected void btnLogOut_Click(object sender, EventArgs e)
        {
            Session.Clear();
            FormsAuthentication.SignOut();
            Response.Redirect("~/auth_page/onyx_login.aspx");
        }
    }
}