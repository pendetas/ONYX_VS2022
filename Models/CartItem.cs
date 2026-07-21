namespace ONYX_DDAC.Models
{
    public class CartItem
    {
        public long ProductId { get; set; }
        public long? VariantId { get; set; }
        public string ProductName { get; set; }
        public string Category { get; set; }
        public string VariantName { get; set; }
        public decimal Price { get; set; }
        public int Quantity { get; set; }
        public string ImageUrl { get; set; }

        // This allows your Eval("Subtotal") in the HTML to work!
        public decimal Subtotal
        {
            get { return Price * Quantity; }
        }
    }
}
