using System;

namespace ONYX_DDAC.Models
{
    public class StripeCheckoutResult
    {
        public long OrderId { get; set; }
        public string SessionId { get; set; }
        public string CheckoutUrl { get; set; }
        public DateTimeOffset ExpiresAt { get; set; }
    }
}
