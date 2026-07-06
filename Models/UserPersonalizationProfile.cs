using System;
using System.Collections.Generic;

namespace ONYX_DDAC.Models
{
    public class UserPersonalizationProfile
    {
        public long UserId { get; set; }
        public string GamingStyle { get; set; }
        public IList<string> PreferredCategories { get; set; } = new List<string>();
        public IList<string> Priorities { get; set; } = new List<string>();
        public IList<string> ComfortPreferences { get; set; } = new List<string>();
        public IList<string> PerformancePreferences { get; set; } = new List<string>();
        public IList<string> SetupConstraints { get; set; } = new List<string>();
        public string BudgetRange { get; set; }
        public string SetupGoal { get; set; }
        public DateTime? CompletedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
