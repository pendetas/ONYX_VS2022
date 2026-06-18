using System;

namespace ONYX_DDAC.Models
{
    public class AuthRateLimitResult
    {
        public bool Allowed
        {
            get { return !IsBlocked; }
        }

        public bool IsBlocked { get; set; }
        public DateTime? BlockedUntil { get; set; }
        public int AttemptCount { get; set; }
        public int AttemptsRemaining { get; set; }

        public static AuthRateLimitResult Allow(int attemptsRemaining)
        {
            return new AuthRateLimitResult
            {
                IsBlocked = false,
                AttemptsRemaining = attemptsRemaining
            };
        }
    }
}
