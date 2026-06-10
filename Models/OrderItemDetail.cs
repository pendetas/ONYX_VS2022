namespace ONYX_DDAC.Models
{
    public class OrderItemDetail
    {
        public string  ProductName  { get; set; }
        public string  Category     { get; set; }
        public int     Quantity     { get; set; }
        public decimal UnitPrice    { get; set; }
        public string  UnitPriceFmt { get; set; }
        public string  SubtotalFmt  { get; set; }
    }
}
