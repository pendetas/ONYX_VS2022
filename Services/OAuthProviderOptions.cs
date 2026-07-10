namespace ONYX_DDAC.Services
{
    public class OAuthProviderOptions
    {
        public string Provider { get; set; }
        public string DisplayName { get; set; }
        public string AuthorizationEndpoint { get; set; }
        public string TokenEndpoint { get; set; }
        public string UserInfoEndpoint { get; set; }
        public string Scope { get; set; }
        public string ClientIdSettingKey { get; set; }
        public string ClientSecretSettingKey { get; set; }
        public string ClientIdEnvironmentKey { get; set; }
        public string ClientSecretEnvironmentKey { get; set; }
        public bool RequiresPkce { get; set; }
        public bool UsesBasicTokenAuthorization { get; set; }
    }
}
