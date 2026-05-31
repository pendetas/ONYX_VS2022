using System;
using System.Web.UI;
using ONYX_DDAC.Helpers;

namespace ONYX_DDAC.admin_page
{
    public partial class admin : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            AuthHelper.RequireAdmin(Page);
        }
    }
}
