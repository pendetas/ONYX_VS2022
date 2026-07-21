namespace ONYX_DDAC.Models
{
    public class OrderSummary
    {
        public long   RawId        { get; set; }
        public string OrderId      { get; set; }
        public string CustomerName { get; set; }
        public string Date         { get; set; }
        public int    ItemCount    { get; set; }
        public decimal SubtotalAmount { get; set; }
        public decimal DiscountAmount { get; set; }
        public string Total        { get; set; }
        public long?  VoucherId    { get; set; }
        public string VoucherCode  { get; set; }
        public string VoucherName  { get; set; }
        public string Status       { get; set; }
        public string StatusKey    { get; set; }
    }
}
