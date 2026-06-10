using System;

namespace ONYX_DDAC.Models
{
    public class OrderDetail
    {
        public long      Id              { get; set; }
        public string    Status          { get; set; }
        public decimal   TotalAmount     { get; set; }
        public string    ShippingAddress { get; set; }
        public string    ReceiptS3Key    { get; set; }
        public DateTime  OrderedAt       { get; set; }
        public DateTime? StatusUpdatedAt { get; set; }
        public string    CustomerName    { get; set; }
        public string    CustomerEmail   { get; set; }
        public string    CustomerPhone   { get; set; }
        public DateTime  CustomerSince   { get; set; }
    }
}
