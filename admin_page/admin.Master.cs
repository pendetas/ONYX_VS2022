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
            // Optional: AuthHelper.RequireAdmin(Page);
            HighlightActiveNavLink();
        }

        /// <summary>
        /// Determines the current page filename and sets the CSS "active" class
        /// on the matching sidebar anchor so the highlighted nav item is always correct.
        /// </summary>
        private void HighlightActiveNavLink()
        {
            string currentPage = System.IO.Path.GetFileName(Request.FilePath).ToLowerInvariant();

            // Map page filenames to their corresponding nav anchor controls.
            var navMap = new System.Collections.Generic.Dictionary<string, HtmlAnchor>
            {
                { "onyx_admin_dashboard.aspx",      navDashboard   },
                { "onyx_admin_products.aspx",        navProducts    },
                { "onyx_admin_products_form.aspx",   navProductForm },
                { "onyx_admin_orders.aspx",           navOrders      },
                { "onyx_admin_order_details.aspx",    navOrderDetail },
                { "onyx_admin_promos.aspx",           navPromos      },
                { "onyx_admin_users.aspx",            navUsers       }
            };

            foreach (var entry in navMap)
            {
                if (entry.Key == currentPage)
                    entry.Value.Attributes["class"] = "active";
            }
        }

        protected void btnLogOut_Click(object sender, EventArgs e)
        {
            Session.Clear();
            FormsAuthentication.SignOut();
            Response.Redirect("~/auth_page/onyx_login.aspx");
        }
    }
}