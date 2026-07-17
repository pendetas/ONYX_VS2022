using System;

namespace ONYX_DDAC.Models
{
    public class StripePaymentState
    {
        public long OrderId { get; set; }
        public long UserId { get; set; }
        public string SessionId { get; set; }
        public string SessionStatus { get; set; }
        public string PaymentStatus { get; set; }
        public string Mode { get; set; }
        public string Currency { get; set; }
        public long? AmountTotal { get; set; }
        public string CheckoutUrl { get; set; }
        public string PaymentIntentId { get; set; }
        public string PaymentMethodSummary { get; set; }
        public string CheckoutAttemptToken { get; set; }
        public bool IsOnyxSession { get; set; }

        public bool IsPaid
        {
            get
            {
                return string.Equals(PaymentStatus, "paid", StringComparison.OrdinalIgnoreCase) ||
                    IsNoCostSession;
            }
        }

        public bool IsNoCostSession
        {
            get { return string.Equals(PaymentStatus, "no_payment_required", StringComparison.OrdinalIgnoreCase); }
        }

        public bool IsExpired
        {
            get { return string.Equals(SessionStatus, "expired", StringComparison.OrdinalIgnoreCase); }
        }

        public bool IsOpen
        {
            get { return string.Equals(SessionStatus, "open", StringComparison.OrdinalIgnoreCase); }
        }
    }
}
