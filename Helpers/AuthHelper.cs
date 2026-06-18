using System.Web;
using System.Web.Security;
using System.Web.SessionState;
using System.Web.UI;
using System.Security.Cryptography;
using ONYX_DDAC.Models;

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

        public static string GetOrCreateViewStateUserKey(Page page)
        {
            const string sessionKey = "ViewStateUserKey";
            string value = page.Session[sessionKey] as string;
            if (!string.IsNullOrEmpty(value))
                return value;

            byte[] bytes = new byte[32];
            using (RandomNumberGenerator random = RandomNumberGenerator.Create())
                random.GetBytes(bytes);

            value = System.Convert.ToBase64String(bytes);
            page.Session[sessionKey] = value;
            return value;
        }

        public static void RequireLogin(Page page)
        {
            if (!IsLoggedIn(page))
            {
                page.Response.Redirect("~/auth_page/onyx_login.aspx", false);
                CompleteRequest();
            }
        }

        public static void RequireAdmin(Page page)
        {
            if (IsAdmin(page))
                return;

            if (IsLoggedIn(page))
            {
                page.Response.Redirect("~/customer_page/onyx_catalog.aspx", false);
                CompleteRequest();
                return;
            }

            page.Response.Redirect("~/auth_page/onyx_login.aspx", false);
            CompleteRequest();
        }

        public static void EstablishAuthenticatedSession(Page page, User user)
        {
            FormsAuthentication.SignOut();
            page.Session.Clear();
            page.Session.RemoveAll();

            page.Session["UserId"] = user.Id;
            page.Session["Username"] = user.Username;
            page.Session["Role"] = user.Role;
            FormsAuthentication.SetAuthCookie(user.Email, false);
        }

        public static void SignOut(Page page)
        {
            FormsAuthentication.SignOut();
            page.Session.Clear();
            page.Session.RemoveAll();
            page.Session.Abandon();

            ExpireCookie(
                page.Response,
                FormsAuthentication.FormsCookieName,
                FormsAuthentication.RequireSSL);
            ExpireCookie(
                page.Response,
                "ASP.NET_SessionId",
                page.Request.IsSecureConnection);
        }

        private static void ExpireCookie(
            HttpResponse response,
            string cookieName,
            bool secure)
        {
            HttpCookie cookie = new HttpCookie(cookieName, string.Empty)
            {
                Expires = System.DateTime.UtcNow.AddYears(-1),
                HttpOnly = true,
                Secure = secure,
                SameSite = SameSiteMode.Lax
            };
            response.Cookies.Add(cookie);
        }

        private static void CompleteRequest()
        {
            if (HttpContext.Current != null &&
                HttpContext.Current.ApplicationInstance != null)
            {
                HttpContext.Current.ApplicationInstance.CompleteRequest();
            }
        }
    }
}
