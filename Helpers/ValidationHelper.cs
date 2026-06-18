using System;
using System.Text.RegularExpressions;

namespace ONYX_DDAC.Helpers
{
    public static class ValidationHelper
    {
        private static readonly Regex EmailPattern = new Regex(@"^[^@\s]+@[^@\s]+\.[^@\s]+$", RegexOptions.Compiled);
        private static readonly Regex UsernamePattern = new Regex(@"^[A-Za-z0-9._-]+$", RegexOptions.Compiled);
        private static readonly Regex PhonePattern = new Regex(@"^[0-9+()\-\s]*$", RegexOptions.Compiled);

        public static bool IsValidEmail(string email)
        {
            return !string.IsNullOrWhiteSpace(email) &&
                   email.Length <= 255 &&
                   EmailPattern.IsMatch(email);
        }

        public static bool IsValidUsername(string username)
        {
            return !string.IsNullOrWhiteSpace(username) &&
                   username.Length >= 3 &&
                   username.Length <= 50 &&
                   UsernamePattern.IsMatch(username);
        }

        public static bool IsValidPhoneNumber(string phoneNumber)
        {
            return string.IsNullOrWhiteSpace(phoneNumber) ||
                   (phoneNumber.Length <= 30 && PhonePattern.IsMatch(phoneNumber));
        }

        public static string GetPasswordValidationError(string password)
        {
            if (string.IsNullOrEmpty(password) || password.Length < 8)
                return "Password must be at least 8 characters.";

            if (password.Length > 128)
                return "Password must not exceed 128 characters.";

            if (!string.Equals(password, password.Trim(), StringComparison.Ordinal))
                return "Password cannot start or end with whitespace.";

            if (!Regex.IsMatch(password, "[A-Z]"))
                return "Password must include an uppercase letter.";

            if (!Regex.IsMatch(password, "[a-z]"))
                return "Password must include a lowercase letter.";

            if (!Regex.IsMatch(password, "[0-9]"))
                return "Password must include a number.";

            if (!Regex.IsMatch(password, @"[^A-Za-z0-9\s]"))
                return "Password must include a symbol.";

            return null;
        }

        public static bool IsValidRegistrationDob(DateTime dob, DateTime today)
        {
            DateTime date = dob.Date;
            DateTime currentDate = today.Date;
            return date <= currentDate.AddYears(-13) &&
                   date >= currentDate.AddYears(-120);
        }

        public static string NormalizeIdentifier(string value)
        {
            return (value ?? string.Empty).Trim().ToLowerInvariant();
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
