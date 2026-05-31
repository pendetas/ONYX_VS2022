using System;

namespace ONYX_DDAC.Models
{
    public class Review
    {
        public long ReviewId { get; set; }
        public long UserId { get; set; }
        public long ProductId { get; set; }
        public short Rating { get; set; }
        public string Comment { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
