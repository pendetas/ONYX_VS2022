using System;
using System.Collections.Generic;

namespace ONYX_DDAC.Models
{
    public class Order
    {
        public long Id { get; set; }
        public long UserId { get; set; }
        public string Status { get; set; }
        public decimal TotalAmount { get; set; }
        public string ShippingAddress { get; set; }
        public string DeliveryMethod { get; set; }
        public string CheckoutAttemptToken { get; set; }
        public string PaymentCancellationTokenHash { get; set; }
        public string StripeCheckoutSessionId { get; set; }
        public string StripePaymentIntentId { get; set; }
        public string PaymentMethod { get; set; }
        public DateTimeOffset? PaymentExpiresAt { get; set; }
        public DateTimeOffset? PaidAt { get; set; }
        public bool IsExistingCheckoutAttempt { get; set; }
        public string ReceiptS3Key { get; set; }
        public DateTime OrderedAt { get; set; }
        public IList<OrderItem> Items { get; set; }

        public Order()
        {
            Items = new List<OrderItem>();
        }
    }
}
