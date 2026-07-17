using System;
using System.Collections.Generic;
using System.Data.Common;
using Npgsql;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.DAL
{
    public class OrderRepository
    {
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
                            o.subtotal_amount,
                            o.discount_amount,
                            o.total_amount,
                            o.voucher_id,
                            o.voucher_code,
                            o.voucher_name,
                            o.status
                        FROM orders o
                        LEFT JOIN users u ON o.user_id = u.id
                        LEFT JOIN order_items oi ON oi.order_id = o.id
                        GROUP BY o.id, u.fullname, u.username, o.ordered_at, o.subtotal_amount, o.discount_amount, o.total_amount, o.voucher_id, o.voucher_code, o.voucher_name, o.status
                        ORDER BY o.ordered_at DESC";

                    using (DbDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            string status = r.GetString(r.GetOrdinal("status"));
                            string cap = string.IsNullOrEmpty(status) ? "Unknown" : char.ToUpper(status[0]) + status.Substring(1);

                            list.Add(new OrderSummary
                            {
                                RawId = r.GetInt64(r.GetOrdinal("id")),
                                OrderId = "#ORD-" + r.GetInt64(r.GetOrdinal("id")),
                                CustomerName = r.GetString(r.GetOrdinal("customer_name")),
                                Date = r.GetDateTime(r.GetOrdinal("ordered_at")).ToString("d MMM yyyy, h:mm tt"),
                                ItemCount = r.GetInt32(r.GetOrdinal("item_count")),
                                SubtotalAmount = r.GetDecimal(r.GetOrdinal("subtotal_amount")),
                                DiscountAmount = r.GetDecimal(r.GetOrdinal("discount_amount")),
                                Total = "RM " + r.GetDecimal(r.GetOrdinal("total_amount")).ToString("N2"),
                                VoucherId = r.IsDBNull(r.GetOrdinal("voucher_id")) ? (long?)null : r.GetInt64(r.GetOrdinal("voucher_id")),
                                VoucherCode = ReadNullableString(r, "voucher_code"),
                                VoucherName = ReadNullableString(r, "voucher_name"),
                                Status = cap,
                                StatusKey = status.ToLower()
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
                            o.subtotal_amount,
                            o.discount_amount,
                            o.total_amount,
                            o.voucher_id,
                            o.voucher_code,
                            o.voucher_name,
                            o.shipping_address,
                            o.receipt_s3_key,
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
                                Id = r.GetInt64(r.GetOrdinal("id")),
                                Status = r.GetString(r.GetOrdinal("status")),
                                SubtotalAmount = r.GetDecimal(r.GetOrdinal("subtotal_amount")),
                                DiscountAmount = r.GetDecimal(r.GetOrdinal("discount_amount")),
                                TotalAmount = r.GetDecimal(r.GetOrdinal("total_amount")),
                                VoucherId = r.IsDBNull(r.GetOrdinal("voucher_id")) ? (long?)null : r.GetInt64(r.GetOrdinal("voucher_id")),
                                VoucherCode = ReadNullableString(r, "voucher_code"),
                                VoucherName = ReadNullableString(r, "voucher_name"),
                                ShippingAddress = ReadNullableString(r, "shipping_address"),
                                ReceiptS3Key = ReadNullableString(r, "receipt_s3_key"),
                                OrderedAt = r.GetDateTime(r.GetOrdinal("ordered_at")),
                                StatusUpdatedAt = r.IsDBNull(r.GetOrdinal("status_updated_at")) ? (DateTime?)null : r.GetDateTime(r.GetOrdinal("status_updated_at")),
                                CustomerName = r.GetString(r.GetOrdinal("customer_name")),
                                CustomerEmail = r.IsDBNull(13) ? "—" : r.GetString(13),
                                CustomerPhone = r.GetString(r.GetOrdinal("phone")),
                                CustomerSince = r.IsDBNull(r.GetOrdinal("created_at")) ? DateTime.MinValue : r.GetDateTime(r.GetOrdinal("created_at"))
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
                            COALESCE(p.category, '—') AS category,
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
                            string name = r.GetString(0);
                            string category = r.GetString(1);
                            int qty = r.GetInt32(2);
                            decimal price = Convert.ToDecimal(r[3]);

                            list.Add(new OrderItemDetail
                            {
                                ProductName = name,
                                Category = category,
                                Quantity = qty,
                                UnitPrice = price,
                                UnitPriceFmt = "RM " + price.ToString("N2"),
                                SubtotalFmt = "RM " + (price * qty).ToString("N2")
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
                            COUNT(*) AS total,
                            COUNT(*) FILTER (WHERE status = 'pending') AS pending,
                            COUNT(*) FILTER (WHERE status = 'shipped') AS shipped,
                            COUNT(*) FILTER (WHERE status = 'delivered') AS delivered,
                            COALESCE(SUM(total_amount) FILTER (WHERE status <> 'cancelled'), 0) AS revenue
                        FROM orders";

                    using (DbDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            return new OrderStats
                            {
                                Total = Convert.ToInt32(r[0]),
                                Pending = Convert.ToInt32(r[1]),
                                Shipped = Convert.ToInt32(r[2]),
                                Delivered = Convert.ToInt32(r[3]),
                                Revenue = Convert.ToDecimal(r[4])
                            };
                        }
                    }
                }
            }
            return new OrderStats();
        }

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

        public IList<Order> GetOrdersForUser(long userId, string status, int limit)
        {
            var orders = new List<Order>();
            var orderLookup = new Dictionary<long, Order>();

            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT
                            o.id,
                            o.user_id,
                            o.status,
                            o.subtotal_amount,
                            o.discount_amount,
                            o.total_amount,
                            o.voucher_id,
                            o.voucher_code,
                            o.voucher_name,
                            o.shipping_address,
                            o.delivery_method,
                            o.stripe_checkout_session_id,
                            o.stripe_payment_intent_id,
                            o.payment_method,
                            o.payment_expires_at,
                            o.paid_at,
                            o.receipt_s3_key,
                            o.ordered_at,
                            oi.order_item_id,
                            oi.product_id,
                            oi.product_variant_id,
                            oi.quantity,
                            oi.unit_price,
                            p.name AS product_name,
                            pv.variant_value
                        FROM (
                            SELECT *
                            FROM orders
                            WHERE user_id = @UserId
                              AND (@Status IS NULL OR status = @Status)
                            ORDER BY ordered_at DESC, id DESC
                            LIMIT @Limit
                        ) o
                        LEFT JOIN order_items oi ON oi.order_id = o.id
                        LEFT JOIN products p ON p.id = oi.product_id
                        LEFT JOIN product_variants pv ON pv.product_variant_id = oi.product_variant_id
                        ORDER BY o.ordered_at DESC, o.id DESC, oi.order_item_id ASC";
                    cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));
                    cmd.Parameters.Add(new NpgsqlParameter("@Status", NpgsqlTypes.NpgsqlDbType.Varchar)
                    {
                        Value = string.IsNullOrWhiteSpace(status) ? (object)DBNull.Value : status
                    });
                    cmd.Parameters.Add(new NpgsqlParameter("@Limit", Math.Max(limit, 1)));

                    using (DbDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            long orderId = reader.GetInt64(reader.GetOrdinal("id"));
                            if (!orderLookup.TryGetValue(orderId, out Order order))
                            {
                                order = MapOrderHeader(reader);
                                orderLookup.Add(orderId, order);
                                orders.Add(order);
                            }

                            if (!reader.IsDBNull(reader.GetOrdinal("order_item_id")))
                            {
                                order.Items.Add(MapOrderHistoryItem(reader));
                            }
                        }
                    }
                }
            }

            return orders;
        }

        public Order GetOrderForUser(long orderId, long userId)
        {
            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT
                            id, user_id, status, subtotal_amount, discount_amount, total_amount, voucher_id, voucher_code, voucher_name, shipping_address, delivery_method,
                            stripe_checkout_session_id, stripe_payment_intent_id, payment_method,
                            payment_expires_at, paid_at, receipt_s3_key, ordered_at
                        FROM orders
                        WHERE id = @OrderId AND user_id = @UserId";
                    cmd.Parameters.Add(new NpgsqlParameter("@OrderId", orderId));
                    cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));

                    using (DbDataReader reader = cmd.ExecuteReader())
                    {
                        return reader.Read() ? MapOrderHeader(reader) : null;
                    }
                }
            }
        }

        public IList<Product> GetPurchasedProductsForUser(long userId)
        {
            var products = new List<Product>();

            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT DISTINCT
                            p.id,
                            p.name,
                            p.brand,
                            p.category,
                            p.description,
                            p.price,
                            p.stock_qty,
                            p.image_url,
                            p.created_at
                        FROM orders o
                        INNER JOIN order_items oi ON oi.order_id = o.id
                        INNER JOIN products p ON p.id = oi.product_id
                        WHERE o.user_id = @UserId
                          AND o.status = @PaidStatus
                        ORDER BY p.name ASC";
                    cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));
                    cmd.Parameters.Add(new NpgsqlParameter("@PaidStatus", OrderStatuses.Paid));

                    using (DbDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            products.Add(MapProduct(reader));
                        }
                    }
                }
            }

            return products;
        }

        public bool HasPurchasedProduct(long userId, long productId)
        {
            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT 1
                        FROM orders o
                        INNER JOIN order_items oi ON oi.order_id = o.id
                        WHERE o.user_id = @UserId
                          AND oi.product_id = @ProductId
                          AND o.status = @PaidStatus
                        LIMIT 1";
                    cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));
                    cmd.Parameters.Add(new NpgsqlParameter("@ProductId", productId));
                    cmd.Parameters.Add(new NpgsqlParameter("@PaidStatus", OrderStatuses.Paid));
                    object result = cmd.ExecuteScalar();
                    return result != null;
                }
            }
        }

        public long CreateOrder(long userId, decimal totalAmount, string shippingAddress, string receiptS3Key, IList<CartItem> cartItems)
        {
            if (cartItems == null || cartItems.Count == 0)
            {
                throw new InvalidOperationException("Cannot create an order from an empty cart.");
            }

            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbTransaction tx = conn.BeginTransaction())
                {
                    try
                    {
                        long orderId = InsertOrder(conn, tx, userId, totalAmount, shippingAddress, receiptS3Key);

                        foreach (CartItem item in cartItems)
                        {
                            InsertOrderItem(conn, tx, orderId, item);
                        }

                        tx.Commit();
                        return orderId;
                    }
                    catch
                    {
                        tx.Rollback();
                        throw;
                    }
                }
            }
        }

        private static long InsertOrder(DbConnection conn, DbTransaction tx, long userId, decimal totalAmount, string shippingAddress, string receiptS3Key)
        {
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = @"
                    INSERT INTO orders (user_id, status, subtotal_amount, discount_amount, total_amount, shipping_address, receipt_s3_key)
                    VALUES (@UserId, @Status, @TotalAmount, @DiscountAmount, @TotalAmount, @ShippingAddress, @ReceiptS3Key)
                    RETURNING id";
                cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));
                cmd.Parameters.Add(new NpgsqlParameter("@Status", OrderStatuses.Paid));
                cmd.Parameters.Add(new NpgsqlParameter("@TotalAmount", totalAmount));
                cmd.Parameters.Add(new NpgsqlParameter("@DiscountAmount", (object)0m));
                cmd.Parameters.Add(new NpgsqlParameter("@ShippingAddress", shippingAddress));
                cmd.Parameters.Add(new NpgsqlParameter("@ReceiptS3Key", string.IsNullOrWhiteSpace(receiptS3Key) ? (object)DBNull.Value : receiptS3Key));

                return Convert.ToInt64(cmd.ExecuteScalar());
            }
        }

        private static void InsertOrderItem(DbConnection conn, DbTransaction tx, long orderId, CartItem item)
        {
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = @"
                    INSERT INTO order_items (order_id, product_id, product_variant_id, quantity, unit_price)
                    VALUES (@OrderId, @ProductId, @ProductVariantId, @Quantity, @UnitPrice)";
                cmd.Parameters.Add(new NpgsqlParameter("@OrderId", orderId));
                cmd.Parameters.Add(new NpgsqlParameter("@ProductId", item.ProductId));
                cmd.Parameters.Add(new NpgsqlParameter("@ProductVariantId", item.VariantId.HasValue ? (object)item.VariantId.Value : DBNull.Value));
                cmd.Parameters.Add(new NpgsqlParameter("@Quantity", item.Quantity));
                cmd.Parameters.Add(new NpgsqlParameter("@UnitPrice", item.Price));
                cmd.ExecuteNonQuery();
            }
        }

        public Invoice GetInvoice(long orderId, long userId)
        {
            Invoice invoice = null;

            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT
                            o.id,
                            o.user_id,
                            o.status,
                            o.subtotal_amount,
                            o.discount_amount,
                            o.total_amount,
                            o.voucher_id,
                            o.voucher_code,
                            o.voucher_name,
                            o.shipping_address,
                            o.delivery_method,
                            o.stripe_checkout_session_id,
                            o.stripe_payment_intent_id,
                            o.payment_method,
                            o.payment_expires_at,
                            o.paid_at,
                            o.receipt_s3_key,
                            o.ordered_at,
                            u.fullname,
                            u.username,
                            u.email,
                            u.address,
                            u.phone_number,
                            oi.order_item_id,
                            oi.product_id,
                            oi.product_variant_id,
                            oi.quantity,
                            oi.unit_price,
                            p.name AS product_name,
                            pv.variant_value
                        FROM orders o
                        JOIN users u ON u.id = o.user_id
                        LEFT JOIN order_items oi ON oi.order_id = o.id
                        LEFT JOIN products p ON p.id = oi.product_id
                        LEFT JOIN product_variants pv ON pv.product_variant_id = oi.product_variant_id
                        WHERE o.id = @OrderId
                          AND o.user_id = @UserId
                          AND o.status = @PaidStatus
                        ORDER BY oi.order_item_id ASC";
                    cmd.Parameters.Add(new NpgsqlParameter("@OrderId", orderId));
                    cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));
                    cmd.Parameters.Add(new NpgsqlParameter("@PaidStatus", OrderStatuses.Paid));

                    using (DbDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            if (invoice == null)
                            {
                                invoice = MapInvoiceHeader(reader);
                            }

                            if (!reader.IsDBNull(reader.GetOrdinal("order_item_id")))
                            {
                                invoice.Order.Items.Add(MapInvoiceItem(reader));
                            }
                        }
                    }
                }
            }

            return invoice;
        }

        public bool TryMarkCheckoutSuccessEmailSent(long orderId, long userId)
        {
            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        UPDATE orders
                        SET checkout_success_email_sent_at = now()
                        WHERE id = @OrderId
                          AND user_id = @UserId
                          AND status = @PaidStatus
                          AND checkout_success_email_sent_at IS NULL";
                    cmd.Parameters.Add(new NpgsqlParameter("@OrderId", orderId));
                    cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));
                    cmd.Parameters.Add(new NpgsqlParameter("@PaidStatus", OrderStatuses.Paid));
                    return cmd.ExecuteNonQuery() == 1;
                }
            }
        }

        public void ClearCheckoutSuccessEmailSent(long orderId, long userId)
        {
            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        UPDATE orders
                        SET checkout_success_email_sent_at = NULL
                        WHERE id = @OrderId
                          AND user_id = @UserId
                          AND status = @PaidStatus";
                    cmd.Parameters.Add(new NpgsqlParameter("@OrderId", orderId));
                    cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));
                    cmd.Parameters.Add(new NpgsqlParameter("@PaidStatus", OrderStatuses.Paid));
                    cmd.ExecuteNonQuery();
                }
            }
        }

        private static Invoice MapInvoiceHeader(DbDataReader reader)
        {
            return new Invoice
            {
                Order = new Order
                {
                    Id = reader.GetInt64(reader.GetOrdinal("id")),
                    UserId = reader.GetInt64(reader.GetOrdinal("user_id")),
                    Status = reader.GetString(reader.GetOrdinal("status")),
                    SubtotalAmount = reader.GetDecimal(reader.GetOrdinal("subtotal_amount")),
                    DiscountAmount = reader.GetDecimal(reader.GetOrdinal("discount_amount")),
                    TotalAmount = reader.GetDecimal(reader.GetOrdinal("total_amount")),
                    VoucherId = reader.IsDBNull(reader.GetOrdinal("voucher_id")) ? (long?)null : reader.GetInt64(reader.GetOrdinal("voucher_id")),
                    VoucherCode = ReadNullableString(reader, "voucher_code"),
                    VoucherName = ReadNullableString(reader, "voucher_name"),
                    ShippingAddress = reader.GetString(reader.GetOrdinal("shipping_address")),
                    DeliveryMethod = ReadNullableString(reader, "delivery_method"),
                    StripeCheckoutSessionId = ReadNullableString(reader, "stripe_checkout_session_id"),
                    StripePaymentIntentId = ReadNullableString(reader, "stripe_payment_intent_id"),
                    PaymentMethod = ReadNullableString(reader, "payment_method"),
                    PaymentExpiresAt = ReadNullableDateTimeOffset(reader, "payment_expires_at"),
                    PaidAt = ReadNullableDateTimeOffset(reader, "paid_at"),
                    ReceiptS3Key = reader.IsDBNull(reader.GetOrdinal("receipt_s3_key")) ? null : reader.GetString(reader.GetOrdinal("receipt_s3_key")),
                    OrderedAt = reader.GetDateTime(reader.GetOrdinal("ordered_at"))
                },
                Customer = new User
                {
                    Id = reader.GetInt64(reader.GetOrdinal("user_id")),
                    FullName = reader.IsDBNull(reader.GetOrdinal("fullname")) ? string.Empty : reader.GetString(reader.GetOrdinal("fullname")),
                    Username = reader.IsDBNull(reader.GetOrdinal("username")) ? string.Empty : reader.GetString(reader.GetOrdinal("username")),
                    Email = reader.IsDBNull(reader.GetOrdinal("email")) ? string.Empty : reader.GetString(reader.GetOrdinal("email")),
                    Address = reader.IsDBNull(reader.GetOrdinal("address")) ? string.Empty : reader.GetString(reader.GetOrdinal("address")),
                    PhoneNumber = reader.IsDBNull(reader.GetOrdinal("phone_number")) ? string.Empty : reader.GetString(reader.GetOrdinal("phone_number"))
                }
            };
        }

        private static Order MapOrderHeader(DbDataReader reader)
        {
            return new Order
            {
                Id = reader.GetInt64(reader.GetOrdinal("id")),
                UserId = reader.GetInt64(reader.GetOrdinal("user_id")),
                Status = reader.GetString(reader.GetOrdinal("status")),
                SubtotalAmount = reader.GetDecimal(reader.GetOrdinal("subtotal_amount")),
                DiscountAmount = reader.GetDecimal(reader.GetOrdinal("discount_amount")),
                TotalAmount = reader.GetDecimal(reader.GetOrdinal("total_amount")),
                VoucherId = reader.IsDBNull(reader.GetOrdinal("voucher_id")) ? (long?)null : reader.GetInt64(reader.GetOrdinal("voucher_id")),
                VoucherCode = ReadNullableString(reader, "voucher_code"),
                VoucherName = ReadNullableString(reader, "voucher_name"),
                ShippingAddress = reader.GetString(reader.GetOrdinal("shipping_address")),
                DeliveryMethod = ReadNullableString(reader, "delivery_method"),
                StripeCheckoutSessionId = ReadNullableString(reader, "stripe_checkout_session_id"),
                StripePaymentIntentId = ReadNullableString(reader, "stripe_payment_intent_id"),
                PaymentMethod = ReadNullableString(reader, "payment_method"),
                PaymentExpiresAt = ReadNullableDateTimeOffset(reader, "payment_expires_at"),
                PaidAt = ReadNullableDateTimeOffset(reader, "paid_at"),
                ReceiptS3Key = reader.IsDBNull(reader.GetOrdinal("receipt_s3_key")) ? null : reader.GetString(reader.GetOrdinal("receipt_s3_key")),
                OrderedAt = reader.GetDateTime(reader.GetOrdinal("ordered_at"))
            };
        }

        private static string ReadNullableString(DbDataReader reader, string columnName)
        {
            int ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? null : reader.GetString(ordinal);
        }

        private static DateTimeOffset? ReadNullableDateTimeOffset(DbDataReader reader, string columnName)
        {
            int ordinal = reader.GetOrdinal(columnName);
            if (reader.IsDBNull(ordinal))
            {
                return null;
            }

            object value = reader.GetValue(ordinal);
            if (value is DateTimeOffset)
            {
                return (DateTimeOffset)value;
            }

            if (value is DateTime)
            {
                DateTime dateTime = (DateTime)value;
                if (dateTime.Kind == DateTimeKind.Unspecified)
                {
                    dateTime = DateTime.SpecifyKind(dateTime, DateTimeKind.Utc);
                }

                return new DateTimeOffset(dateTime).ToUniversalTime();
            }

            return DateTimeOffset.Parse(
                Convert.ToString(value, System.Globalization.CultureInfo.InvariantCulture),
                System.Globalization.CultureInfo.InvariantCulture,
                System.Globalization.DateTimeStyles.AssumeUniversal |
                System.Globalization.DateTimeStyles.AdjustToUniversal);
        }

        private static OrderItem MapOrderHistoryItem(DbDataReader reader)
        {
            long? variantId = reader.IsDBNull(reader.GetOrdinal("product_variant_id"))
                ? (long?)null
                : reader.GetInt64(reader.GetOrdinal("product_variant_id"));

            string productName = reader.IsDBNull(reader.GetOrdinal("product_name"))
                ? $"Product #{reader.GetInt64(reader.GetOrdinal("product_id"))}"
                : reader.GetString(reader.GetOrdinal("product_name"));

            string variantValue = reader.IsDBNull(reader.GetOrdinal("variant_value"))
                ? null
                : reader.GetString(reader.GetOrdinal("variant_value"));

            return new OrderItem
            {
                OrderItemId = reader.GetInt64(reader.GetOrdinal("order_item_id")),
                OrderId = reader.GetInt64(reader.GetOrdinal("id")),
                ProductId = reader.GetInt64(reader.GetOrdinal("product_id")),
                ProductVariantId = variantId,
                ProductName = string.IsNullOrWhiteSpace(variantValue) ? productName : $"{productName} ({variantValue})",
                Quantity = reader.GetInt32(reader.GetOrdinal("quantity")),
                UnitPrice = reader.GetDecimal(reader.GetOrdinal("unit_price"))
            };
        }

        private static Product MapProduct(DbDataReader reader)
        {
            return new Product
            {
                Id = reader.GetInt64(reader.GetOrdinal("id")),
                Name = reader.GetString(reader.GetOrdinal("name")),
                Brand = reader.IsDBNull(reader.GetOrdinal("brand")) ? null : reader.GetString(reader.GetOrdinal("brand")),
                Category = reader.GetString(reader.GetOrdinal("category")),
                Description = reader.IsDBNull(reader.GetOrdinal("description")) ? null : reader.GetString(reader.GetOrdinal("description")),
                Price = reader.GetDecimal(reader.GetOrdinal("price")),
                StockQty = reader.GetInt32(reader.GetOrdinal("stock_qty")),
                ImageUrl = reader.IsDBNull(reader.GetOrdinal("image_url")) ? null : reader.GetString(reader.GetOrdinal("image_url")),
                CreatedAt = reader.GetDateTime(reader.GetOrdinal("created_at"))
            };
        }

        private static OrderItem MapInvoiceItem(DbDataReader reader)
        {
            long? variantId = reader.IsDBNull(reader.GetOrdinal("product_variant_id"))
                ? (long?)null
                : reader.GetInt64(reader.GetOrdinal("product_variant_id"));
            string productName = reader.IsDBNull(reader.GetOrdinal("product_name"))
                ? $"Product #{reader.GetInt64(reader.GetOrdinal("product_id"))}"
                : reader.GetString(reader.GetOrdinal("product_name"));
            string variantValue = reader.IsDBNull(reader.GetOrdinal("variant_value"))
                ? null
                : reader.GetString(reader.GetOrdinal("variant_value"));

            return new OrderItem
            {
                OrderItemId = reader.GetInt64(reader.GetOrdinal("order_item_id")),
                OrderId = reader.GetInt64(reader.GetOrdinal("id")),
                ProductId = reader.GetInt64(reader.GetOrdinal("product_id")),
                ProductVariantId = variantId,
                ProductName = string.IsNullOrWhiteSpace(variantValue) ? productName : $"{productName} ({variantValue})",
                Quantity = reader.GetInt32(reader.GetOrdinal("quantity")),
                UnitPrice = reader.GetDecimal(reader.GetOrdinal("unit_price"))
            };
        }
    }
}
