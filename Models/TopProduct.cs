namespace ONYX_DDAC.Models
{
    /// <summary>
    /// Represents a top-selling product entry for the dashboard's leaderboard widget.
    /// </summary>
    public class TopProduct
    {
        public string Name { get; set; }
        public string Category { get; set; }
        public decimal Price    { get; set; }
        public int    UnitsSold { get; set; }
        public int    StockQty  { get; set; }
        public decimal Revenue  { get; set; }
        public double GrowthRate { get; set; }  // % change vs last month; negative = decline
    }
}
