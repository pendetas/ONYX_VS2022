using System;

namespace ONYX_DDAC.Models
{
    public class UserDetail
    {
        public long     Id          { get; set; }
        public string   FullName    { get; set; }
        public string   Username    { get; set; }
        public string   Email       { get; set; }
        public string   Phone       { get; set; }
        public string   Address     { get; set; }
        public string   Dob         { get; set; }
        public string   Role        { get; set; }
        public string   Initials    { get; set; }
        public DateTime CreatedAt   { get; set; }
        public int      TotalOrders { get; set; }
        public decimal  TotalSpent  { get; set; }
    }
}
