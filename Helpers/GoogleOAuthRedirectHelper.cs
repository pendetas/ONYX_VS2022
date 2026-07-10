using System;

namespace ONYX_DDAC.Helpers
{
    public static class GoogleOAuthRedirectHelper
    {
        public static string GetSuccessTarget(string role)
        {
            return string.Equals(role, "admin", StringComparison.OrdinalIgnoreCase)
                ? "~/admin_page/onyx_admin_dashboard.aspx"
                : "~/customer_page/onyx_home.aspx";
        }
    }
}
