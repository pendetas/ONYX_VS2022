using System;
using System.Text.RegularExpressions;

namespace ONYX_DDAC.Helpers
{
    public static class ValidationHelper
    {
        private static readonly Regex EmailPattern = new Regex(@"^[^@\s]+@[^@\s]+\.[^@\s]+$", RegexOptions.Compiled);

        public static bool IsValidEmail(string email)
        {
            return !string.IsNullOrWhiteSpace(email) && EmailPattern.IsMatch(email);
        }

        public static string NormalizeIdentifier(string value)
        {
            return string.IsNullOrWhiteSpace(value)
                ? null
                : value.Trim().ToLowerInvariant();
        }

        public static bool IsValidPositiveQuantity(int quantity)
        {
            return quantity > 0 && quantity <= 99;
        }

        public static bool IsValidPrice(decimal price)
        {
            return price >= 0m;
        }
    }
}
