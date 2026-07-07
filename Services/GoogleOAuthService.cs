using System;
using System.Collections.Generic;
using System.Configuration;
using System.Net.Http;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.Services
{
    public class GoogleOAuthService
    {
        private const string AuthorizationEndpoint = "https://accounts.google.com/o/oauth2/v2/auth";
        private const string TokenEndpoint = "https://oauth2.googleapis.com/token";
        private const string TokenInfoEndpoint = "https://oauth2.googleapis.com/tokeninfo?id_token=";
        private static readonly HttpClient Http = new HttpClient();

        public string BuildAuthorizationUrl(string redirectUri, string state)
        {
            string clientId = GetRequiredSetting("GoogleClientId", "GOOGLE_CLIENT_ID");

            return AuthorizationEndpoint +
                   "?client_id=" + Uri.EscapeDataString(clientId) +
                   "&redirect_uri=" + Uri.EscapeDataString(redirectUri) +
                   "&response_type=code" +
                   "&scope=" + Uri.EscapeDataString("openid email profile") +
                   "&state=" + Uri.EscapeDataString(state);
        }

        public async Task<GoogleOAuthProfile> ExchangeCodeForProfileAsync(
            string code,
            string redirectUri)
        {
            if (string.IsNullOrWhiteSpace(code))
                throw new InvalidOperationException("Missing Google authorization code.");

            string clientId = GetRequiredSetting("GoogleClientId", "GOOGLE_CLIENT_ID");
            string clientSecret = GetRequiredSetting("GoogleClientSecret", "GOOGLE_CLIENT_SECRET");

            var values = new Dictionary<string, string>
            {
                { "code", code },
                { "client_id", clientId },
                { "client_secret", clientSecret },
                { "redirect_uri", redirectUri },
                { "grant_type", "authorization_code" }
            };

            using (var content = new FormUrlEncodedContent(values))
            using (HttpResponseMessage response = await Http.PostAsync(TokenEndpoint, content))
            {
                string body = await response.Content.ReadAsStringAsync();
                if (!response.IsSuccessStatusCode)
                    throw new InvalidOperationException("Google token exchange failed.");

                JObject tokenJson = JObject.Parse(body);
                string idToken = (string)tokenJson["id_token"];
                if (string.IsNullOrWhiteSpace(idToken))
                    throw new InvalidOperationException("Google did not return an ID token.");

                return await ValidateIdTokenAsync(idToken, clientId);
            }
        }

        public static string CreateStateToken()
        {
            byte[] bytes = new byte[32];
            using (RandomNumberGenerator rng = RandomNumberGenerator.Create())
                rng.GetBytes(bytes);

            return Convert.ToBase64String(bytes)
                .TrimEnd('=')
                .Replace('+', '-')
                .Replace('/', '_');
        }

        private static async Task<GoogleOAuthProfile> ValidateIdTokenAsync(
            string idToken,
            string clientId)
        {
            using (HttpResponseMessage response = await Http.GetAsync(
                       TokenInfoEndpoint + Uri.EscapeDataString(idToken)))
            {
                string body = await response.Content.ReadAsStringAsync();
                if (!response.IsSuccessStatusCode)
                    throw new InvalidOperationException("Google ID token validation failed.");

                JObject claims = JObject.Parse(body);
                string audience = (string)claims["aud"];
                string issuer = (string)claims["iss"];
                string subject = (string)claims["sub"];
                string email = (string)claims["email"];
                bool emailVerified = string.Equals(
                    (string)claims["email_verified"],
                    "true",
                    StringComparison.OrdinalIgnoreCase);

                if (!string.Equals(audience, clientId, StringComparison.Ordinal))
                    throw new InvalidOperationException("Google token audience mismatch.");

                if (!string.Equals(issuer, "accounts.google.com", StringComparison.Ordinal) &&
                    !string.Equals(issuer, "https://accounts.google.com", StringComparison.Ordinal))
                {
                    throw new InvalidOperationException("Google token issuer mismatch.");
                }

                if (string.IsNullOrWhiteSpace(subject) ||
                    string.IsNullOrWhiteSpace(email) ||
                    !emailVerified)
                {
                    throw new InvalidOperationException("Google account email is not verified.");
                }

                return new GoogleOAuthProfile
                {
                    Subject = subject,
                    Email = email,
                    EmailVerified = emailVerified,
                    FullName = (string)claims["name"],
                    AvatarUrl = (string)claims["picture"]
                };
            }
        }

        private static string GetRequiredSetting(string appSettingKey, string environmentKey)
        {
            string value = ConfigurationManager.AppSettings[appSettingKey];
            if (string.IsNullOrWhiteSpace(value) ||
                value.StartsWith("REPLACE_", StringComparison.OrdinalIgnoreCase))
            {
                value = Environment.GetEnvironmentVariable(environmentKey);
            }

            if (string.IsNullOrWhiteSpace(value) ||
                value.StartsWith("REPLACE_", StringComparison.OrdinalIgnoreCase))
            {
                throw new ConfigurationErrorsException(
                    appSettingKey + " is missing. Configure Web.config or environment variable " + environmentKey + ".");
            }

            return value.Trim();
        }
    }
}
