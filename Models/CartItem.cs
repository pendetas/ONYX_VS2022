namespace ONYX_DDAC.Models
{
    public class CartItem
    {
        public long ProductId { get; set; }
        public long? ProductVariantId { get; set; }
        public string ProductName { get; set; }
        public string VariantLabel { get; set; }
        public string ImageUrl { get; set; }
        public decimal UnitPrice { get; set; }
        public int Quantity { get; set; }
        public decimal Subtotal
        {
            get { return UnitPrice * Quantity; }
        }
    }
}
