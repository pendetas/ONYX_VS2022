namespace ONYX_DDAC.Models
{
    public class OrderStats
    {
        public int     Total     { get; set; }
        public int     Pending   { get; set; }
        public int     Shipped   { get; set; }
        public int     Delivered { get; set; }
        public decimal Revenue   { get; set; }
    }
}
