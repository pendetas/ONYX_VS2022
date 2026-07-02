using System.Web;
using System.Web.Security;
using System.Web.SessionState;
using System.Web.UI;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.Helpers
{
    public static class AuthHelper
    {
        private const string ViewStateUserKeySessionKey = "ViewStateUserKey";

        public static string GetOrCreateViewStateUserKey(Page page)
        {
            string key = page.Session[ViewStateUserKeySessionKey] as string;
            if (string.IsNullOrWhiteSpace(key))
            {
                key = System.Guid.NewGuid().ToString("N");
                page.Session[ViewStateUserKeySessionKey] = key;
            }

            return key;
        }

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
                page.Response.Redirect("~/auth_page/onyx_Admin_Login.aspx", true);
            }
        }

        public static void SignOut(HttpSessionState session)
        {
            session.Clear();
            FormsAuthentication.SignOut();
        }

        public static void EstablishAuthenticatedSession(Page page, User user)
        {
            var savedCart = page.Session["Cart"] as System.Collections.Generic.List<CartItem>;

            page.Session["UserId"] = user.Id;
            page.Session["Username"] = user.Username;
            page.Session["Role"] = user.Role;
            FormsAuthentication.SetAuthCookie(user.Email, false);

            new CartService().MergeSessionCartForUser(user.Id, savedCart);
        }
    }
}
