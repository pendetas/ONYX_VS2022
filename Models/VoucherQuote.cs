namespace ONYX_DDAC.Models
{
    public class VoucherCartLine
    {
        public string Category { get; set; }

        public decimal UnitPrice { get; set; }

        public int Quantity { get; set; }
    }

    public class VoucherQuote
    {
        public long VoucherId { get; set; }

        public string Code { get; set; }

        public string Name { get; set; }

        public string TermsAndConditions { get; set; }

        public decimal Subtotal { get; set; }

        public decimal EligibleSubtotal { get; set; }

        public decimal DiscountAmount { get; set; }

        public decimal TotalAmount { get; set; }
    }
}
