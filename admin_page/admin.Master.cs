using System;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using ONYX_DDAC.Helpers;

namespace ONYX_DDAC.admin_page
{
    public partial class admin : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            AuthHelper.RequireAdmin(Page);
            HighlightActiveNavLink();
        }

        /// <summary>
        /// Determines the current page filename and sets the CSS "active" class
        /// on the matching sidebar anchor so the highlighted nav item is always correct.
        /// </summary>
        private void HighlightActiveNavLink()
        {
            string currentPage = System.IO.Path.GetFileName(Request.FilePath).ToLowerInvariant();

            // Main sidebar menu items (no default base class).
            var menuMap = new System.Collections.Generic.Dictionary<string, HtmlAnchor>
            {
                { "onyx_admin_dashboard.aspx", navDashboard },
                { "onyx_admin_products.aspx",  navProducts  },
                { "onyx_admin_orders.aspx",    navOrders    },
                { "onyx_admin_promos.aspx",    navPromos    },
                { "onyx_admin_users.aspx",     navUsers     }
            };

            foreach (var anchor in menuMap.Values)
                anchor.Attributes["class"] = "";

            HtmlAnchor active;
            if (menuMap.TryGetValue(currentPage, out active))
                active.Attributes["class"] = "active";

            // Settings link keeps its base class; active is additive.
            navSettings.Attributes["class"] = currentPage == "onyx_admin_settings.aspx"
                ? "sidebar-bottom-link active"
                : "sidebar-bottom-link";
        }

        protected void btnLogOut_Click(object sender, EventArgs e)
        {
            Session.Clear();
            FormsAuthentication.SignOut();
            Response.Redirect("~/auth_page/onyx_Admin_Login.aspx");
        }
    }
}