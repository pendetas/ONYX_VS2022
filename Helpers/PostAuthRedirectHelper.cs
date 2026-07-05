using System;
using System.Web;
using System.Web.UI;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.Helpers
{
    public static class PostAuthRedirectHelper
    {
        public static string GetTarget(Page page, User user, string requestedCustomerTarget)
        {
            if (user == null)
                return "~/auth_page/onyx_login.aspx";

            if (string.Equals(user.Role, "admin", StringComparison.OrdinalIgnoreCase))
                return "~/admin_page/onyx_admin_dashboard.aspx";

            if (new PersonalizationService().UserRequiresPersonalization(user))
                return "~/customer_page/onyx_personalization.aspx";

            if (!string.IsNullOrWhiteSpace(requestedCustomerTarget))
                return requestedCustomerTarget;

            return "~/customer_page/onyx_home.aspx";
        }

        public static void Redirect(Page page, User user, string requestedCustomerTarget = null)
        {
            page.Response.Redirect(GetTarget(page, user, requestedCustomerTarget), false);
            HttpContext currentContext = HttpContext.Current;
            if (currentContext != null && currentContext.ApplicationInstance != null)
                currentContext.ApplicationInstance.CompleteRequest();
        }
    }
}
