using System;
using System.Collections.Generic;
using System.Data.Common;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.DAL
{
    public class OrderRepository
    {
        // =====================================================================
        //  READ QUERIES
        // =====================================================================

        public List<OrderSummary> GetAllOrders()
        {
            var list = new List<OrderSummary>();

            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT
                            o.id,
                            COALESCE(NULLIF(TRIM(u.fullname), ''), u.username, 'Unknown') AS customer_name,
                            o.ordered_at,
                            COALESCE(SUM(oi.quantity), 0)::int AS item_count,
                            o.total_amount,
                            o.status
                        FROM orders o
                        LEFT JOIN users u ON o.user_id = u.id
                        LEFT JOIN order_items oi ON oi.order_id = o.id
                        GROUP BY o.id, u.fullname, u.username, o.ordered_at, o.total_amount, o.status
                        ORDER BY o.ordered_at DESC";

                    using (DbDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            string status = r.GetString(5);
                            string cap    = char.ToUpper(status[0]) + status.Substring(1);

                            list.Add(new OrderSummary
                            {
                                RawId        = r.GetInt64(0),
                                OrderId      = "#ORD-" + r.GetInt64(0),
                                CustomerName = r.GetString(1),
                                Date         = r.GetDateTime(2).ToString("d MMM yyyy, h:mm tt"),
                                ItemCount    = r.GetInt32(3),
                                Total        = "RM " + Convert.ToDecimal(r[4]).ToString("N2"),
                                Status       = cap,
                                StatusKey    = status.ToLower()
                            });
                        }
                    }
                }
            }

            return list;
        }

        public OrderDetail GetOrderById(long id)
        {
            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT
                            o.id,
                            o.status,
                            o.total_amount,
                            COALESCE(o.shipping_address, '') AS shipping_address,
                            COALESCE(o.receipt_s3_key,   '') AS receipt_s3_key,
                            o.ordered_at,
                            o.status_updated_at,
                            COALESCE(NULLIF(TRIM(u.fullname), ''), u.username, 'Unknown') AS customer_name,
                            u.email,
                            COALESCE(u.phone_number, '—') AS phone,
                            u.created_at
                        FROM orders o
                        LEFT JOIN users u ON o.user_id = u.id
                        WHERE o.id = @Id";

                    DbParameter p = cmd.CreateParameter();
                    p.ParameterName = "@Id";
                    p.Value = id;
                    cmd.Parameters.Add(p);

                    using (DbDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            return new OrderDetail
                            {
                                Id              = r.GetInt64(0),
                                Status          = r.GetString(1),
                                TotalAmount     = Convert.ToDecimal(r[2]),
                                ShippingAddress = r.GetString(3),
                                ReceiptS3Key    = r.GetString(4),
                                OrderedAt       = r.GetDateTime(5),
                                StatusUpdatedAt = r.IsDBNull(6) ? (DateTime?)null : r.GetDateTime(6),
                                CustomerName    = r.GetString(7),
                                CustomerEmail   = r.IsDBNull(8) ? "—" : r.GetString(8),
                                CustomerPhone   = r.GetString(9),
                                CustomerSince   = r.IsDBNull(10) ? DateTime.MinValue : r.GetDateTime(10)
                            };
                        }
                    }
                }
            }
            return null;
        }

        public List<OrderItemDetail> GetOrderItems(long orderId)
        {
            var list = new List<OrderItemDetail>();

            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT
                            COALESCE(p.name, 'Unknown Product') AS product_name,
                            COALESCE(p.category, '—')           AS category,
                            oi.quantity,
                            oi.unit_price
                        FROM order_items oi
                        LEFT JOIN products p ON p.id = oi.product_id
                        WHERE oi.order_id = @OrderId";

                    DbParameter p = cmd.CreateParameter();
                    p.ParameterName = "@OrderId";
                    p.Value = orderId;
                    cmd.Parameters.Add(p);

                    using (DbDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            string  name     = r.GetString(0);
                            string  category = r.GetString(1);
                            int     qty      = r.GetInt32(2);
                            decimal price    = Convert.ToDecimal(r[3]);

                            list.Add(new OrderItemDetail
                            {
                                ProductName  = name,
                                Category     = category,
                                Quantity     = qty,
                                UnitPrice    = price,
                                UnitPriceFmt = "RM " + price.ToString("N2"),
                                SubtotalFmt  = "RM " + (price * qty).ToString("N2")
                            });
                        }
                    }
                }
            }

            return list;
        }

        public OrderStats GetStats()
        {
            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT
                            COUNT(*)                                                             AS total,
                            COUNT(*) FILTER (WHERE status = 'pending')                          AS pending,
                            COUNT(*) FILTER (WHERE status = 'shipped')                          AS shipped,
                            COUNT(*) FILTER (WHERE status = 'delivered')                        AS delivered,
                            COALESCE(SUM(total_amount) FILTER (WHERE status <> 'cancelled'), 0) AS revenue
                        FROM orders";

                    using (DbDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            return new OrderStats
                            {
                                Total     = Convert.ToInt32(r[0]),
                                Pending   = Convert.ToInt32(r[1]),
                                Shipped   = Convert.ToInt32(r[2]),
                                Delivered = Convert.ToInt32(r[3]),
                                Revenue   = Convert.ToDecimal(r[4])
                            };
                        }
                    }
                }
            }
            return new OrderStats();
        }

        // =====================================================================
        //  WRITE OPERATIONS
        // =====================================================================

        public void UpdateStatus(long id, string status)
        {
            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "UPDATE orders SET status = @Status, status_updated_at = NOW() WHERE id = @Id";

                    DbParameter pStatus = cmd.CreateParameter();
                    pStatus.ParameterName = "@Status";
                    pStatus.Value = status;
                    cmd.Parameters.Add(pStatus);

                    DbParameter pId = cmd.CreateParameter();
                    pId.ParameterName = "@Id";
                    pId.Value = id;
                    cmd.Parameters.Add(pId);

                    cmd.ExecuteNonQuery();
                }
            }
        }

        public void DeleteOrder(long id)
        {
            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbTransaction tx = conn.BeginTransaction())
                {
                    using (DbCommand cmd = conn.CreateCommand())
                    {
                        cmd.Transaction = tx;

                        cmd.CommandText = "DELETE FROM order_items WHERE order_id = @Id";
                        DbParameter p1 = cmd.CreateParameter();
                        p1.ParameterName = "@Id";
                        p1.Value = id;
                        cmd.Parameters.Add(p1);
                        cmd.ExecuteNonQuery();

                        cmd.Parameters.Clear();
                        cmd.CommandText = "DELETE FROM orders WHERE id = @Id";
                        DbParameter p2 = cmd.CreateParameter();
                        p2.ParameterName = "@Id";
                        p2.Value = id;
                        cmd.Parameters.Add(p2);
                        cmd.ExecuteNonQuery();
                    }
                    tx.Commit();
                }
            }
        }
    }
}
