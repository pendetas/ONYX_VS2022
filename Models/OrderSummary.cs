namespace ONYX_DDAC.Models
{
    public class OrderSummary
    {
        public long   RawId        { get; set; }
        public string OrderId      { get; set; }
        public string CustomerName { get; set; }
        public string Date         { get; set; }
        public int    ItemCount    { get; set; }
        public string Total        { get; set; }
        public string Status       { get; set; }
        public string StatusKey    { get; set; }
    }
}
