using System;
using System.Linq;
using System.Web;
using Npgsql;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.Services
{
    public class ProfileService
    {
        private readonly UserRepository userRepository;

        public ProfileService()
        {
            userRepository = new UserRepository();
        }

        public User GetUserProfile(long userId)
        {
            try
            {
                return userRepository.GetUserById(userId) ?? GetSessionFallbackUser();
            }
            catch
            {
                return GetSessionFallbackUser();
            }
        }

        public ProfileUpdateResult UpdateUserSettings(
            long userId,
            string firstName,
            string lastName,
            string email,
            string phoneNumber,
            string address)
        {
            string normalizedFirstName = NormalizeOptionalValue(firstName);
            string normalizedLastName = NormalizeOptionalValue(lastName);
            string fullName = NormalizeOptionalValue(string.Join(" ", new[] { normalizedFirstName, normalizedLastName }
                .Where(value => !string.IsNullOrWhiteSpace(value))));
            string normalizedEmail = (email ?? string.Empty).Trim();
            string normalizedPhoneNumber = NormalizeOptionalValue(phoneNumber);
            string normalizedAddress = NormalizeOptionalValue(address);

            if (string.IsNullOrWhiteSpace(fullName))
            {
                return Failure("Full name is required.");
            }

            if (string.IsNullOrWhiteSpace(normalizedEmail) || !LooksLikeEmail(normalizedEmail))
            {
                return Failure("Enter a valid email address.");
            }

            if (normalizedAddress != null && normalizedAddress.Length > 500)
            {
                return Failure("Keep the address under 500 characters.");
            }

            try
            {
                if (!userRepository.UpdateUserSettings(userId, fullName, normalizedEmail, normalizedPhoneNumber, normalizedAddress))
                {
                    return Failure("Settings could not be saved.");
                }

                return new ProfileUpdateResult
                {
                    Success = true,
                    Message = "Settings saved.",
                    User = userRepository.GetUserById(userId)
                };
            }
            catch (PostgresException ex) when (ex.SqlState == "23505")
            {
                return Failure("That email is already used by another account.");
            }
        }

        private static ProfileUpdateResult Failure(string message)
        {
            return new ProfileUpdateResult
            {
                Success = false,
                Message = message
            };
        }

        private static string NormalizeOptionalValue(string value)
        {
            string normalized = (value ?? string.Empty).Trim();
            return normalized.Length == 0 ? null : normalized;
        }

        private static bool LooksLikeEmail(string email)
        {
            int atIndex = email.IndexOf('@');
            return atIndex > 0 && atIndex < email.Length - 1 && email.IndexOf('.', atIndex) > atIndex + 1;
        }

        private static User GetSessionFallbackUser()
        {
            HttpContext context = HttpContext.Current;
            object username = context == null ? null : context.Session["Username"];

            return new User
            {
                Username = username == null ? "onyx-user" : username.ToString(),
                CreatedAt = DateTime.MinValue
            };
        }
    }
}
