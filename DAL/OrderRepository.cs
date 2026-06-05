using System;
using System.Collections.Generic;
using System.Data.Common;
using Npgsql;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.DAL
{
    public class OrderRepository
    {
        public IList<Order> GetOrdersForUser(long userId, int limit)
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
                            o.total_amount,
                            o.shipping_address,
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
                            ORDER BY ordered_at DESC, id DESC
                            LIMIT @Limit
                        ) o
                        LEFT JOIN order_items oi ON oi.order_id = o.id
                        LEFT JOIN products p ON p.id = oi.product_id
                        LEFT JOIN product_variants pv ON pv.product_variant_id = oi.product_variant_id
                        ORDER BY o.ordered_at DESC, o.id DESC, oi.order_item_id ASC";
                    cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));
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
                        ORDER BY p.name ASC";
                    cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));

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
                        LIMIT 1";
                    cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));
                    cmd.Parameters.Add(new NpgsqlParameter("@ProductId", productId));
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
                    INSERT INTO orders (user_id, status, total_amount, shipping_address, receipt_s3_key)
                    VALUES (@UserId, @Status, @TotalAmount, @ShippingAddress, @ReceiptS3Key)
                    RETURNING id";
                cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));
                cmd.Parameters.Add(new NpgsqlParameter("@Status", "paid"));
                cmd.Parameters.Add(new NpgsqlParameter("@TotalAmount", totalAmount));
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
                            o.total_amount,
                            o.shipping_address,
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
                            oi.unit_price
                        FROM orders o
                        JOIN users u ON u.id = o.user_id
                        LEFT JOIN order_items oi ON oi.order_id = o.id
                        WHERE o.id = @OrderId
                          AND o.user_id = @UserId
                        ORDER BY oi.order_item_id ASC";
                    cmd.Parameters.Add(new NpgsqlParameter("@OrderId", orderId));
                    cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));

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

        private static Invoice MapInvoiceHeader(DbDataReader reader)
        {
            return new Invoice
            {
                Order = new Order
                {
                    Id = reader.GetInt64(reader.GetOrdinal("id")),
                    UserId = reader.GetInt64(reader.GetOrdinal("user_id")),
                    Status = reader.GetString(reader.GetOrdinal("status")),
                    TotalAmount = reader.GetDecimal(reader.GetOrdinal("total_amount")),
                    ShippingAddress = reader.GetString(reader.GetOrdinal("shipping_address")),
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
                TotalAmount = reader.GetDecimal(reader.GetOrdinal("total_amount")),
                ShippingAddress = reader.GetString(reader.GetOrdinal("shipping_address")),
                ReceiptS3Key = reader.IsDBNull(reader.GetOrdinal("receipt_s3_key")) ? null : reader.GetString(reader.GetOrdinal("receipt_s3_key")),
                OrderedAt = reader.GetDateTime(reader.GetOrdinal("ordered_at"))
            };
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
            long productId = reader.GetInt64(reader.GetOrdinal("product_id"));
            long? variantId = reader.IsDBNull(reader.GetOrdinal("product_variant_id"))
                ? (long?)null
                : reader.GetInt64(reader.GetOrdinal("product_variant_id"));

            return new OrderItem
            {
                OrderItemId = reader.GetInt64(reader.GetOrdinal("order_item_id")),
                OrderId = reader.GetInt64(reader.GetOrdinal("id")),
                ProductId = productId,
                ProductVariantId = variantId,
                ProductName = variantId.HasValue
                    ? $"Product #{productId} / Variant #{variantId.Value}"
                    : $"Product #{productId}",
                Quantity = reader.GetInt32(reader.GetOrdinal("quantity")),
                UnitPrice = reader.GetDecimal(reader.GetOrdinal("unit_price"))
            };
        }
    }
}
