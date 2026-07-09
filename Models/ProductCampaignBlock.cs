using System;

namespace ONYX_DDAC.Models
{
    [Serializable]
    public class ProductCampaignBlock
    {
        public long Id { get; set; }
        public long ProductId { get; set; }
        public string BlockType { get; set; }
        public int SortOrder { get; set; }
        public bool IsEnabled { get; set; }

        public string Eyebrow { get; set; }
        public string Headline { get; set; }
        public string Body { get; set; }

        public string MediaType { get; set; }
        public string MediaUrl { get; set; }
        public string MediaAlt { get; set; }

        public string LayoutVariant { get; set; }
        public string BackgroundVariant { get; set; }
        public string JsonContent { get; set; }

        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
