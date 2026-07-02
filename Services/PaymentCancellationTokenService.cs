using System;
using System.Security.Cryptography;

namespace ONYX_DDAC.Services
{
    public static class PaymentCancellationTokenService
    {
        public static string GenerateToken()
        {
            byte[] bytes = new byte[32];
            using (RandomNumberGenerator random = RandomNumberGenerator.Create())
            {
                random.GetBytes(bytes);
            }

            return Convert.ToBase64String(bytes)
                .TrimEnd('=')
                .Replace('+', '-')
                .Replace('/', '_');
        }

        public static string HashToken(string token)
        {
            if (string.IsNullOrWhiteSpace(token))
            {
                return null;
            }

            using (SHA256 sha256 = SHA256.Create())
            {
                return Convert.ToBase64String(
                    sha256.ComputeHash(System.Text.Encoding.UTF8.GetBytes(token)));
            }
        }

        public static bool Matches(string token, string expectedHash)
        {
            string actualHash = HashToken(token);
            if (string.IsNullOrEmpty(actualHash) || string.IsNullOrEmpty(expectedHash))
            {
                return false;
            }

            byte[] actual = Convert.FromBase64String(actualHash);
            byte[] expected;
            try
            {
                expected = Convert.FromBase64String(expectedHash);
            }
            catch (FormatException)
            {
                return false;
            }

            if (actual.Length != expected.Length)
            {
                return false;
            }

            int difference = 0;
            for (int index = 0; index < actual.Length; index++)
            {
                difference |= actual[index] ^ expected[index];
            }

            return difference == 0;
        }
    }
}
