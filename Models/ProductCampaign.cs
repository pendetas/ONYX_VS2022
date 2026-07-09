using System;

namespace ONYX_DDAC.Models
{
    public class ProductCampaign
    {
        public long ProductId { get; set; }
        public bool CampaignEnabled { get; set; }
        public string HeroEyebrow { get; set; }
        public string HeroHeadline { get; set; }
        public string HeroBody { get; set; }
        public string HeroImageUrl { get; set; }
        public string OverviewEyebrow { get; set; }
        public string OverviewHeadline { get; set; }
        public string OverviewBody { get; set; }
        public string PerformanceEyebrow { get; set; }
        public string PerformanceHeadline { get; set; }
        public string PerformanceBody { get; set; }
        public string FeatureCards { get; set; }
        public string SpecsText { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }
}
