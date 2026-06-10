namespace ONYX_DDAC.Models
{
    public class UserStats
    {
        public int     Total           { get; set; }
        public int     Admins          { get; set; }
        public int     Customers       { get; set; }
        public int     NewThisMonth    { get; set; }
        public decimal PlatformRevenue { get; set; }
    }
}
