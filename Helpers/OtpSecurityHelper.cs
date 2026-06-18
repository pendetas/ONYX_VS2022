using System;
using System.Security.Cryptography;
using System.Text;

namespace ONYX_DDAC.Helpers
{
    public static class OtpSecurityHelper
    {
        private const int OtpRange = 1000000;
        private const ulong UInt32Range = 4294967296UL;
        private static readonly ulong RejectionLimit = UInt32Range - (UInt32Range % OtpRange);

        public static string GenerateOtp()
        {
            byte[] bytes = new byte[4];

            using (RandomNumberGenerator random = RandomNumberGenerator.Create())
            {
                uint value;
                do
                {
                    random.GetBytes(bytes);
                    value = BitConverter.ToUInt32(bytes, 0);
                }
                while (value >= RejectionLimit);

                return (value % OtpRange).ToString("D6");
            }
        }

        public static string HashOtp(string email, string otp, string secret)
        {
            if (string.IsNullOrWhiteSpace(secret) || secret.Length < 32)
                throw new InvalidOperationException("OtpHmacSecret must contain at least 32 characters.");

            string normalizedEmail = ValidationHelper.NormalizeIdentifier(email);
            byte[] key = Encoding.UTF8.GetBytes(secret);
            byte[] payload = Encoding.UTF8.GetBytes(normalizedEmail + ":" + otp);

            using (HMACSHA256 hmac = new HMACSHA256(key))
            {
                return Convert.ToBase64String(hmac.ComputeHash(payload));
            }
        }

        public static bool VerifyOtp(string email, string otp, string expectedHash, string secret)
        {
            if (string.IsNullOrWhiteSpace(expectedHash))
                return false;

            byte[] expected;
            byte[] actual;

            try
            {
                expected = Convert.FromBase64String(expectedHash);
                actual = Convert.FromBase64String(HashOtp(email, otp, secret));
            }
            catch (FormatException)
            {
                return false;
            }

            if (expected.Length != actual.Length)
                return false;

            int difference = 0;
            for (int i = 0; i < expected.Length; i++)
                difference |= expected[i] ^ actual[i];

            return difference == 0;
        }
    }
}
