using System;
using System.Linq;
using System.Text;
using ONYX_DDAC.Helpers;

namespace ONYX_DDAC.Helpers
{
    public static class GoogleOAuthAccountHelper
    {
        public static string BuildBaseUsername(string email, string fullName)
        {
            string source = null;
            string normalizedEmail = ValidationHelper.NormalizeIdentifier(email);
            int atIndex = string.IsNullOrEmpty(normalizedEmail) ? -1 : normalizedEmail.IndexOf('@');

            if (atIndex > 0)
            {
                source = normalizedEmail.Substring(0, atIndex);
                int plusIndex = source.IndexOf('+');
                if (plusIndex > 0)
                    source = source.Substring(0, plusIndex);
            }

            if (string.IsNullOrWhiteSpace(source))
                source = fullName;

            string sanitized = SanitizeUsername(source);
            return string.IsNullOrWhiteSpace(sanitized) ? "google.user" : sanitized;
        }

        public static string BuildCandidateUsername(string email, string fullName, int suffix)
        {
            string baseUsername = BuildBaseUsername(email, fullName);
            if (suffix <= 0)
                return baseUsername;

            string suffixText = "." + suffix;
            int maxBaseLength = Math.Max(1, 50 - suffixText.Length);
            if (baseUsername.Length > maxBaseLength)
                baseUsername = baseUsername.Substring(0, maxBaseLength).Trim('.');

            return baseUsername + suffixText;
        }

        private static string SanitizeUsername(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
                return null;

            StringBuilder builder = new StringBuilder();
            bool lastWasDot = false;

            foreach (char c in value.Trim().ToLowerInvariant())
            {
                if (char.IsLetterOrDigit(c) || c == '_' || c == '-')
                {
                    builder.Append(c);
                    lastWasDot = false;
                }
                else if (!lastWasDot)
                {
                    builder.Append('.');
                    lastWasDot = true;
                }
            }

            string username = builder.ToString().Trim('.');
            if (username.Length > 50)
                username = username.Substring(0, 50).Trim('.');

            if (username.Length < 3)
                username = (username + ".user").Trim('.');

            return new string(username.Take(50).ToArray());
        }
    }
}
