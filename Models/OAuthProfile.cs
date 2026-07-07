namespace ONYX_DDAC.Models
{
    public class OAuthProfile
    {
        public string Provider { get; set; }
        public string Subject { get; set; }
        public string Email { get; set; }
        public bool EmailVerified { get; set; }
        public string FullName { get; set; }
        public string AvatarUrl { get; set; }
    }
}
