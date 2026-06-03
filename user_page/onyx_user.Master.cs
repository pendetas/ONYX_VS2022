using System;
using System.Web.UI;

namespace ONYX_DDAC.user_page
{
    public partial class onyx_user : MasterPage
    {
        protected bool IsLoggedIn
        {
            get { return Session["UserId"] != null; }
        }

        protected string CurrentUsername
        {
            get
            {
                var username = Session["Username"];
                return username == null ? string.Empty : username.ToString();
            }
        }

        protected bool ShowMasterFooter
        {
            get
            {
                return !Page.AppRelativeVirtualPath.EndsWith("/Home.aspx", StringComparison.OrdinalIgnoreCase);
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
        }
    }
}
