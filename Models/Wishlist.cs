using System;

namespace ONYX_DDAC.Models
{
    public class Wishlist
    {
        public long WishlistId { get; set; }
        public long UserId { get; set; }
        public long ProductId { get; set; }
        public DateTime AddedAt { get; set; }
    }
}
