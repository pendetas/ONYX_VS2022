using System;
using System.Collections.Generic;
using System.Data.Common;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.DAL
{
    public class AdminRepository
    {
        public DashboardMetrics GetDashboardMetrics()
        {
            var m = new DashboardMetrics();

            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();

                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT
                            COALESCE(SUM(total_amount) FILTER (
                                WHERE ordered_at::date = CURRENT_DATE), 0)                                               AS today_sales,
                            COALESCE(SUM(total_amount) FILTER (
                                WHERE ordered_at::date = CURRENT_DATE - 1), 0)                                           AS yesterday_sales,
                            COALESCE(SUM(total_amount) FILTER (
                                WHERE DATE_TRUNC('month', ordered_at) = DATE_TRUNC('month', NOW())), 0)                  AS mtd_revenue,
                            COALESCE(SUM(total_amount) FILTER (
                                WHERE DATE_TRUNC('month', ordered_at) = DATE_TRUNC('month', NOW() - INTERVAL '1 month')
                                  AND EXTRACT(DAY FROM ordered_at) <= EXTRACT(DAY FROM NOW())), 0)                       AS last_month_revenue_to_date,
                            COUNT(*) FILTER (
                                WHERE DATE_TRUNC('month', ordered_at) = DATE_TRUNC('month', NOW()))                      AS mtd_orders,
                            COUNT(*) FILTER (
                                WHERE DATE_TRUNC('month', ordered_at) = DATE_TRUNC('month', NOW() - INTERVAL '1 month')
                                  AND EXTRACT(DAY FROM ordered_at) <= EXTRACT(DAY FROM NOW()))                           AS last_month_orders_to_date,
                            COALESCE(AVG(total_amount) FILTER (
                                WHERE DATE_TRUNC('month', ordered_at) = DATE_TRUNC('month', NOW())), 0)                  AS aov,
                            COALESCE(AVG(total_amount) FILTER (
                                WHERE DATE_TRUNC('month', ordered_at) = DATE_TRUNC('month', NOW() - INTERVAL '1 month')), 0) AS last_month_aov
                        FROM orders
                        WHERE status <> 'cancelled'";

                    using (DbDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            decimal todaySales       = Convert.ToDecimal(r[0]);
                            decimal yesterdaySales   = Convert.ToDecimal(r[1]);
                            decimal mtdRevenue       = Convert.ToDecimal(r[2]);
                            decimal lastMonthRevenue = Convert.ToDecimal(r[3]);
                            int     mtdOrders        = Convert.ToInt32(r[4]);
                            int     lastMonthOrders  = Convert.ToInt32(r[5]);
                            decimal aov              = Convert.ToDecimal(r[6]);
                            decimal lastMonthAov     = Convert.ToDecimal(r[7]);

                            m.TodaySales        = todaySales;
                            m.TotalRevenueMTD   = mtdRevenue;
                            m.TotalOrdersMTD    = mtdOrders;
                            m.AverageOrderValue = aov;

                            m.TodaySalesTrend = CalcTrend(todaySales,     yesterdaySales);
                            m.RevenueTrend    = CalcTrend(mtdRevenue,      lastMonthRevenue);
                            m.OrdersTrend     = CalcTrend(mtdOrders,       lastMonthOrders);
                            m.AOVTrend        = CalcTrend(aov,             lastMonthAov);
                        }
                    }
                }

                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SELECT COUNT(*) FROM users WHERE role = 'customer'";
                    m.TotalUsers = Convert.ToInt32(cmd.ExecuteScalar());
                }

                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SELECT COUNT(*) FROM products WHERE stock_qty < 5";
                    m.LowStockItems = Convert.ToInt32(cmd.ExecuteScalar());
                }

                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        WITH this_month_buyers AS (
                            SELECT DISTINCT user_id
                            FROM orders
                            WHERE DATE_TRUNC('month', ordered_at) = DATE_TRUNC('month', NOW())
                              AND status <> 'cancelled'
                        ),
                        repeat_buyers AS (
                            SELECT user_id
                            FROM orders
                            WHERE status <> 'cancelled'
                            GROUP BY user_id
                            HAVING COUNT(*) > 1
                        ),
                        total_customers AS (
                            SELECT COUNT(*) AS cnt FROM users WHERE role = 'customer'
                        )
                        SELECT
                            COUNT(tmb.user_id)                 AS buyers_this_month,
                            COUNT(rb.user_id)                  AS returning_buyers,
                            (SELECT cnt FROM total_customers)  AS total_customers
                        FROM this_month_buyers tmb
                        LEFT JOIN repeat_buyers rb ON tmb.user_id = rb.user_id";

                    using (DbDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            int buyersThisMonth = Convert.ToInt32(r[0]);
                            int returningBuyers = Convert.ToInt32(r[1]);
                            int totalCustomers  = Convert.ToInt32(r[2]);

                            m.ReturningCustomerRate = buyersThisMonth > 0
                                ? Math.Round((double)returningBuyers / buyersThisMonth * 100.0, 1)
                                : 0.0;

                            m.ConversionRate = totalCustomers > 0
                                ? Math.Round((double)buyersThisMonth / totalCustomers * 100.0, 1)
                                : 0.0;
                        }
                    }
                }

                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT
                            COUNT(DISTINCT user_id) FILTER (
                                WHERE DATE_TRUNC('month', ordered_at) = DATE_TRUNC('month', NOW())) AS this_month,
                            COUNT(DISTINCT user_id) FILTER (
                                WHERE DATE_TRUNC('month', ordered_at) = DATE_TRUNC('month', NOW() - INTERVAL '1 month')) AS last_month
                        FROM orders
                        WHERE status <> 'cancelled'";

                    using (DbDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                            m.ConversionTrend = CalcTrend(Convert.ToInt32(r[0]), Convert.ToInt32(r[1]));
                    }
                }
            }

            return m;
        }

        public List<TopProduct> GetTopSellingProducts(int count = 5)
        {
            var results = new List<TopProduct>();

            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT
                            p.name,
                            p.category,
                            p.price,
                            p.stock_qty,
                            COALESCE(SUM(oi.quantity) FILTER (
                                WHERE DATE_TRUNC('month', o.ordered_at) = DATE_TRUNC('month', NOW())), 0)                      AS units_this_month,
                            COALESCE(SUM(oi.subtotal) FILTER (
                                WHERE DATE_TRUNC('month', o.ordered_at) = DATE_TRUNC('month', NOW())), 0)                      AS revenue_this_month,
                            COALESCE(SUM(oi.quantity) FILTER (
                                WHERE DATE_TRUNC('month', o.ordered_at) = DATE_TRUNC('month', NOW() - INTERVAL '1 month')), 0) AS units_last_month
                        FROM products p
                        LEFT JOIN order_items oi ON p.id = oi.product_id
                        LEFT JOIN orders o ON oi.order_id = o.id AND o.status <> 'cancelled'
                        GROUP BY p.id, p.name, p.category, p.price, p.stock_qty
                        ORDER BY units_this_month DESC, revenue_this_month DESC
                        LIMIT @count";

                    DbParameter p = cmd.CreateParameter();
                    p.ParameterName = "@count";
                    p.Value = count;
                    cmd.Parameters.Add(p);

                    using (DbDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            decimal price        = Convert.ToDecimal(r[2]);
                            int     stockQty     = Convert.ToInt32(r[3]);
                            int     unitsCurrent = Convert.ToInt32(r[4]);
                            decimal revCurrent   = Convert.ToDecimal(r[5]);
                            int     unitsLast    = Convert.ToInt32(r[6]);

                            results.Add(new TopProduct
                            {
                                Name       = r.GetString(0),
                                Category   = r.GetString(1),
                                Price      = price,
                                StockQty   = stockQty,
                                UnitsSold  = unitsCurrent,
                                Revenue    = revCurrent,
                                GrowthRate = CalcTrend(unitsCurrent, unitsLast)
                            });
                        }
                    }
                }
            }

            return results;
        }

        public List<LowStockProduct> GetLowStockProducts(int threshold = 5)
        {
            var results = new List<LowStockProduct>();

            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT id, name, category, stock_qty
                        FROM products
                        WHERE stock_qty < @Threshold
                        ORDER BY stock_qty ASC, name ASC";

                    DbParameter p = cmd.CreateParameter();
                    p.ParameterName = "@Threshold";
                    p.Value = threshold;
                    cmd.Parameters.Add(p);

                    using (DbDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            results.Add(new LowStockProduct
                            {
                                Id       = r.GetInt64(0),
                                Name     = r.GetString(1),
                                Category = r.GetString(2),
                                StockQty = r.GetInt32(3)
                            });
                        }
                    }
                }
            }

            return results;
        }

        public List<RecentOrder> GetRecentOrders(int count = 6)
        {
            var results = new List<RecentOrder>();

            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT o.id, u.fullname, o.status, o.total_amount, o.ordered_at
                        FROM orders o
                        JOIN users u ON o.user_id = u.id
                        ORDER BY o.ordered_at DESC
                        LIMIT @count";

                    DbParameter p = cmd.CreateParameter();
                    p.ParameterName = "@count";
                    p.Value = count;
                    cmd.Parameters.Add(p);

                    using (DbDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            string status = r.GetString(2);
                            results.Add(new RecentOrder
                            {
                                OrderId        = r.GetInt64(0),
                                CustomerName   = r.GetString(1),
                                Status         = status,
                                TotalAmount    = Convert.ToDecimal(r[3]),
                                OrderedAt      = r.GetDateTime(4),
                                StatusCssClass = MapStatusCss(status)
                            });
                        }
                    }
                }
            }

            return results;
        }

        public List<RecentActivity> GetRecentActivities(int count = 3)
        {
            var list = new List<RecentActivity>();

            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT * FROM (
                            SELECT
                                'order'                                                                    AS activity_type,
                                o.id                                                                       AS ref_id,
                                COALESCE(NULLIF(TRIM(u.fullname), ''), u.username, 'Unknown')             AS name,
                                o.total_amount::text                                                       AS extra,
                                o.ordered_at                                                               AS happened_at
                            FROM orders o
                            LEFT JOIN users u ON o.user_id = u.id
                            UNION ALL
                            SELECT
                                'user'                                                                     AS activity_type,
                                u.id                                                                       AS ref_id,
                                COALESCE(NULLIF(TRIM(u.fullname), ''), u.username)                        AS name,
                                u.email                                                                    AS extra,
                                u.created_at                                                               AS happened_at
                            FROM users u
                        ) combined
                        ORDER BY happened_at DESC
                        LIMIT @count";

                    DbParameter p = cmd.CreateParameter();
                    p.ParameterName = "@count";
                    p.Value = count;
                    cmd.Parameters.Add(p);

                    using (DbDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            string   type  = r.GetString(0);
                            long     id    = r.GetInt64(1);
                            string   name  = r.GetString(2);
                            string   extra = r.GetString(3);
                            DateTime at    = r.GetDateTime(4);

                            list.Add(new RecentActivity
                            {
                                Type      = type,
                                RefId     = id,
                                Title     = type == "order"
                                            ? "New order by " + name
                                            : name + " joined",
                                Sub       = type == "order"
                                            ? "#ORD-" + id + " &middot; RM " + Convert.ToDecimal(extra).ToString("N2")
                                            : extra,
                                TimeLabel = FormatTimeAgo(at),
                                Icon      = type == "order" ? "shopping-bag" : "user-plus"
                            });
                        }
                    }
                }
            }

            return list;
        }

        public List<decimal> GetWeeklyRevenueTrend()
        {
            var results = new List<decimal>();

            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT COALESCE(SUM(o.total_amount), 0) AS daily_revenue
                        FROM generate_series(
                            CURRENT_DATE - INTERVAL '6 days',
                            CURRENT_DATE,
                            INTERVAL '1 day'
                        ) AS d(day)
                        LEFT JOIN orders o
                            ON o.ordered_at::date = d.day
                           AND o.status <> 'cancelled'
                        GROUP BY d.day
                        ORDER BY d.day";

                    using (DbDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                            results.Add(Convert.ToDecimal(r[0]));
                    }
                }
            }

            while (results.Count < 7) results.Insert(0, 0m);
            if (results.Count > 7) results = results.GetRange(results.Count - 7, 7);

            return results;
        }

        // =====================================================================
        //  HELPERS
        // =====================================================================

        private static double CalcTrend(decimal current, decimal previous)
        {
            if (previous == 0m) return current > 0m ? 100.0 : 0.0;
            return Math.Round((double)((current - previous) / previous * 100m), 1);
        }

        private static double CalcTrend(int current, int previous)
        {
            if (previous == 0) return current > 0 ? 100.0 : 0.0;
            return Math.Round((double)(current - previous) / previous * 100.0, 1);
        }

        private static string MapStatusCss(string status)
        {
            switch ((status ?? "").ToLowerInvariant())
            {
                case "shipped":   return "status-shipped";
                case "delivered": return "status-delivered";
                case "cancelled": return "status-cancelled";
                default:          return "status-pending";
            }
        }

        private static string FormatTimeAgo(DateTime dt)
        {
            TimeSpan diff = DateTime.Now - dt;
            if (diff.TotalMinutes < 1)  return "Just now";
            if (diff.TotalMinutes < 60) return (int)diff.TotalMinutes + " min ago";
            if (diff.TotalHours   < 24) return (int)diff.TotalHours + "h ago";
            if (diff.TotalDays    < 7)  return (int)diff.TotalDays + "d ago";
            return dt.ToString("d MMM yyyy");
        }
    }
}
