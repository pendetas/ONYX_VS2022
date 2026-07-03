using System;
using System.Collections.Generic;
using System.Configuration;
using System.Net.Http;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace ONYX_DDAC.Services
{
    public class CaptchaService
    {
        private const string VerificationUrl = "https://challenges.cloudflare.com/turnstile/v0/siteverify";
        private static readonly HttpClient HttpClient = new HttpClient
        {
            Timeout = TimeSpan.FromSeconds(10)
        };

        public async Task<bool> VerifyCaptchaAsync(string captchaToken, string remoteIp)
        {
            if (string.IsNullOrWhiteSpace(captchaToken))
                return false;

            string secret = GetSetting("TurnstileSecretKey", "TURNSTILE_SECRET_KEY");
            if (IsMissingSetting(secret))
                return false;

            var values = new Dictionary<string, string>
            {
                { "secret", secret },
                { "response", captchaToken }
            };

            if (!string.IsNullOrWhiteSpace(remoteIp))
                values.Add("remoteip", remoteIp);

            try
            {
                using (FormUrlEncodedContent content = new FormUrlEncodedContent(values))
                using (HttpResponseMessage response = await HttpClient.PostAsync(VerificationUrl, content))
                {
                    if (!response.IsSuccessStatusCode)
                        return false;

                    string json = await response.Content.ReadAsStringAsync();
                    JObject payload = JObject.Parse(json);
                    return payload.Value<bool?>("success") == true;
                }
            }
            catch (Exception exception)
            {
                System.Diagnostics.Trace.TraceWarning(
                    "Turnstile verification failed: " + exception.GetType().Name);
                return false;
            }
        }

        public static string GetSiteKey()
        {
            return GetSetting("TurnstileSiteKey", "TURNSTILE_SITE_KEY") ?? string.Empty;
        }

        private static string GetSetting(string appSettingKey, string environmentKey)
        {
            string value = Environment.GetEnvironmentVariable(environmentKey) ??
                           Environment.GetEnvironmentVariable(environmentKey, EnvironmentVariableTarget.User);

            if (!IsMissingSetting(value))
                return value.Trim();

            value = ConfigurationManager.AppSettings[appSettingKey];
            return IsMissingSetting(value) ? null : value.Trim();
        }

        private static bool IsMissingSetting(string value)
        {
            return string.IsNullOrWhiteSpace(value) ||
                   value.IndexOf("REPLACE_", StringComparison.OrdinalIgnoreCase) >= 0;
        }
    }
}
