using System;
using System.Diagnostics;
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

            if (RoutesToAdminDashboard(user.Role))
                return "~/admin_page/onyx_admin_dashboard.aspx";

            if (CustomerRequiresPersonalization(user))
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

        private static bool RoutesToAdminDashboard(string role)
        {
            return string.Equals(role, "admin", StringComparison.OrdinalIgnoreCase) ||
                   string.Equals(role, "owner", StringComparison.OrdinalIgnoreCase) ||
                   string.Equals(role, "staff", StringComparison.OrdinalIgnoreCase);
        }

        private static bool CustomerRequiresPersonalization(User user)
        {
            if (!string.Equals(user.Role, "customer", StringComparison.OrdinalIgnoreCase))
                return false;

            try
            {
                return new PersonalizationService().UserRequiresPersonalization(user);
            }
            catch (Exception exception)
            {
                Trace.TraceWarning(
                    "Personalization lookup failed during post-auth redirect for user {0}: {1}",
                    user.Id,
                    exception);

                return true;
            }
        }
    }
}
