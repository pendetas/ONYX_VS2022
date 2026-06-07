namespace ONYX_DDAC.Models
{
    /// <summary>
    /// Aggregated KPI metrics returned by AdminRepository.GetDashboardMetrics()
    /// and displayed on the executive overview panel of the admin dashboard.
    /// </summary>
    public class DashboardMetrics
    {
        // ----- Revenue / Sales -----

        /// <summary>Total order revenue for today (non-cancelled orders).</summary>
        public decimal TodaySales { get; set; }

        /// <summary>Month-to-date revenue (non-cancelled orders).</summary>
        public decimal TotalRevenueMTD { get; set; }

        /// <summary>Percentage change in today's sales vs. the previous comparable period.</summary>
        public double TodaySalesTrend { get; set; }

        /// <summary>Percentage change in MTD revenue vs. the previous month.</summary>
        public double RevenueTrend { get; set; }

        // ----- Orders -----

        /// <summary>Number of orders placed today.</summary>
        public int TodayOrders { get; set; }

        /// <summary>Total orders placed this calendar month.</summary>
        public int TotalOrdersMTD { get; set; }

        /// <summary>Percentage change in order volume vs. the previous period.</summary>
        public double OrdersTrend { get; set; }

        // ----- Average Order Value -----

        /// <summary>Mean order value across all non-cancelled orders.</summary>
        public decimal AverageOrderValue { get; set; }

        /// <summary>Percentage change in AOV vs. the previous period.</summary>
        public double AOVTrend { get; set; }

        // ----- Customers -----

        /// <summary>Total number of registered customer accounts.</summary>
        public int TotalUsers { get; set; }

        /// <summary>Visitor-to-order conversion rate (%).</summary>
        public double ConversionRate { get; set; }

        /// <summary>Percentage-point change in conversion rate vs. the previous period.</summary>
        public double ConversionTrend { get; set; }

        /// <summary>Proportion of orders placed by returning customers (%).</summary>
        public double ReturningCustomerRate { get; set; }

        // ----- Inventory -----

        /// <summary>Number of products with stock_qty below the low-stock threshold (5 units).</summary>
        public int LowStockItems { get; set; }
    }
}
