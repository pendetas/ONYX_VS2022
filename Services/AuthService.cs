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
                return "DB Error: " + ex.Message;
            }
        }

        // Handles the business logic for logging in
        public User Login(string email, string rawPassword)
        {
            // 1. Fetch the user from the database
            User user = _userRepository.GetUserByEmail(email);

            // 2. If user exists, verify the password against the stored BCrypt hash
            if (user != null)
            {
                // Fix: Removed named arguments here as well. SHA384 is used by default.
                bool isPasswordValid = BCrypt.Net.BCrypt.EnhancedVerify(rawPassword, user.PasswordHash);

                if (isPasswordValid)
                {
                    return user; // Login successful!
                }
            }

            // Login failed (either username not found or password incorrect)
            return null;
        }
    }
}
