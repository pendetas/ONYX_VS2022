using System.Web;
using System.Web.Security;
using System.Web.SessionState;
using System.Web.UI;

namespace ONYX_DDAC.Helpers
{
    public static class AuthHelper
    {
        public static bool IsLoggedIn(Page page)
        {
            return page.Session["UserId"] != null;
        }

        public static bool IsAdmin(Page page)
        {
            return string.Equals(page.Session["Role"] as string, "admin", System.StringComparison.OrdinalIgnoreCase);
        }

        public static void RequireLogin(Page page)
        {
            if (!IsLoggedIn(page))
            {
                page.Response.Redirect("~/auth_page/onyx_login.aspx", true);
            }
        }

        public static void RequireAdmin(Page page)
        {
            if (!IsAdmin(page))
            {
                page.Response.Redirect("~/customer_page/onyx_catalog.aspx", true);
            }
        }

        public static void SignOut(HttpSessionState session)
        {
            session.Clear();
            FormsAuthentication.SignOut();
        }
    }
}
