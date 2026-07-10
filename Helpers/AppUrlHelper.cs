using System;
using System.Configuration;
using System.Web;
using System.Web.UI;

namespace ONYX_DDAC.Helpers
{
    public static class AppUrlHelper
    {
        public static string GetBaseUrl(Page page)
        {
            string configured = GetConfiguredBaseUrl();
            if (!string.IsNullOrWhiteSpace(configured))
                return configured.TrimEnd('/');

            if (page == null || page.Request == null || page.Request.Url == null)
                throw new ConfigurationErrorsException("APP_BASE_URL is required when no current request URL is available.");

            return page.Request.Url.GetLeftPart(UriPartial.Authority).TrimEnd('/');
        }

        public static string BuildAbsoluteUrl(Page page, string appRelativePath)
        {
            if (page == null)
                throw new ArgumentNullException(nameof(page));

            string resolvedPath = page.ResolveUrl(appRelativePath);
            return GetBaseUrl(page) + "/" + resolvedPath.TrimStart('/');
        }

        private static string GetConfiguredBaseUrl()
        {
            string value = Environment.GetEnvironmentVariable("APP_BASE_URL") ??
                           Environment.GetEnvironmentVariable("APP_BASE_URL", EnvironmentVariableTarget.User) ??
                           ConfigurationManager.AppSettings["AppBaseUrl"] ??
                           ConfigurationManager.AppSettings["StripeAppBaseUrl"];

            if (string.IsNullOrWhiteSpace(value) ||
                value.IndexOf("REPLACE_", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                return null;
            }

            if (!Uri.TryCreate(value.Trim(), UriKind.Absolute, out Uri uri) ||
                (uri.Scheme != Uri.UriSchemeHttp && uri.Scheme != Uri.UriSchemeHttps))
            {
                throw new ConfigurationErrorsException("APP_BASE_URL must be an absolute http or https URL.");
            }

            return uri.AbsoluteUri;
        }
    }
}
