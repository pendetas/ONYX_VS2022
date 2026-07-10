using System;
using System.Collections.Generic;
using System.Configuration;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using ONYX_DDAC.Helpers;
using Newtonsoft.Json.Linq;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.Services
{
    public class OAuthService
    {
        private static readonly HttpClient Http = new HttpClient();

        public string BuildAuthorizationUrl(
            string provider,
            string redirectUri,
            string state,
            string codeChallenge = null)
        {
            OAuthProviderOptions options = OAuthProviderRegistry.GetRequired(provider);
            string clientId = GetRequiredSetting(
                options.ClientIdSettingKey,
                options.ClientIdEnvironmentKey);

            if (options.RequiresPkce && string.IsNullOrWhiteSpace(codeChallenge))
                throw new InvalidOperationException(options.DisplayName + " requires a PKCE code challenge.");

            string url = options.AuthorizationEndpoint +
                   "?client_id=" + Uri.EscapeDataString(clientId) +
                   "&redirect_uri=" + Uri.EscapeDataString(redirectUri) +
                   "&response_type=code" +
                   "&scope=" + Uri.EscapeDataString(options.Scope) +
                   "&state=" + Uri.EscapeDataString(state);

            if (options.RequiresPkce)
            {
                url += "&code_challenge=" + Uri.EscapeDataString(codeChallenge) +
                       "&code_challenge_method=S256";
            }

            return url;
        }

        public async Task<OAuthProfile> ExchangeCodeForProfileAsync(
            string provider,
            string code,
            string redirectUri,
            string codeVerifier = null)
        {
            OAuthProviderOptions options = OAuthProviderRegistry.GetRequired(provider);

            if (string.IsNullOrWhiteSpace(code))
                throw new InvalidOperationException(options.DisplayName + " authorization code is missing.");

            if (string.Equals(options.Provider, "google", StringComparison.OrdinalIgnoreCase))
                return await ExchangeGoogleCodeAsync(options, code, redirectUri);

            if (string.Equals(options.Provider, "discord", StringComparison.OrdinalIgnoreCase))
                return await ExchangeDiscordCodeAsync(options, code, redirectUri);

            if (string.Equals(options.Provider, "facebook", StringComparison.OrdinalIgnoreCase))
                return await ExchangeFacebookCodeAsync(options, code, redirectUri);

            if (string.Equals(options.Provider, "x", StringComparison.OrdinalIgnoreCase))
                return await ExchangeXCodeAsync(options, code, redirectUri, codeVerifier);

            throw new InvalidOperationException("Unsupported OAuth provider: " + provider);
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

        private static async Task<OAuthProfile> ExchangeGoogleCodeAsync(
            OAuthProviderOptions options,
            string code,
            string redirectUri)
        {
            string clientId = GetRequiredSetting(options.ClientIdSettingKey, options.ClientIdEnvironmentKey);
            string clientSecret = GetRequiredSetting(options.ClientSecretSettingKey, options.ClientSecretEnvironmentKey);

            var values = new Dictionary<string, string>
            {
                { "code", code },
                { "client_id", clientId },
                { "client_secret", clientSecret },
                { "redirect_uri", redirectUri },
                { "grant_type", "authorization_code" }
            };

            using (var content = new FormUrlEncodedContent(values))
            using (HttpResponseMessage response = await Http.PostAsync(options.TokenEndpoint, content))
            {
                string body = await response.Content.ReadAsStringAsync();
                if (!response.IsSuccessStatusCode)
                    throw new InvalidOperationException("Google token exchange failed.");

                JObject tokenJson = JObject.Parse(body);
                string idToken = (string)tokenJson["id_token"];
                if (string.IsNullOrWhiteSpace(idToken))
                    throw new InvalidOperationException("Google did not return an ID token.");

                return await ValidateGoogleIdTokenAsync(options, idToken, clientId);
            }
        }

        private static async Task<OAuthProfile> ExchangeDiscordCodeAsync(
            OAuthProviderOptions options,
            string code,
            string redirectUri)
        {
            string clientId = GetRequiredSetting(options.ClientIdSettingKey, options.ClientIdEnvironmentKey);
            string clientSecret = GetRequiredSetting(options.ClientSecretSettingKey, options.ClientSecretEnvironmentKey);

            var values = new Dictionary<string, string>
            {
                { "code", code },
                { "client_id", clientId },
                { "client_secret", clientSecret },
                { "redirect_uri", redirectUri },
                { "grant_type", "authorization_code" }
            };

            string accessToken;
            using (var content = new FormUrlEncodedContent(values))
            using (HttpResponseMessage response = await Http.PostAsync(options.TokenEndpoint, content))
            {
                string body = await response.Content.ReadAsStringAsync();
                if (!response.IsSuccessStatusCode)
                    throw new InvalidOperationException("Discord token exchange failed.");

                JObject tokenJson = JObject.Parse(body);
                accessToken = (string)tokenJson["access_token"];
                if (string.IsNullOrWhiteSpace(accessToken))
                    throw new InvalidOperationException("Discord did not return an access token.");
            }

            using (var request = new HttpRequestMessage(HttpMethod.Get, options.UserInfoEndpoint))
            {
                request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
                request.Headers.UserAgent.ParseAdd("ONYX-DDAC/1.0");

                using (HttpResponseMessage response = await Http.SendAsync(request))
                {
                    string body = await response.Content.ReadAsStringAsync();
                    if (!response.IsSuccessStatusCode)
                        throw new InvalidOperationException("Discord profile request failed.");

                    JObject profile = JObject.Parse(body);
                    string subject = (string)profile["id"];
                    string email = (string)profile["email"];
                    bool verified = profile["verified"] != null && profile["verified"].Value<bool>();

                    if (string.IsNullOrWhiteSpace(subject) ||
                        string.IsNullOrWhiteSpace(email) ||
                        !verified)
                    {
                        throw new InvalidOperationException("Discord account email is not verified.");
                    }

                    string fullName = (string)profile["global_name"];
                    if (string.IsNullOrWhiteSpace(fullName))
                        fullName = (string)profile["username"];

                    return new OAuthProfile
                    {
                        Provider = options.Provider,
                        Subject = subject,
                        Email = email,
                        EmailVerified = verified,
                        FullName = fullName,
                        AvatarUrl = BuildDiscordAvatarUrl(profile)
                    };
                }
            }
        }

        private static async Task<OAuthProfile> ExchangeFacebookCodeAsync(
            OAuthProviderOptions options,
            string code,
            string redirectUri)
        {
            string clientId = GetRequiredSetting(options.ClientIdSettingKey, options.ClientIdEnvironmentKey);
            string clientSecret = GetRequiredSetting(options.ClientSecretSettingKey, options.ClientSecretEnvironmentKey);

            string tokenUrl = options.TokenEndpoint +
                "?client_id=" + Uri.EscapeDataString(clientId) +
                "&redirect_uri=" + Uri.EscapeDataString(redirectUri) +
                "&client_secret=" + Uri.EscapeDataString(clientSecret) +
                "&code=" + Uri.EscapeDataString(code);

            string accessToken;
            using (HttpResponseMessage response = await Http.GetAsync(tokenUrl))
            {
                string body = await response.Content.ReadAsStringAsync();
                if (!response.IsSuccessStatusCode)
                    throw new InvalidOperationException("Facebook token exchange failed.");

                JObject tokenJson = JObject.Parse(body);
                accessToken = (string)tokenJson["access_token"];
                if (string.IsNullOrWhiteSpace(accessToken))
                    throw new InvalidOperationException("Facebook did not return an access token.");
            }

            using (var request = new HttpRequestMessage(HttpMethod.Get, options.UserInfoEndpoint))
            {
                request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
                request.Headers.UserAgent.ParseAdd("ONYX-DDAC/1.0");

                using (HttpResponseMessage response = await Http.SendAsync(request))
                {
                    string body = await response.Content.ReadAsStringAsync();
                    if (!response.IsSuccessStatusCode)
                        throw new InvalidOperationException("Facebook profile request failed.");

                    JObject profile = JObject.Parse(body);
                    string subject = (string)profile["id"];
                    string email = (string)profile["email"];
                    string fullName = (string)profile["name"];

                    if (string.IsNullOrWhiteSpace(subject))
                        throw new InvalidOperationException("Facebook profile did not include a user id.");

                    if (string.IsNullOrWhiteSpace(email))
                        throw new InvalidOperationException("Facebook account email is not available.");

                    return new OAuthProfile
                    {
                        Provider = options.Provider,
                        Subject = subject,
                        Email = email,
                        EmailVerified = true,
                        FullName = string.IsNullOrWhiteSpace(fullName) ? email : fullName,
                        AvatarUrl = (string)profile["picture"]?["data"]?["url"]
                    };
                }
            }
        }

        private static async Task<OAuthProfile> ExchangeXCodeAsync(
            OAuthProviderOptions options,
            string code,
            string redirectUri,
            string codeVerifier)
        {
            if (string.IsNullOrWhiteSpace(codeVerifier))
                throw new InvalidOperationException("X sign-in is missing the PKCE verifier.");

            string clientId = GetRequiredSetting(options.ClientIdSettingKey, options.ClientIdEnvironmentKey);
            string clientSecret = GetRequiredSetting(options.ClientSecretSettingKey, options.ClientSecretEnvironmentKey);

            var values = new Dictionary<string, string>
            {
                { "code", code },
                { "client_id", clientId },
                { "redirect_uri", redirectUri },
                { "grant_type", "authorization_code" },
                { "code_verifier", codeVerifier }
            };

            string accessToken;
            using (var request = new HttpRequestMessage(HttpMethod.Post, options.TokenEndpoint))
            using (var content = new FormUrlEncodedContent(values))
            {
                string credentials = Convert.ToBase64String(
                    Encoding.ASCII.GetBytes(clientId + ":" + clientSecret));
                request.Headers.Authorization = new AuthenticationHeaderValue("Basic", credentials);
                request.Content = content;

                using (HttpResponseMessage response = await Http.SendAsync(request))
                {
                    string body = await response.Content.ReadAsStringAsync();
                    if (!response.IsSuccessStatusCode)
                        throw new InvalidOperationException("X token exchange failed.");

                    JObject tokenJson = JObject.Parse(body);
                    accessToken = (string)tokenJson["access_token"];
                    if (string.IsNullOrWhiteSpace(accessToken))
                        throw new InvalidOperationException("X did not return an access token.");
                }
            }

            using (var request = new HttpRequestMessage(HttpMethod.Get, options.UserInfoEndpoint))
            {
                request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
                request.Headers.UserAgent.ParseAdd("ONYX-DDAC/1.0");

                using (HttpResponseMessage response = await Http.SendAsync(request))
                {
                    string body = await response.Content.ReadAsStringAsync();
                    if (!response.IsSuccessStatusCode)
                        throw new InvalidOperationException("X profile request failed.");

                    JObject profile = JObject.Parse(body);
                    JObject data = profile["data"] as JObject;
                    if (data == null)
                        throw new InvalidOperationException("X profile response did not include user data.");

                    string subject = (string)data["id"];
                    string username = (string)data["username"];
                    string name = (string)data["name"];

                    if (string.IsNullOrWhiteSpace(subject))
                        throw new InvalidOperationException("X profile did not include a user id.");

                    return new OAuthProfile
                    {
                        Provider = options.Provider,
                        Subject = subject,
                        Email = "x_" + subject + "@oauth.onyx.local",
                        EmailVerified = true,
                        FullName = string.IsNullOrWhiteSpace(name) ? username : name,
                        AvatarUrl = (string)data["profile_image_url"]
                    };
                }
            }
        }

        private static async Task<OAuthProfile> ValidateGoogleIdTokenAsync(
            OAuthProviderOptions options,
            string idToken,
            string clientId)
        {
            using (HttpResponseMessage response = await Http.GetAsync(
                       options.UserInfoEndpoint + Uri.EscapeDataString(idToken)))
            {
                string body = await response.Content.ReadAsStringAsync();
                if (!response.IsSuccessStatusCode)
                    throw new InvalidOperationException("Google ID token validation failed.");

                JObject claims = JObject.Parse(body);
                string audience = (string)claims["aud"];
                string issuer = (string)claims["iss"];
                string subject = (string)claims["sub"];
                string email = (string)claims["email"];
                bool emailVerified = IsTrue(claims["email_verified"]);

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

                return new OAuthProfile
                {
                    Provider = options.Provider,
                    Subject = subject,
                    Email = email,
                    EmailVerified = emailVerified,
                    FullName = (string)claims["name"],
                    AvatarUrl = (string)claims["picture"]
                };
            }
        }

        private static string BuildDiscordAvatarUrl(JObject profile)
        {
            string id = (string)profile["id"];
            string avatar = (string)profile["avatar"];
            if (string.IsNullOrWhiteSpace(id) || string.IsNullOrWhiteSpace(avatar))
                return null;

            return "https://cdn.discordapp.com/avatars/" +
                   Uri.EscapeDataString(id) +
                   "/" +
                   Uri.EscapeDataString(avatar) +
                   ".png?size=128";
        }

        private static bool IsTrue(JToken value)
        {
            if (value == null)
                return false;

            if (value.Type == JTokenType.Boolean)
                return value.Value<bool>();

            return string.Equals(
                value.Value<string>(),
                "true",
                StringComparison.OrdinalIgnoreCase);
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
