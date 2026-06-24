using System;

namespace ONYX_DDAC.Models
{
    public class StockReservation
    {
        public const string Active = "active";
        public const string Completed = "completed";
        public const string Released = "released";

        public long ReservationId { get; set; }
        public long OrderId { get; set; }
        public long ProductId { get; set; }
        public long? ProductVariantId { get; set; }
        public long VariantKey { get; set; }
        public int Quantity { get; set; }
        public string Status { get; set; }
        public DateTimeOffset ExpiresAt { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
    }
}
