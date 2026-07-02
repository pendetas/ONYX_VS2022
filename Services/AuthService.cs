using System;
using BCrypt.Net;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.Services
{
    public class AuthService
    {
        private readonly UserRepository _userRepository;

        public AuthService()
        {
            _userRepository = new UserRepository();
        }

        // Returns null on success, or an error message string on failure
        public string Register(string fullName, string username, string email, string rawPassword, DateTime dob, string address, string phoneNumber)
        {
            if (rawPassword == null || rawPassword.Length < 8)
                return "Password must be at least 8 characters.";

            try
            {
                // 1. Pre-check for duplicate username / email before attempting INSERT
                string duplicate = _userRepository.CheckDuplicate(username, email);
                if (duplicate == "username")
                    return "That username is already taken. Please choose another.";
                if (duplicate == "email")
                    return "An account with that email already exists. Try signing in instead.";

                // 2. Hash the password using BCrypt with a work factor of 12 for strong security
                string hashedPassword = BCrypt.Net.BCrypt.EnhancedHashPassword(rawPassword, 12);

                // 3. Create the user model
                User newUser = new User
                {
                    FullName = fullName,
                    Username = username,
                    Email = email,
                    PasswordHash = hashedPassword,
                    Dob = dob,
                    Address = address,
                    PhoneNumber = phoneNumber,
                    Role = "customer"
                };

                // 4. Persist to PostgreSQL
                bool created = _userRepository.CreateUser(newUser);
                return created ? null : "Registration failed due to a server error. Please try again.";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Registration Error: " + ex.Message);
                return "Registration failed due to a server error. Please try again.";
            }
        }

        // Returns null on success, or an error string on failure.
        // Verifies current password, then updates to new hash.
        public string ChangePassword(string username, string currentRaw, string newRaw, string confirmRaw)
        {
            if (string.IsNullOrWhiteSpace(currentRaw) || string.IsNullOrWhiteSpace(newRaw) || string.IsNullOrWhiteSpace(confirmRaw))
                return "All fields are required.";

            if (newRaw != confirmRaw)
                return "New password and confirmation do not match.";

            if (newRaw.Length < 8)
                return "New password must be at least 8 characters.";

            User user = _userRepository.GetUserByUsername(username);
            if (user == null)
                return "Session error. Please log in again.";

            bool currentValid = BCrypt.Net.BCrypt.EnhancedVerify(currentRaw, user.PasswordHash);
            if (!currentValid)
                return "Current password is incorrect.";

            string newHash = BCrypt.Net.BCrypt.EnhancedHashPassword(newRaw, 12);
            _userRepository.UpdatePasswordHash(user.Id, newHash);
            return null;
        }

        // Handles the business logic for logging in
        public User Login(string emailOrUsername, string rawPassword)
        {
            // 1. Fetch the user from the database
            User user = _userRepository.GetUserByEmailOrUsername(emailOrUsername);

            // 2. If user exists, verify the password against the stored BCrypt hash
            if (user != null)
            {
                bool isPasswordValid = VerifyPassword(rawPassword, user.PasswordHash);

                if (isPasswordValid)
                {
                    return user; // Login successful!
                }
            }

            // Login failed (either account not found or password incorrect)
            return null;
        }

        private static bool VerifyPassword(string rawPassword, string passwordHash)
        {
            if (string.IsNullOrWhiteSpace(rawPassword) || string.IsNullOrWhiteSpace(passwordHash))
            {
                return false;
            }

            if (TryVerify(() => BCrypt.Net.BCrypt.EnhancedVerify(rawPassword, passwordHash)))
            {
                return true;
            }

            return TryVerify(() => BCrypt.Net.BCrypt.Verify(rawPassword, passwordHash));
        }

        private static bool TryVerify(Func<bool> verifier)
        {
            try
            {
                return verifier();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Password verification skipped: " + ex.Message);
                return false;
            }
        }
    }
}
