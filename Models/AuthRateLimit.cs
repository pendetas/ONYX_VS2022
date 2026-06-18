using System;

namespace ONYX_DDAC.Models
{
    public class AuthRateLimit
    {
        public long Id { get; set; }
        public string Action { get; set; }
        public string IdentityKey { get; set; }
        public int AttemptCount { get; set; }
        public DateTime WindowStartedAt { get; set; }
        public DateTime? BlockedUntil { get; set; }
        public DateTime LastAttemptAt { get; set; }
    }
}
