using System;
using System.Reflection;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.Services
{
    public class AuthService
    {
        private readonly UserRepository userRepository;

        public AuthService()
            : this(new UserRepository())
        {
        }

        public AuthService(UserRepository userRepository)
        {
            this.userRepository = userRepository;
        }

        public LoginResult Login(string email, string password)
        {
            User user = userRepository.FindByEmail(email);

            if (user == null || !VerifyBcryptPassword(password, user.PasswordHash))
            {
                return LoginResult.Failed("Invalid email or password.");
            }

            return LoginResult.Success(user);
        }

        private static bool VerifyBcryptPassword(string password, string passwordHash)
        {
            Type bcryptType = Type.GetType("BCrypt.Net.BCrypt, BCrypt.Net-Next");

            if (bcryptType == null)
            {
                throw new InvalidOperationException("BCrypt.Net-Next is required before password login can be verified.");
            }

            MethodInfo verifyMethod = bcryptType.GetMethod("Verify", new[] { typeof(string), typeof(string) });

            if (verifyMethod == null)
            {
                throw new InvalidOperationException("BCrypt password verifier was not found.");
            }

            return (bool)verifyMethod.Invoke(null, new object[] { password, passwordHash });
        }
    }

    public class LoginResult
    {
        private LoginResult(bool succeeded, string message, User user)
        {
            Succeeded = succeeded;
            Message = message;
            User = user;
        }

        public bool Succeeded { get; private set; }
        public string Message { get; private set; }
        public User User { get; private set; }

        public static LoginResult Success(User user)
        {
            return new LoginResult(true, string.Empty, user);
        }

        public static LoginResult Failed(string message)
        {
            return new LoginResult(false, message, null);
        }
    }
}
