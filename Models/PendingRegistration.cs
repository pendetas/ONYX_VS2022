using System;

namespace ONYX_DDAC.Models
{
    public class PendingRegistration
    {
        public long Id { get; set; }
        public string FullName { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public string PasswordHash { get; set; }
        public string Address { get; set; }
        public DateTime? Dob { get; set; }
        public string PhoneNumber { get; set; }
        public string OtpHash { get; set; }
        public DateTime OtpExpiresAt { get; set; }
        public int OtpAttempts { get; set; }
        public int ResendCount { get; set; }
        public DateTime LastOtpSentAt { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
