namespace ONYX_DDAC.Models
{
    public class LowStockProduct
    {
        public long   Id       { get; set; }
        public string Name     { get; set; }
        public string Category { get; set; }
        public int    StockQty { get; set; }
    }
}
