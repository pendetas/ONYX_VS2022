namespace ONYX_DDAC.Models
{
    public class ProductVariant
    {
        public long ProductVariantId { get; set; }
        public long ProductId { get; set; }
        public string VariantType { get; set; }
        public string VariantValue { get; set; }
        public decimal VariantPrice { get; set; }
        public int StockQty { get; set; }
        public string ImageUrl { get; set; }
    }
}
