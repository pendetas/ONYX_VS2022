using System;

namespace ONYX_DDAC.Models
{
    /// <summary>
    /// A flattened summary row for a recent order displayed on the admin dashboard.
    /// Combines data from the orders and users tables.
    /// </summary>
    public class RecentOrder
    {
        public long OrderId { get; set; }
        public string CustomerName { get; set; }
        public string Status { get; set; }
        public decimal TotalAmount { get; set; }
        public DateTime OrderedAt { get; set; }

        /// <summary>
        /// CSS class name for the status badge, derived from Status value.
        /// e.g. "status-pending", "status-shipped", "status-delivered", "status-cancelled"
        /// </summary>
        public string StatusCssClass { get; set; }
    }
}
