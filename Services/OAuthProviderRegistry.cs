using System;
using System.Collections.Generic;

namespace ONYX_DDAC.Services
{
    public static class OAuthProviderRegistry
    {
        private static readonly IDictionary<string, OAuthProviderOptions> Providers =
            new Dictionary<string, OAuthProviderOptions>(StringComparer.OrdinalIgnoreCase)
            {
                {
                    "google",
                    new OAuthProviderOptions
                    {
                        Provider = "google",
                        DisplayName = "Google",
                        AuthorizationEndpoint = "https://accounts.google.com/o/oauth2/v2/auth",
                        TokenEndpoint = "https://oauth2.googleapis.com/token",
                        UserInfoEndpoint = "https://oauth2.googleapis.com/tokeninfo?id_token=",
                        Scope = "openid email profile",
                        ClientIdSettingKey = "GoogleClientId",
                        ClientSecretSettingKey = "GoogleClientSecret",
                        ClientIdEnvironmentKey = "GOOGLE_CLIENT_ID",
                        ClientSecretEnvironmentKey = "GOOGLE_CLIENT_SECRET"
                    }
                },
                {
                    "discord",
                    new OAuthProviderOptions
                    {
                        Provider = "discord",
                        DisplayName = "Discord",
                        AuthorizationEndpoint = "https://discord.com/oauth2/authorize",
                        TokenEndpoint = "https://discord.com/api/v10/oauth2/token",
                        UserInfoEndpoint = "https://discord.com/api/v10/users/@me",
                        Scope = "identify email",
                        ClientIdSettingKey = "DiscordClientId",
                        ClientSecretSettingKey = "DiscordClientSecret",
                        ClientIdEnvironmentKey = "DISCORD_CLIENT_ID",
                        ClientSecretEnvironmentKey = "DISCORD_CLIENT_SECRET"
                    }
                },
                {
                    "x",
                    new OAuthProviderOptions
                    {
                        Provider = "x",
                        DisplayName = "X",
                        AuthorizationEndpoint = "https://x.com/i/oauth2/authorize",
                        TokenEndpoint = "https://api.x.com/2/oauth2/token",
                        UserInfoEndpoint = "https://api.x.com/2/users/me?user.fields=profile_image_url",
                        Scope = "tweet.read users.read",
                        ClientIdSettingKey = "XClientId",
                        ClientSecretSettingKey = "XClientSecret",
                        ClientIdEnvironmentKey = "X_CLIENT_ID",
                        ClientSecretEnvironmentKey = "X_CLIENT_SECRET",
                        RequiresPkce = true,
                        UsesBasicTokenAuthorization = true
                    }
                }
            };

        public static OAuthProviderOptions GetRequired(string provider)
        {
            string normalized = NormalizeProvider(provider);
            OAuthProviderOptions options;
            if (!Providers.TryGetValue(normalized, out options))
                throw new InvalidOperationException("Unsupported OAuth provider: " + provider);

            return options;
        }

        public static string NormalizeProvider(string provider)
        {
            if (string.IsNullOrWhiteSpace(provider))
                throw new InvalidOperationException("OAuth provider is required.");

            return provider.Trim().ToLowerInvariant();
        }

        public static string GetStateSessionKey(string provider)
        {
            return "OAuthState:" + NormalizeProvider(provider);
        }

        public static string GetStateProviderSessionKey(string state)
        {
            return "OAuthStateProvider:" + state;
        }

        public static string GetCodeVerifierSessionKey(string provider, string state)
        {
            return "OAuthCodeVerifier:" + NormalizeProvider(provider) + ":" + state;
        }
    }
}
