namespace ONYX_DDAC.Models
{
    public class UserSummary
    {
        public long   Id          { get; set; }
        public string FullName    { get; set; }
        public string Email       { get; set; }
        public string Role        { get; set; }
        public string RoleKey     { get; set; }
        public string Initials    { get; set; }
        public string Phone       { get; set; }
        public string JoinDate    { get; set; }
        public string TotalOrders { get; set; }
        public string TotalSpent  { get; set; }
        public string SpentClass  { get; set; }
    }
}
