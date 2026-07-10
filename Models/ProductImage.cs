using System;

namespace ONYX_DDAC.Models
{
    public class ProductImage
    {
        public long Id { get; set; }
        public long ProductId { get; set; }
        public string ImagePath { get; set; }
        public int DisplayOrder { get; set; }
        public bool IsPrimary { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
