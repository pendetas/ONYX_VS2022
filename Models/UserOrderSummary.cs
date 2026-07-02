namespace ONYX_DDAC.Models
{
    public class UserOrderSummary
    {
        public long   RawId     { get; set; }
        public string OrderId   { get; set; }
        public string Date      { get; set; }
        public string Total     { get; set; }
        public string Status    { get; set; }
        public string StatusKey { get; set; }
    }
}
