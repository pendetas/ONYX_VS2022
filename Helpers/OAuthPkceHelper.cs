using System;
using System.Security.Cryptography;
using System.Text;

namespace ONYX_DDAC.Helpers
{
    public static class OAuthPkceHelper
    {
        public static string CreateVerifier()
        {
            byte[] bytes = new byte[32];
            using (RandomNumberGenerator rng = RandomNumberGenerator.Create())
                rng.GetBytes(bytes);

            return Base64UrlEncode(bytes);
        }

        public static string CreateChallenge(string verifier)
        {
            if (string.IsNullOrWhiteSpace(verifier))
                throw new InvalidOperationException("PKCE verifier is required.");

            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = Encoding.ASCII.GetBytes(verifier);
                return Base64UrlEncode(sha256.ComputeHash(bytes));
            }
        }

        private static string Base64UrlEncode(byte[] bytes)
        {
            return Convert.ToBase64String(bytes)
                .TrimEnd('=')
                .Replace('+', '-')
                .Replace('/', '_');
        }
    }
}
