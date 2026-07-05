using ONYX_DDAC.Services;
using System;
using System.Web.UI;

namespace ONYX_DDAC.customer_page
{
    public partial class onyx_user : MasterPage
    {
        private readonly PersonalizationService personalizationService = new PersonalizationService();

        protected bool IsLoggedIn
        {
            get { return Session["UserId"] != null; }
        }


        protected void Page_PreRender(object sender, EventArgs e)
        {
            try
            {
                var cartService = new CartService();
                litCartCount.Text = cartService.GetCartItemCount().ToString();
            }
            catch (Exception)
            {
                litCartCount.Text = "0";
            }
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
                return !Page.AppRelativeVirtualPath.EndsWith("/onyx_home.aspx", StringComparison.OrdinalIgnoreCase);
            }
        }

        protected string BodyCssClass
        {
            get { return IsPersonalizationPage ? "onyx-personalization-shell-page" : string.Empty; }
        }

        protected string HtmlCssClass
        {
            get { return IsPersonalizationPage ? "onyx-personalization-shell-page" : string.Empty; }
        }

        protected string ShellCssClass
        {
            get
            {
                string baseClass = "onyx-user-shell antialiased";
                if (IsPersonalizationPage)
                {
                    return baseClass + " onyx-personalization-shell";
                }

                return baseClass + " selection:bg-accent selection:text-black";
            }
        }

        private bool IsPersonalizationPage
        {
            get
            {
                return Page.AppRelativeVirtualPath.EndsWith("/onyx_personalization.aspx", StringComparison.OrdinalIgnoreCase);
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            EnsureCustomerPersonalizationCompleted();
        }

        protected void btnCustomerLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("~/auth_page/onyx_login.aspx", true);
        }

        private void EnsureCustomerPersonalizationCompleted()
        {
            if (IsPersonalizationPage || !IsCustomerPage() || !TryGetCustomerUserId(out long userId))
            {
                return;
            }

            if (personalizationService.HasCompletedProfile(userId))
            {
                return;
            }

            Response.Redirect("~/customer_page/onyx_personalization.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private bool IsCustomerPage()
        {
            return Page.AppRelativeVirtualPath.StartsWith("~/customer_page/", StringComparison.OrdinalIgnoreCase);
        }

        private bool TryGetCustomerUserId(out long userId)
        {
            userId = 0;

            string role = Convert.ToString(Session["Role"]);
            if (!string.Equals(role, "customer", StringComparison.OrdinalIgnoreCase))
            {
                return false;
            }

            object sessionUserId = Session["UserId"];
            if (sessionUserId is long longValue)
            {
                userId = longValue;
                return true;
            }

            return sessionUserId != null && long.TryParse(sessionUserId.ToString(), out userId);
        }
    }
}
