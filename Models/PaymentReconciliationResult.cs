using System;

namespace ONYX_DDAC.Models
{
    public class PaymentReconciliationResult
    {
        public long OrderId { get; set; }
        public string OrderStatus { get; set; }
        public string CheckoutUrl { get; set; }

        public bool IsPaid
        {
            get { return string.Equals(OrderStatus?.Trim(), OrderStatuses.Paid, StringComparison.OrdinalIgnoreCase); }
        }
    }
}
