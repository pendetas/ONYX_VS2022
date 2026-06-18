using System;
using System.Linq;
using ONYX_DDAC.Helpers;

internal static class SecurityTests
{
    private static int _passed;

    private static void Main()
    {
        Run("OTP is always six numeric digits", OtpIsSixNumericDigits);
        Run("OTP HMAC is bound to normalized email", OtpHashIsEmailBound);
        Run("OTP HMAC verification rejects a different code", OtpVerificationRejectsWrongCode);
        Run("Password policy accepts all required character classes", PasswordPolicyAcceptsStrongPassword);
        Run("Password policy rejects missing symbol", PasswordPolicyRejectsMissingSymbol);
        Run("DOB policy accepts ages from 13 through 120", DobPolicyEnforcesBounds);
        Run("Login identifiers are normalized consistently", IdentifierNormalizationIsStable);

        Console.WriteLine("Security tests passed: " + _passed);
    }

    private static void OtpIsSixNumericDigits()
    {
        for (int i = 0; i < 100; i++)
        {
            string otp = OtpSecurityHelper.GenerateOtp();
            Assert(otp.Length == 6, "OTP length was " + otp.Length);
            Assert(otp.All(char.IsDigit), "OTP contained a non-digit");
        }
    }

    private static void OtpHashIsEmailBound()
    {
        const string secret = "unit-test-secret-with-at-least-32-bytes";
        string first = OtpSecurityHelper.HashOtp("USER@example.com", "123456", secret);
        string normalized = OtpSecurityHelper.HashOtp(" user@example.com ", "123456", secret);
        string otherEmail = OtpSecurityHelper.HashOtp("other@example.com", "123456", secret);

        Assert(first == normalized, "Equivalent emails produced different hashes");
        Assert(first != otherEmail, "Different emails produced the same hash");
    }

    private static void OtpVerificationRejectsWrongCode()
    {
        const string secret = "unit-test-secret-with-at-least-32-bytes";
        string hash = OtpSecurityHelper.HashOtp("user@example.com", "123456", secret);

        Assert(OtpSecurityHelper.VerifyOtp("user@example.com", "123456", hash, secret), "Correct OTP was rejected");
        Assert(!OtpSecurityHelper.VerifyOtp("user@example.com", "654321", hash, secret), "Wrong OTP was accepted");
    }

    private static void PasswordPolicyAcceptsStrongPassword()
    {
        Assert(ValidationHelper.GetPasswordValidationError("OnyxGear#2026") == null, "Strong password was rejected");
    }

    private static void PasswordPolicyRejectsMissingSymbol()
    {
        Assert(ValidationHelper.GetPasswordValidationError("OnyxGear2026") != null, "Password without a symbol was accepted");
    }

    private static void DobPolicyEnforcesBounds()
    {
        DateTime today = new DateTime(2026, 6, 12);
        Assert(ValidationHelper.IsValidRegistrationDob(new DateTime(2013, 6, 12), today), "Exactly age 13 was rejected");
        Assert(!ValidationHelper.IsValidRegistrationDob(new DateTime(2013, 6, 13), today), "Under age 13 was accepted");
        Assert(ValidationHelper.IsValidRegistrationDob(new DateTime(1906, 6, 12), today), "Exactly age 120 was rejected");
        Assert(!ValidationHelper.IsValidRegistrationDob(new DateTime(1906, 6, 11), today), "Age over 120 was accepted");
    }

    private static void IdentifierNormalizationIsStable()
    {
        Assert(ValidationHelper.NormalizeIdentifier("  User@Example.COM ") == "user@example.com", "Identifier normalization failed");
    }

    private static void Run(string name, Action test)
    {
        test();
        _passed++;
        Console.WriteLine("PASS: " + name);
    }

    private static void Assert(bool condition, string message)
    {
        if (!condition)
            throw new InvalidOperationException(message);
    }
}
