using System;
using System.Configuration;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.Hosting;
using BCrypt.Net;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Helpers;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.Services
{
    public class AuthService
    {
        private readonly UserRepository _userRepository;
        private readonly EmailService _emailService;

        public AuthService()
        {
            _userRepository = new UserRepository();
            _emailService = new EmailService();
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
                if (!created)
                    return "Registration failed due to a server error. Please try again.";

                QueueAccountCreatedNotice(email, fullName, "Email and password");
                return null;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Registration Error: " + ex.Message);
                return "Registration failed due to a server error. Please try again.";
            }
        }

        public User RegisterCustomer(
            string fullName,
            string username,
            string email,
            string rawPassword,
            DateTime dob,
            string address,
            string phoneNumber)
        {
            string error = Register(fullName, username, email, rawPassword, dob, address, phoneNumber);
            if (error != null)
                throw new InvalidOperationException(error);

            User createdUser = _userRepository.GetUserByEmail(email);
            if (createdUser == null)
            {
                throw new InvalidOperationException(
                    "Registration succeeded, but the customer account could not be loaded.");
            }

            return createdUser;
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

        public async Task RequestPasswordResetAsync(
            string email,
            Func<string, string> buildResetUrl)
        {
            if (string.IsNullOrWhiteSpace(email))
                return;

            User user = _userRepository.GetUserByEmail(email.Trim());
            if (user == null || string.IsNullOrWhiteSpace(user.PasswordHash))
            {
                WriteEmailDebugLog(
                    "password_reset_skipped",
                    email,
                    "no manual account",
                    null);
                return;
            }

            string rawToken = CreatePasswordResetToken();
            string tokenHash = HashPasswordResetToken(rawToken);
            int expiryMinutes = GetPasswordResetExpiryMinutes();

            _userRepository.CreatePasswordResetToken(
                user.Id,
                tokenHash,
                expiryMinutes);

            string resetUrl = buildResetUrl == null
                ? rawToken
                : buildResetUrl(rawToken);

            try
            {
                await _emailService.SendPasswordResetAsync(
                    user.Email,
                    user.FullName,
                    resetUrl,
                    expiryMinutes);

                WriteEmailDebugLog(
                    "password_reset_sent",
                    user.Email,
                    "manual account",
                    null);
            }
            catch (Exception exception)
            {
                WriteEmailDebugLog(
                    "password_reset_failed",
                    user.Email,
                    "manual account",
                    exception);
                throw;
            }
        }

        public bool IsPasswordResetTokenValid(string rawToken)
        {
            if (string.IsNullOrWhiteSpace(rawToken))
                return false;

            return _userRepository.GetValidPasswordResetUserId(
                HashPasswordResetToken(rawToken)).HasValue;
        }

        public string ResetPassword(
            string rawToken,
            string newRaw,
            string confirmRaw)
        {
            if (string.IsNullOrWhiteSpace(rawToken) ||
                !_userRepository.GetValidPasswordResetUserId(HashPasswordResetToken(rawToken)).HasValue)
            {
                return "This reset link is invalid or has expired.";
            }

            if (string.IsNullOrWhiteSpace(newRaw) || string.IsNullOrWhiteSpace(confirmRaw))
                return "Enter and confirm your new password.";

            if (newRaw != confirmRaw)
                return "New password and confirmation do not match.";

            if (newRaw.Length < 8)
                return "New password must be at least 8 characters.";

            string newHash = BCrypt.Net.BCrypt.EnhancedHashPassword(newRaw, 12);
            bool updated = _userRepository.ResetPasswordWithToken(
                HashPasswordResetToken(rawToken),
                newHash);

            return updated
                ? null
                : "This reset link is invalid or has expired.";
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

        public User LoginOrCreateGoogleUser(GoogleOAuthProfile profile)
        {
            return LoginOrCreateOAuthUser(profile);
        }

        public User LoginOrCreateOAuthUser(OAuthProfile profile)
        {
            bool created;
            return LoginOrCreateOAuthUser(profile, out created);
        }

        public User LoginOrCreateOAuthUser(OAuthProfile profile, out bool created)
        {
            NormalizeAndValidateOAuthProfile(profile);
            created = false;

            User user = FindAndLinkExistingOAuthUser(profile);
            if (user != null)
                return user;

            string username = BuildUniqueOAuthUsername(profile);
            user = _userRepository.CreateOAuthUser(profile, username);
            if (user == null)
                throw new InvalidOperationException("OAuth account creation failed.");

            created = true;
            _userRepository.TouchLastLogin(user.Id);
            return user;
        }

        public User LoginExistingOAuthUser(OAuthProfile profile)
        {
            NormalizeAndValidateOAuthProfile(profile);
            return FindAndLinkExistingOAuthUser(profile);
        }

        private void NormalizeAndValidateOAuthProfile(OAuthProfile profile)
        {
            if (profile == null ||
                string.IsNullOrWhiteSpace(profile.Provider) ||
                string.IsNullOrWhiteSpace(profile.Subject) ||
                string.IsNullOrWhiteSpace(profile.Email) ||
                !profile.EmailVerified)
            {
                throw new InvalidOperationException("OAuth profile is missing verified identity data.");
            }

            profile.Provider = OAuthProviderRegistry.NormalizeProvider(profile.Provider);
            profile.Email = ValidationHelper.NormalizeIdentifier(profile.Email);
            profile.FullName = string.IsNullOrWhiteSpace(profile.FullName)
                ? profile.Email
                : profile.FullName.Trim();
        }

        private User FindAndLinkExistingOAuthUser(OAuthProfile profile)
        {
            User user = _userRepository.GetUserByOAuthAccount(profile.Provider, profile.Subject);
            if (user != null)
            {
                _userRepository.TouchLastLogin(user.Id);
                return user;
            }

            if (profile.Provider == "google")
            {
                user = _userRepository.GetUserByGoogleSub(profile.Subject);
                if (user != null)
                {
                    _userRepository.LinkOAuthAccount(user.Id, profile);
                    _userRepository.TouchLastLogin(user.Id);
                    return user;
                }
            }

            user = _userRepository.GetUserByEmail(profile.Email);
            if (user != null)
            {
                _userRepository.LinkOAuthAccount(user.Id, profile);
                _userRepository.TouchLastLogin(user.Id);
                return _userRepository.GetUserByOAuthAccount(profile.Provider, profile.Subject) ?? user;
            }

            return null;
        }

        public void QueueAccountCreatedNotice(
            string email,
            string displayName,
            string signInMethod)
        {
            WriteEmailDebugLog(
                "account_created_notice_queued",
                email,
                signInMethod,
                null);

            try
            {
                HostingEnvironment.QueueBackgroundWorkItem(async cancellationToken =>
                {
                    try
                    {
                        if (cancellationToken.IsCancellationRequested)
                        {
                            WriteEmailDebugLog(
                                "account_created_notice_cancelled",
                                email,
                                signInMethod,
                                null);
                            return;
                        }

                        await SendAccountCreatedNoticeAsync(email, displayName, signInMethod);
                    }
                    catch (Exception exception)
                    {
                        WriteEmailDebugLog(
                            "account_created_notice_task_failed",
                            email,
                            signInMethod,
                            exception);
                    }
                });
            }
            catch (Exception exception)
            {
                WriteEmailDebugLog(
                    "account_created_notice_queue_failed",
                    email,
                    signInMethod,
                    exception);

                Task.Run(() => SendAccountCreatedNoticeAsync(email, displayName, signInMethod));
            }
        }

        public async Task SendAccountCreatedNoticeAsync(
            string email,
            string displayName,
            string signInMethod)
        {
            if (string.IsNullOrWhiteSpace(email) ||
                email.EndsWith("@oauth.onyx.local", StringComparison.OrdinalIgnoreCase))
            {
                WriteEmailDebugLog(
                    "account_created_notice_skipped",
                    email,
                    "missing or local-only recipient",
                    null);
                return;
            }

            try
            {
                WriteEmailDebugLog(
                    "account_created_notice_start",
                    email,
                    signInMethod,
                    null);

                await _emailService.SendAccountCreatedAsync(
                    email,
                    displayName,
                    signInMethod);

                WriteEmailDebugLog(
                    "account_created_notice_sent",
                    email,
                    signInMethod,
                    null);
            }
            catch (Exception exception)
            {
                WriteEmailDebugLog(
                    "account_created_notice_failed",
                    email,
                    signInMethod,
                    exception);
                System.Diagnostics.Trace.TraceWarning(
                    "Account-created email failed: " + exception.GetType().Name);
            }
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

        private static string CreatePasswordResetToken()
        {
            byte[] bytes = new byte[32];
            using (RandomNumberGenerator rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(bytes);
            }

            return Convert.ToBase64String(bytes)
                .TrimEnd('=')
                .Replace('+', '-')
                .Replace('/', '_');
        }

        private static string HashPasswordResetToken(string rawToken)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] hash = sha256.ComputeHash(Encoding.UTF8.GetBytes(rawToken ?? string.Empty));
                StringBuilder builder = new StringBuilder(hash.Length * 2);
                for (int i = 0; i < hash.Length; i++)
                    builder.Append(hash[i].ToString("x2"));

                return builder.ToString();
            }
        }

        private static int GetPasswordResetExpiryMinutes()
        {
            int minutes;
            if (!int.TryParse(ConfigurationManager.AppSettings["PasswordResetExpiryMinutes"], out minutes) ||
                minutes < 5 ||
                minutes > 1440)
            {
                return 30;
            }

            return minutes;
        }

        private string BuildUniqueOAuthUsername(OAuthProfile profile)
        {
            for (int i = 0; i < 100; i++)
            {
                string candidate = GoogleOAuthAccountHelper.BuildCandidateUsername(
                    profile.Email,
                    profile.FullName,
                    i);

                if (!_userRepository.UsernameExists(candidate))
                    return candidate;
            }

            return profile.Provider + ".user." + Guid.NewGuid().ToString("N").Substring(0, 12);
        }

        private static void WriteEmailDebugLog(
            string status,
            string recipientEmail,
            string detail,
            Exception exception)
        {
            try
            {
                string basePath = HttpContext.Current == null
                    ? HostingEnvironment.MapPath("~/App_Data") ?? AppDomain.CurrentDomain.BaseDirectory
                    : HttpContext.Current.Server.MapPath("~/App_Data");
                Directory.CreateDirectory(basePath);
                string path = Path.Combine(basePath, "email_debug.log");
                string line =
                    "[" + DateTime.UtcNow.ToString("u") + "] " +
                    status +
                    " to=" + (recipientEmail ?? "none") +
                    " detail=\"" + (detail ?? "") + "\"";

                if (exception != null)
                    line += " error=" + exception.GetType().FullName + ": " + exception.Message;

                File.AppendAllText(path, line + Environment.NewLine);
            }
            catch
            {
                // Email diagnostics must never affect the auth flow.
            }
        }
    }
}
