using ONYX_DDAC.Models;

namespace ONYX_DDAC.Models
{
    public class ProfileUpdateResult
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public User User { get; set; }
    }
}
