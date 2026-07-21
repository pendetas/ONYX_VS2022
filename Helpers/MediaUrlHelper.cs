using System;
using System.Configuration;

namespace ONYX_DDAC.Helpers
{
    public static class MediaUrlHelper
    {
        public static string Resolve(string objectPath)
        {
            if (string.IsNullOrWhiteSpace(objectPath)) return string.Empty;

            string normalizedPath = objectPath.Trim().TrimStart('/');
            if (normalizedPath.Contains(".."))
                throw new ArgumentException("Media paths cannot contain parent directory segments.", "objectPath");

            return ReadDeliveryBaseUrl().TrimEnd('/') + "/" + normalizedPath;
        }

        private static string ReadDeliveryBaseUrl()
        {
            string value = Environment.GetEnvironmentVariable("ONYX_MEDIA_DELIVERY_BASE_URL") ??
                           Environment.GetEnvironmentVariable("ONYX_MEDIA_DELIVERY_BASE_URL", EnvironmentVariableTarget.User) ??
                           ConfigurationManager.AppSettings["ONYX_MEDIA_DELIVERY_BASE_URL"];

            Uri uri;
            if (string.IsNullOrWhiteSpace(value) ||
                !Uri.TryCreate(value.Trim(), UriKind.Absolute, out uri) ||
                (uri.Scheme != Uri.UriSchemeHttp && uri.Scheme != Uri.UriSchemeHttps))
            {
                throw new InvalidOperationException("ONYX_MEDIA_DELIVERY_BASE_URL must be an absolute HTTP or HTTPS URL.");
            }

            return value.Trim();
        }
    }
}
