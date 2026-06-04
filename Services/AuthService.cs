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

        // Handles the business logic for registering a user
        public bool Register(string fullName, string username, string email, string rawPassword, DateTime dob, string address, string phoneNumber)
        {
            try
            {
                // 1. Hash the password using BCrypt with a work factor of 12 for strong security
                string hashedPassword = BCrypt.Net.BCrypt.EnhancedHashPassword(rawPassword, 12);

                // 2. Create the user model (now including all PRD fields)
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

                // 3. Send to the Data Access Layer to save in PostgreSQL
                return _userRepository.CreateUser(newUser);
            }
            catch (Exception ex)
            {
                // In a production app, log this error (e.g., duplicate username violation)
                System.Diagnostics.Debug.WriteLine("Registration Error: " + ex.Message);
                return false;
            }
        }

        // Handles the business logic for logging in
        public User Login(string emailOrUsername, string rawPassword)
        {
            // 1. Fetch the user from the database
            User user = _userRepository.GetUserByEmailOrUsername(emailOrUsername);

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

            // Login failed (either account not found or password incorrect)
            return null;
        }
    }
}
