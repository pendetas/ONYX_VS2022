using System;

namespace ONYX_DDAC.Models
{
    public class Invoice
    {
        public Order Order { get; set; }
        public User Customer { get; set; }

        public Invoice()
        {
            Order = new Order();
            Customer = new User();
        }

        public string OrderReference
        {
            get
            {
                if (Order == null)
                {
                    return string.Empty;
                }

                int displayNumber = (int)(((Order.Id * 137) + 41) % 1000);
                return string.Format("Z{0:000}", displayNumber);
            }
        }

        public DateTime OrderedAt
        {
            get { return Order == null ? DateTime.MinValue : Order.OrderedAt; }
        }
    }
}
