using System;

namespace ONYX_DDAC.Models
{
    public class RegistrationRequest
    {
        public string FullName { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public string Password { get; set; }
        public string ConfirmPassword { get; set; }
        public string Address { get; set; }
        public DateTime Dob { get; set; }
        public string PhoneNumber { get; set; }
        public string CaptchaToken { get; set; }
        public string RemoteIp { get; set; }
    }
}
