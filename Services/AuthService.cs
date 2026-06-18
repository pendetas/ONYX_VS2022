using System;
using System.Configuration;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using BCrypt.Net;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Helpers;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.Services
{
    public class AuthService
    {
        private const string GenericLoginFailure = "Invalid email or password.";
        private const string GenericOtpFailure = "The verification code is invalid or expired.";
        private static readonly string DummyPasswordHash =
            BCrypt.Net.BCrypt.EnhancedHashPassword("ONYX-DUMMY-" + Guid.NewGuid().ToString("N"), 12);

        private readonly UserRepository _userRepository;
        private readonly PendingRegistrationRepository _pendingRepository;
        private readonly AuthRateLimitRepository _rateLimitRepository;
        private readonly CaptchaService _captchaService;
        private readonly EmailService _emailService;

        public AuthService()
            : this(
                new UserRepository(),
                new PendingRegistrationRepository(),
                new AuthRateLimitRepository(),
                new CaptchaService(),
                new EmailService())
        {
        }

        public AuthService(
            UserRepository userRepository,
            PendingRegistrationRepository pendingRepository,
            AuthRateLimitRepository rateLimitRepository,
            CaptchaService captchaService,
            EmailService emailService)
        {
            _userRepository = userRepository;
            _pendingRepository = pendingRepository;
            _rateLimitRepository = rateLimitRepository;
            _captchaService = captchaService;
            _emailService = emailService;
        }

        public async Task<string> StartRegistrationAsync(
            RegistrationRequest request,
            string captchaToken,
            string remoteIp)
        {
            string validationError = ValidateRegistration(request);
            if (validationError != null)
                return validationError;

            NormalizeRegistration(request);
            DateTime nowUtc = DateTime.UtcNow;

            if (!ConsumeLimit(
                    "registration_email",
                    request.Email,
                    5,
                    TimeSpan.FromHours(1),
                    TimeSpan.FromHours(1),
                    nowUtc) ||
                !ConsumeLimit(
                    "registration_ip",
                    NormalizeIp(remoteIp),
                    20,
                    TimeSpan.FromHours(1),
                    TimeSpan.FromHours(1),
                    nowUtc))
            {
                return "Too many registration attempts. Please wait and try again.";
            }

            if (!await _captchaService.VerifyCaptchaAsync(captchaToken, remoteIp))
                return "Security verification failed. Please try again.";

            try
            {
                _pendingRepository.DeleteExpired(nowUtc);

                string duplicate = _userRepository.CheckDuplicate(request.Username, request.Email);
                string pendingConflict = _pendingRepository.CheckPendingConflict(
                    request.Username,
                    request.Email);

                if (duplicate != null || pendingConflict != null)
                    return "Unable to start registration. Check your details and try again.";

                int expiryMinutes = GetIntSetting("OtpExpiryMinutes", 10, 5, 30);
                string otp = OtpSecurityHelper.GenerateOtp();
                string otpHash = OtpSecurityHelper.HashOtp(
                    request.Email,
                    otp,
                    GetOtpSecret());

                PendingRegistration pending = new PendingRegistration
                {
                    FullName = request.FullName,
                    Username = request.Username,
                    Email = request.Email,
                    PasswordHash = BCrypt.Net.BCrypt.EnhancedHashPassword(request.Password, 12),
                    Address = NullIfWhiteSpace(request.Address),
                    Dob = request.Dob.Date,
                    PhoneNumber = NullIfWhiteSpace(request.PhoneNumber),
                    OtpHash = otpHash,
                    OtpExpiresAt = nowUtc.AddMinutes(expiryMinutes),
                    LastOtpSentAt = nowUtc,
                    CreatedAt = nowUtc
                };

                _pendingRepository.ReplaceByEmail(pending);

                try
                {
                    await _emailService.SendRegistrationOtpAsync(
                        request.Email,
                        otp,
                        expiryMinutes);
                }
                catch (Exception exception)
                {
                    PendingRegistration stored = _pendingRepository.GetByEmail(request.Email);
                    if (stored != null)
                        _pendingRepository.Delete(stored.Id);

                    System.Diagnostics.Trace.TraceError(
                        "Registration OTP email failed: " + exception.GetType().Name);
                    return "We could not send the verification code. Please try again.";
                }

                return null;
            }
            catch (Exception exception)
            {
                System.Diagnostics.Trace.TraceError(
                    "Registration start failed: " + exception.GetType().Name);
                return "Unable to start registration. Please try again.";
            }
        }

        public string VerifyRegistrationOtp(string email, string otp, string remoteIp)
        {
            string normalizedEmail = ValidationHelper.NormalizeIdentifier(email);
            if (!ValidationHelper.IsValidEmail(normalizedEmail) ||
                !Regex.IsMatch(otp ?? string.Empty, @"^\d{6}$"))
            {
                return GenericOtpFailure;
            }

            DateTime nowUtc = DateTime.UtcNow;
            int maxAttempts = GetIntSetting("OtpMaxAttempts", 5, 1, 10);

            if (!ConsumeLimit(
                    "otp_verify_email",
                    normalizedEmail,
                    maxAttempts,
                    TimeSpan.FromMinutes(10),
                    TimeSpan.FromMinutes(10),
                    nowUtc) ||
                !ConsumeLimit(
                    "otp_verify_ip",
                    NormalizeIp(remoteIp),
                    20,
                    TimeSpan.FromMinutes(10),
                    TimeSpan.FromMinutes(10),
                    nowUtc))
            {
                return GenericOtpFailure;
            }

            try
            {
                PendingRegistration pending = _pendingRepository.GetByEmail(normalizedEmail);
                if (pending == null)
                    return GenericOtpFailure;

                if (pending.OtpExpiresAt < nowUtc)
                {
                    _pendingRepository.Delete(pending.Id);
                    return GenericOtpFailure;
                }

                if (pending.OtpAttempts >= maxAttempts)
                    return GenericOtpFailure;

                if (!OtpSecurityHelper.VerifyOtp(
                        pending.Email,
                        otp,
                        pending.OtpHash,
                        GetOtpSecret()))
                {
                    _pendingRepository.IncrementOtpAttempts(pending.Id);
                    return GenericOtpFailure;
                }

                bool completed = _pendingRepository.CompleteRegistration(
                    pending.Id,
                    pending.OtpHash,
                    nowUtc,
                    maxAttempts);

                if (!completed)
                    return GenericOtpFailure;

                _rateLimitRepository.Reset("otp_verify_email", normalizedEmail);
                return null;
            }
            catch (Exception exception)
            {
                System.Diagnostics.Trace.TraceError(
                    "Registration OTP verification failed: " + exception.GetType().Name);
                return GenericOtpFailure;
            }
        }

        public async Task<string> ResendRegistrationOtpAsync(
            string email,
            string remoteIp)
        {
            string normalizedEmail = ValidationHelper.NormalizeIdentifier(email);
            if (!ValidationHelper.IsValidEmail(normalizedEmail))
                return "Unable to resend a verification code. Start registration again.";

            DateTime nowUtc = DateTime.UtcNow;
            if (!ConsumeLimit(
                    "otp_resend_email",
                    normalizedEmail,
                    3,
                    TimeSpan.FromHours(1),
                    TimeSpan.FromHours(1),
                    nowUtc) ||
                !ConsumeLimit(
                    "otp_resend_ip",
                    NormalizeIp(remoteIp),
                    10,
                    TimeSpan.FromHours(1),
                    TimeSpan.FromHours(1),
                    nowUtc))
            {
                return "Unable to resend a verification code right now. Please try again later.";
            }

            try
            {
                PendingRegistration pending = _pendingRepository.GetByEmail(normalizedEmail);
                if (pending == null)
                    return "Unable to resend a verification code. Start registration again.";

                int cooldownSeconds = GetIntSetting(
                    "OtpResendCooldownSeconds",
                    60,
                    30,
                    600);
                int maxResends = GetIntSetting("OtpMaxResends", 3, 1, 10);
                int expiryMinutes = GetIntSetting("OtpExpiryMinutes", 10, 5, 30);

                if (pending.ResendCount >= maxResends)
                    return "Unable to resend a verification code right now. Please try again later.";

                if (pending.LastOtpSentAt.AddSeconds(cooldownSeconds) > nowUtc)
                    return "Please wait before requesting another verification code.";

                string otp = OtpSecurityHelper.GenerateOtp();
                string otpHash = OtpSecurityHelper.HashOtp(
                    pending.Email,
                    otp,
                    GetOtpSecret());

                bool updated = _pendingRepository.UpdateOtpForResend(
                    pending.Id,
                    otpHash,
                    nowUtc.AddMinutes(expiryMinutes),
                    nowUtc,
                    nowUtc.AddSeconds(-cooldownSeconds),
                    maxResends);

                if (!updated)
                    return "Unable to resend a verification code right now. Please try again later.";

                await _emailService.SendRegistrationOtpAsync(
                    pending.Email,
                    otp,
                    expiryMinutes);
                return null;
            }
            catch (Exception exception)
            {
                System.Diagnostics.Trace.TraceError(
                    "Registration OTP resend failed: " + exception.GetType().Name);
                return "Unable to resend a verification code right now. Please try again later.";
            }
        }

        public void CancelPendingRegistration(string email)
        {
            string normalizedEmail = ValidationHelper.NormalizeIdentifier(email);
            if (string.IsNullOrEmpty(normalizedEmail))
                return;

            PendingRegistration pending = _pendingRepository.GetByEmail(normalizedEmail);
            if (pending != null)
                _pendingRepository.Delete(pending.Id);
        }

        public User Login(string identifier, string rawPassword, string remoteIp)
        {
            string normalizedIdentifier = ValidationHelper.NormalizeIdentifier(identifier);
            if (string.IsNullOrEmpty(normalizedIdentifier) ||
                string.IsNullOrEmpty(rawPassword) ||
                rawPassword.Length > 128)
            {
                return null;
            }

            DateTime nowUtc = DateTime.UtcNow;
            if (!ConsumeLimit(
                    "login_account",
                    normalizedIdentifier,
                    5,
                    TimeSpan.FromMinutes(15),
                    TimeSpan.FromMinutes(15),
                    nowUtc) ||
                !ConsumeLimit(
                    "login_ip",
                    NormalizeIp(remoteIp),
                    20,
                    TimeSpan.FromMinutes(15),
                    TimeSpan.FromMinutes(15),
                    nowUtc))
            {
                return null;
            }

            try
            {
                User user = _userRepository.GetUserByLoginIdentifier(normalizedIdentifier);
                string hash = user == null ? DummyPasswordHash : user.PasswordHash;
                bool valid = BCrypt.Net.BCrypt.EnhancedVerify(rawPassword, hash);

                if (!valid || user == null)
                    return null;

                _rateLimitRepository.Reset("login_account", normalizedIdentifier);
                return user;
            }
            catch (Exception exception)
            {
                System.Diagnostics.Trace.TraceError(
                    "Login failed: " + exception.GetType().Name);
                return null;
            }
        }

        public string ChangePassword(
            string username,
            string currentRaw,
            string newRaw,
            string confirmRaw)
        {
            if (string.IsNullOrWhiteSpace(currentRaw) ||
                string.IsNullOrWhiteSpace(newRaw) ||
                string.IsNullOrWhiteSpace(confirmRaw))
            {
                return "All fields are required.";
            }

            if (newRaw != confirmRaw)
                return "New password and confirmation do not match.";

            string passwordError = ValidationHelper.GetPasswordValidationError(newRaw);
            if (passwordError != null)
                return passwordError;

            User user = _userRepository.GetUserByUsername(username);
            if (user == null)
                return "Session error. Please log in again.";

            bool currentValid = BCrypt.Net.BCrypt.EnhancedVerify(
                currentRaw,
                user.PasswordHash);
            if (!currentValid)
                return "Current password is incorrect.";

            string newHash = BCrypt.Net.BCrypt.EnhancedHashPassword(newRaw, 12);
            _userRepository.UpdatePasswordHash(user.Id, newHash);
            return null;
        }

        public string RegisterAdmin(
            string fullName,
            string username,
            string email,
            string rawPassword,
            string confirmPassword)
        {
            if (string.IsNullOrWhiteSpace(fullName) ||
                string.IsNullOrWhiteSpace(username) ||
                string.IsNullOrWhiteSpace(email) ||
                string.IsNullOrEmpty(rawPassword) ||
                string.IsNullOrEmpty(confirmPassword))
            {
                return "All fields are required.";
            }

            fullName = fullName.Trim();
            username = username.Trim();
            email = ValidationHelper.NormalizeIdentifier(email);

            if (fullName.Length < 2 || fullName.Length > 100)
                return "Full name must be between 2 and 100 characters.";

            if (!ValidationHelper.IsValidUsername(username))
                return "Username must be 3-50 characters and use letters, numbers, dots, dashes, or underscores.";

            if (!ValidationHelper.IsValidEmail(email))
                return "Please enter a valid email address.";

            if (rawPassword != confirmPassword)
                return "Passwords do not match.";

            string passwordError = ValidationHelper.GetPasswordValidationError(rawPassword);
            if (passwordError != null)
                return passwordError;

            try
            {
                string duplicate = _userRepository.CheckDuplicate(username, email);
                if (duplicate == "username")
                    return "That username is already taken.";
                if (duplicate == "email")
                    return "An account with that email already exists.";

                User user = new User
                {
                    FullName = fullName,
                    Username = username,
                    Email = email,
                    PasswordHash = BCrypt.Net.BCrypt.EnhancedHashPassword(rawPassword, 12),
                    Role = "admin",
                    Dob = null,
                    Address = null,
                    PhoneNumber = null
                };

                return _userRepository.CreateUser(user)
                    ? null
                    : "Registration failed. Please try again.";
            }
            catch (Exception exception)
            {
                System.Diagnostics.Trace.TraceError(
                    "Admin registration failed: " + exception.GetType().Name);
                return "Registration failed. Please try again.";
            }
        }

        public static string LoginFailureMessage
        {
            get { return GenericLoginFailure; }
        }

        private static string ValidateRegistration(RegistrationRequest request)
        {
            if (request == null)
                return "Please fill in all required fields.";

            if (string.IsNullOrWhiteSpace(request.FullName) ||
                string.IsNullOrWhiteSpace(request.Username) ||
                string.IsNullOrWhiteSpace(request.Email) ||
                string.IsNullOrEmpty(request.Password) ||
                string.IsNullOrEmpty(request.ConfirmPassword))
            {
                return "Please fill in all required fields.";
            }

            if (request.FullName.Trim().Length < 2 ||
                request.FullName.Trim().Length > 100)
            {
                return "Full name must be between 2 and 100 characters.";
            }

            if (!ValidationHelper.IsValidUsername(request.Username.Trim()))
                return "Username must be 3-50 characters and use letters, numbers, dots, dashes, or underscores.";

            if (!ValidationHelper.IsValidEmail(request.Email.Trim()))
                return "Please enter a valid email address.";

            if (!ValidationHelper.IsValidPhoneNumber(request.PhoneNumber))
                return "Please enter a valid phone number.";

            if (!string.IsNullOrWhiteSpace(request.Address) &&
                request.Address.Trim().Length > 1000)
            {
                return "Address must not exceed 1000 characters.";
            }

            if (!ValidationHelper.IsValidRegistrationDob(request.Dob, DateTime.Today))
                return "You must be between 13 and 120 years old to register.";

            if (request.Password != request.ConfirmPassword)
                return "Passwords do not match.";

            return ValidationHelper.GetPasswordValidationError(request.Password);
        }

        private static void NormalizeRegistration(RegistrationRequest request)
        {
            request.FullName = request.FullName.Trim();
            request.Username = request.Username.Trim();
            request.Email = ValidationHelper.NormalizeIdentifier(request.Email);
            request.Address = request.Address == null ? null : request.Address.Trim();
            request.PhoneNumber = request.PhoneNumber == null
                ? null
                : request.PhoneNumber.Trim();
        }

        private bool ConsumeLimit(
            string action,
            string identityKey,
            int maxAttempts,
            TimeSpan window,
            TimeSpan blockDuration,
            DateTime nowUtc)
        {
            AuthRateLimitResult result = _rateLimitRepository.ConsumeAttempt(
                action,
                identityKey,
                maxAttempts,
                window,
                blockDuration,
                nowUtc);
            return result.Allowed;
        }

        private static string GetOtpSecret()
        {
            string secret = ConfigurationManager.AppSettings["OtpHmacSecret"];
            if (string.IsNullOrWhiteSpace(secret) ||
                secret.Length < 32 ||
                secret.IndexOf("REPLACE_", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                throw new ConfigurationErrorsException(
                    "OtpHmacSecret must contain at least 32 non-placeholder characters.");
            }

            return secret;
        }

        private static int GetIntSetting(
            string key,
            int defaultValue,
            int minimum,
            int maximum)
        {
            int value;
            if (!int.TryParse(ConfigurationManager.AppSettings[key], out value))
                return defaultValue;

            return Math.Max(minimum, Math.Min(maximum, value));
        }

        private static string NormalizeIp(string remoteIp)
        {
            string value = (remoteIp ?? string.Empty).Trim();
            return string.IsNullOrEmpty(value) ? "unknown" : value;
        }

        private static string NullIfWhiteSpace(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? null : value.Trim();
        }
    }
}
