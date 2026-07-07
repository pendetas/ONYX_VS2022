using ONYX_DDAC.Services;
using System;
using System.Web.UI;

namespace ONYX_DDAC.customer_page
{
    public partial class onyx_user : MasterPage
    {
        protected bool IsLoggedIn
        {
            get { return Session["UserId"] != null; }
        }


        protected void Page_PreRender(object sender, EventArgs e)
        {
            var cartService = new CartService();
            litCartCount.Text = cartService.GetCartItemCount().ToString();
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

        protected bool ShowAiChatbot
        {
            get
            {
                string currentPath = Page.AppRelativeVirtualPath ?? string.Empty;

                return !currentPath.StartsWith("~/auth_page/", StringComparison.OrdinalIgnoreCase)
                    && !currentPath.EndsWith("/onyx_checkout.aspx", StringComparison.OrdinalIgnoreCase)
                    && !currentPath.EndsWith("/onyx_invoice.aspx", StringComparison.OrdinalIgnoreCase);
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnCustomerLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/auth_page/onyx_login.aspx", true);
        }
    }
}
