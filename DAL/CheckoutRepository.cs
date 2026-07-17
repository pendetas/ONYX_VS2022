using System;
using System.Collections.Generic;
using System.Data.Common;
using System.Linq;
using Npgsql;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.DAL
{
    public class CheckoutRepository
    {
        public IList<CartItem> GetValidatedCartForCheckout(long userId)
        {
            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbTransaction tx = conn.BeginTransaction())
                {
                    try
                    {
                        IList<CheckoutItem> items = LoadAuthoritativeCart(conn, tx, userId);
                        ValidateAvailability(conn, tx, items);
                        tx.Commit();
                        return items.Select(ToCartItem).ToList();
                    }
                    catch
                    {
                        tx.Rollback();
                        throw;
                    }
                }
            }
        }

        public Order CreatePendingOrderWithReservations(
            long userId,
            string shippingAddress,
            string deliveryMethod,
            string checkoutAttemptToken,
            string paymentCancellationTokenHash,
            DateTimeOffset expiresAt)
        {
            if (string.IsNullOrWhiteSpace(checkoutAttemptToken))
            {
                throw new ArgumentException("Checkout attempt token is required.", nameof(checkoutAttemptToken));
            }
            if (string.IsNullOrWhiteSpace(paymentCancellationTokenHash))
            {
                throw new ArgumentException("Payment cancellation token hash is required.", nameof(paymentCancellationTokenHash));
            }

            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbTransaction tx = conn.BeginTransaction())
                {
                    try
                    {
                        LockUserCheckout(conn, tx, userId);

                        if (HasDifferentActivePendingOrder(
                            conn,
                            tx,
                            userId,
                            checkoutAttemptToken))
                        {
                            throw new ActiveCheckoutAttemptException();
                        }

                        Order activeOrder = FindActivePendingOrder(
                            conn,
                            tx,
                            userId,
                            checkoutAttemptToken);
                        if (activeOrder != null)
                        {
                            if (string.IsNullOrWhiteSpace(activeOrder.StripeCheckoutSessionId))
                            {
                                ReplacePaymentCancellationTokenHash(
                                    conn,
                                    tx,
                                    activeOrder.Id,
                                    userId,
                                    paymentCancellationTokenHash);
                                activeOrder.PaymentCancellationTokenHash = paymentCancellationTokenHash;
                            }

                            tx.Commit();
                            return activeOrder;
                        }

                        IList<CartIdentity> identities = LockCartRows(conn, tx, userId);
                        if (identities.Count == 0)
                        {
                            throw new InvalidOperationException("Your cart is empty.");
                        }

                        LockStockRows(conn, tx, identities);
                        IList<CheckoutItem> items = LoadAuthoritativeCart(conn, tx, userId);
                        ValidateAvailability(conn, tx, items);

                        decimal totalAmount = items.Sum(item => item.UnitPrice * item.Quantity);
                        long orderId = InsertPendingOrder(
                            conn,
                            tx,
                            userId,
                            totalAmount,
                            shippingAddress,
                            deliveryMethod,
                            checkoutAttemptToken,
                            paymentCancellationTokenHash,
                            expiresAt);

                        foreach (CheckoutItem item in items)
                        {
                            InsertOrderItem(conn, tx, orderId, item);
                            InsertReservation(conn, tx, orderId, item, expiresAt);
                        }

                        RemoveCheckedOutCartItems(conn, tx, userId, items);

                        tx.Commit();
                        return new Order
                        {
                            Id = orderId,
                            UserId = userId,
                            Status = OrderStatuses.PendingPayment,
                            TotalAmount = totalAmount,
                            ShippingAddress = shippingAddress,
                            DeliveryMethod = deliveryMethod,
                            CheckoutAttemptToken = checkoutAttemptToken,
                            PaymentCancellationTokenHash = paymentCancellationTokenHash,
                            PaymentExpiresAt = expiresAt,
                            Items = items.Select(ToOrderItem).ToList()
                        };
                    }
                    catch
                    {
                        tx.Rollback();
                        throw;
                    }
                }
            }
        }

        public void SaveStripeSession(
            long orderId,
            long userId,
            string sessionId,
            DateTimeOffset expiresAt)
        {
            if (string.IsNullOrWhiteSpace(sessionId))
            {
                throw new ArgumentException("Stripe Checkout Session ID is required.", nameof(sessionId));
            }

            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbTransaction tx = conn.BeginTransaction())
                {
                    try
                    {
                        using (DbCommand cmd = conn.CreateCommand())
                        {
                            cmd.Transaction = tx;
                            cmd.CommandText = @"
                                UPDATE orders
                                SET stripe_checkout_session_id = @SessionId,
                                    payment_expires_at = @ExpiresAt
                                WHERE id = @OrderId
                                  AND user_id = @UserId
                                  AND status = @PendingStatus
                                  AND (stripe_checkout_session_id IS NULL OR stripe_checkout_session_id = @SessionId)";
                            cmd.Parameters.Add(new NpgsqlParameter("@SessionId", sessionId));
                            cmd.Parameters.Add(new NpgsqlParameter("@ExpiresAt", expiresAt));
                            cmd.Parameters.Add(new NpgsqlParameter("@OrderId", orderId));
                            cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));
                            cmd.Parameters.Add(new NpgsqlParameter("@PendingStatus", OrderStatuses.PendingPayment));

                            if (cmd.ExecuteNonQuery() != 1)
                            {
                                throw new InvalidOperationException("The pending order could not be linked to Stripe Checkout.");
                            }
                        }

                        using (DbCommand cmd = conn.CreateCommand())
                        {
                            cmd.Transaction = tx;
                            cmd.CommandText = @"
                                UPDATE stock_reservations
                                SET expires_at = @ExpiresAt
                                WHERE order_id = @OrderId
                                  AND status = @ActiveStatus";
                            cmd.Parameters.Add(new NpgsqlParameter("@ExpiresAt", expiresAt));
                            cmd.Parameters.Add(new NpgsqlParameter("@OrderId", orderId));
                            cmd.Parameters.Add(new NpgsqlParameter("@ActiveStatus", StockReservation.Active));
                            cmd.ExecuteNonQuery();
                        }

                        tx.Commit();
                    }
                    catch
                    {
                        tx.Rollback();
                        throw;
                    }
                }
            }
        }

        private static void LockUserCheckout(DbConnection conn, DbTransaction tx, long userId)
        {
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = "SELECT pg_advisory_xact_lock(@UserId)";
                cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));
                cmd.ExecuteNonQuery();
            }
        }

        private static bool HasDifferentActivePendingOrder(
            DbConnection conn,
            DbTransaction tx,
            long userId,
            string checkoutAttemptToken)
        {
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = @"
                    SELECT EXISTS (
                        SELECT 1
                        FROM orders
                        WHERE user_id = @UserId
                          AND status = @PendingStatus
                          AND payment_expires_at > now()
                          AND checkout_attempt_token IS DISTINCT FROM @CheckoutAttemptToken
                    )";
                cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));
                cmd.Parameters.Add(new NpgsqlParameter("@PendingStatus", OrderStatuses.PendingPayment));
                cmd.Parameters.Add(new NpgsqlParameter("@CheckoutAttemptToken", checkoutAttemptToken));
                return Convert.ToBoolean(cmd.ExecuteScalar());
            }
        }

        private static Order FindActivePendingOrder(
            DbConnection conn,
            DbTransaction tx,
            long userId,
            string checkoutAttemptToken)
        {
            Order order = null;
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = @"
                    SELECT
                        id,
                        status,
                        total_amount,
                        shipping_address,
                        delivery_method,
                        checkout_attempt_token,
                        payment_cancel_token_hash,
                        stripe_checkout_session_id,
                        payment_expires_at
                    FROM orders
                    WHERE user_id = @UserId
                      AND status = @PendingStatus
                      AND payment_expires_at > now()
                      AND checkout_attempt_token = @CheckoutAttemptToken
                    ORDER BY id DESC
                    LIMIT 1
                    FOR UPDATE";
                cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));
                cmd.Parameters.Add(new NpgsqlParameter("@PendingStatus", OrderStatuses.PendingPayment));
                cmd.Parameters.Add(new NpgsqlParameter("@CheckoutAttemptToken", checkoutAttemptToken));

                using (DbDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        order = new Order
                        {
                            Id = reader.GetInt64(reader.GetOrdinal("id")),
                            UserId = userId,
                            Status = reader.GetString(reader.GetOrdinal("status")),
                            TotalAmount = reader.GetDecimal(reader.GetOrdinal("total_amount")),
                            ShippingAddress = reader.GetString(reader.GetOrdinal("shipping_address")),
                            DeliveryMethod = ReadNullableString(reader, "delivery_method"),
                            CheckoutAttemptToken = ReadNullableString(reader, "checkout_attempt_token"),
                            PaymentCancellationTokenHash = ReadNullableString(reader, "payment_cancel_token_hash"),
                            StripeCheckoutSessionId = ReadNullableString(reader, "stripe_checkout_session_id"),
                            PaymentExpiresAt = ReadDateTimeOffset(reader, "payment_expires_at"),
                            IsExistingCheckoutAttempt = true
                        };
                    }
                }
            }

            if (order == null)
            {
                return null;
            }

            order.Items = LoadOrderItems(conn, tx, order.Id);
            return order;
        }

        private static void ReplacePaymentCancellationTokenHash(
            DbConnection conn,
            DbTransaction tx,
            long orderId,
            long userId,
            string paymentCancellationTokenHash)
        {
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = @"
                    UPDATE orders
                    SET payment_cancel_token_hash = @PaymentCancellationTokenHash
                    WHERE id = @OrderId
                      AND user_id = @UserId
                      AND status = @PendingStatus
                      AND stripe_checkout_session_id IS NULL";
                cmd.Parameters.Add(new NpgsqlParameter("@PaymentCancellationTokenHash", paymentCancellationTokenHash));
                cmd.Parameters.Add(new NpgsqlParameter("@OrderId", orderId));
                cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));
                cmd.Parameters.Add(new NpgsqlParameter("@PendingStatus", OrderStatuses.PendingPayment));
                if (cmd.ExecuteNonQuery() != 1)
                {
                    throw new InvalidOperationException("The pending order cancellation token could not be updated.");
                }
            }
        }

        public Order GetPendingOrderForCancellation(long orderId, long userId)
        {
            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT id, user_id, status, stripe_checkout_session_id, payment_cancel_token_hash
                        FROM orders
                        WHERE id = @OrderId
                          AND user_id = @UserId
                          AND status = @PendingStatus
                          AND payment_cancel_token_hash IS NOT NULL";
                    cmd.Parameters.Add(new NpgsqlParameter("@OrderId", orderId));
                    cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));
                    cmd.Parameters.Add(new NpgsqlParameter("@PendingStatus", OrderStatuses.PendingPayment));

                    using (DbDataReader reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            return null;
                        }

                        return new Order
                        {
                            Id = reader.GetInt64(reader.GetOrdinal("id")),
                            UserId = reader.GetInt64(reader.GetOrdinal("user_id")),
                            Status = reader.GetString(reader.GetOrdinal("status")),
                            StripeCheckoutSessionId = ReadNullableString(reader, "stripe_checkout_session_id"),
                            PaymentCancellationTokenHash = ReadNullableString(reader, "payment_cancel_token_hash")
                        };
                    }
                }
            }
        }

        private static IList<OrderItem> LoadOrderItems(DbConnection conn, DbTransaction tx, long orderId)
        {
            var items = new List<OrderItem>();
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = @"
                    SELECT
                        oi.product_id,
                        oi.product_variant_id,
                        oi.quantity,
                        oi.unit_price,
                        p.name,
                        pv.variant_value
                    FROM order_items oi
                    INNER JOIN products p ON p.id = oi.product_id
                    LEFT JOIN product_variants pv
                        ON pv.product_variant_id = oi.product_variant_id
                       AND pv.product_id = oi.product_id
                    WHERE oi.order_id = @OrderId
                    ORDER BY oi.order_item_id";
                cmd.Parameters.Add(new NpgsqlParameter("@OrderId", orderId));

                using (DbDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string name = reader.GetString(reader.GetOrdinal("name"));
                        string variantValue = ReadNullableString(reader, "variant_value");
                        items.Add(new OrderItem
                        {
                            ProductId = reader.GetInt64(reader.GetOrdinal("product_id")),
                            ProductVariantId = reader.IsDBNull(reader.GetOrdinal("product_variant_id"))
                                ? (long?)null
                                : reader.GetInt64(reader.GetOrdinal("product_variant_id")),
                            ProductName = string.IsNullOrWhiteSpace(variantValue)
                                ? name
                                : name + " (" + variantValue + ")",
                            Quantity = reader.GetInt32(reader.GetOrdinal("quantity")),
                            UnitPrice = reader.GetDecimal(reader.GetOrdinal("unit_price"))
                        });
                    }
                }
            }

            return items;
        }

        private static string ReadNullableString(DbDataReader reader, string columnName)
        {
            int ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? null : reader.GetString(ordinal);
        }

        private static DateTimeOffset ReadDateTimeOffset(DbDataReader reader, string columnName)
        {
            object value = reader.GetValue(reader.GetOrdinal(columnName));
            if (value is DateTimeOffset)
            {
                return (DateTimeOffset)value;
            }

            DateTime dateTime = (DateTime)value;
            if (dateTime.Kind == DateTimeKind.Unspecified)
            {
                dateTime = DateTime.SpecifyKind(dateTime, DateTimeKind.Utc);
            }

            return new DateTimeOffset(dateTime).ToUniversalTime();
        }

        public void CancelPendingOrderAndReleaseReservations(long orderId, long userId)
        {
            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbTransaction tx = conn.BeginTransaction())
                {
                    try
                    {
                        LockUserCheckout(conn, tx, userId);
                        LockPendingOrderForCancellation(conn, tx, orderId, userId);
                        CartRepository.RestoreCartItems(conn, tx, userId, orderId);

                        using (DbCommand release = conn.CreateCommand())
                        {
                            release.Transaction = tx;
                            release.CommandText = @"
                                UPDATE stock_reservations
                                SET status = @ReleasedStatus
                                WHERE order_id = @OrderId
                                  AND status = @ActiveStatus";
                            release.Parameters.Add(new NpgsqlParameter("@OrderId", orderId));
                            release.Parameters.Add(new NpgsqlParameter("@ActiveStatus", StockReservation.Active));
                            release.Parameters.Add(new NpgsqlParameter("@ReleasedStatus", StockReservation.Released));
                            release.ExecuteNonQuery();
                        }

                        using (DbCommand cancel = conn.CreateCommand())
                        {
                            cancel.Transaction = tx;
                            cancel.CommandText = @"
                                UPDATE orders
                                SET status = @CancelledStatus,
                                    payment_cancel_token_hash = NULL
                                WHERE id = @OrderId
                                  AND user_id = @UserId
                                  AND status = @PendingStatus";
                            cancel.Parameters.Add(new NpgsqlParameter("@OrderId", orderId));
                            cancel.Parameters.Add(new NpgsqlParameter("@UserId", userId));
                            cancel.Parameters.Add(new NpgsqlParameter("@PendingStatus", OrderStatuses.PendingPayment));
                            cancel.Parameters.Add(new NpgsqlParameter("@CancelledStatus", OrderStatuses.Cancelled));
                            if (cancel.ExecuteNonQuery() != 1)
                            {
                                throw new InvalidOperationException("The pending order could not be cancelled.");
                            }
                        }

                        tx.Commit();
                    }
                    catch
                    {
                        tx.Rollback();
                        throw;
                    }
                }
            }
        }

        private static void LockPendingOrderForCancellation(
            DbConnection conn,
            DbTransaction tx,
            long orderId,
            long userId)
        {
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = @"
                    SELECT id
                    FROM orders
                    WHERE id = @OrderId
                      AND user_id = @UserId
                      AND status = @PendingStatus
                    FOR UPDATE";
                cmd.Parameters.Add(new NpgsqlParameter("@OrderId", orderId));
                cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));
                cmd.Parameters.Add(new NpgsqlParameter("@PendingStatus", OrderStatuses.PendingPayment));
                if (cmd.ExecuteScalar() == null)
                {
                    throw new InvalidOperationException("The pending order could not be cancelled.");
                }
            }
        }

        private static IList<CartIdentity> LockCartRows(DbConnection conn, DbTransaction tx, long userId)
        {
            var identities = new List<CartIdentity>();
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = @"
                    SELECT product_id, product_variant_id
                    FROM cart
                    WHERE user_id = @UserId
                    ORDER BY product_id, variant_key
                    FOR UPDATE";
                cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));

                using (DbDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        identities.Add(new CartIdentity
                        {
                            ProductId = reader.GetInt64(0),
                            VariantId = reader.IsDBNull(1) ? (long?)null : reader.GetInt64(1)
                        });
                    }
                }
            }

            return identities;
        }

        private static void LockStockRows(DbConnection conn, DbTransaction tx, IList<CartIdentity> identities)
        {
            foreach (long productId in identities.Select(item => item.ProductId).Distinct().OrderBy(id => id))
            {
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.Transaction = tx;
                    cmd.CommandText = "SELECT id FROM products WHERE id = @ProductId FOR UPDATE";
                    cmd.Parameters.Add(new NpgsqlParameter("@ProductId", productId));
                    if (cmd.ExecuteScalar() == null)
                    {
                        throw new InvalidOperationException("A product in your cart is no longer available.");
                    }
                }
            }

            foreach (CartIdentity item in identities.Where(item => item.VariantId.HasValue).OrderBy(item => item.VariantId.Value))
            {
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.Transaction = tx;
                    cmd.CommandText = @"
                        SELECT product_variant_id
                        FROM product_variants
                        WHERE product_variant_id = @VariantId
                          AND product_id = @ProductId
                        FOR UPDATE";
                    cmd.Parameters.Add(new NpgsqlParameter("@VariantId", item.VariantId.Value));
                    cmd.Parameters.Add(new NpgsqlParameter("@ProductId", item.ProductId));
                    if (cmd.ExecuteScalar() == null)
                    {
                        throw new InvalidOperationException("A product option in your cart is no longer available.");
                    }
                }
            }
        }

        private static IList<CheckoutItem> LoadAuthoritativeCart(DbConnection conn, DbTransaction tx, long userId)
        {
            var items = new List<CheckoutItem>();
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = @"
                    SELECT
                        c.product_id,
                        c.product_variant_id,
                        c.quantity,
                        p.name AS product_name,
                        p.category AS product_category,
                        p.price AS product_price,
                        p.stock_qty AS product_stock,
                        p.image_url AS product_image_url,
                        pv.variant_value,
                        pv.variant_price,
                        pv.stock_qty AS variant_stock,
                        pv.image_url AS variant_image_url
                    FROM cart c
                    INNER JOIN products p ON p.id = c.product_id
                    LEFT JOIN product_variants pv
                        ON pv.product_variant_id = c.product_variant_id
                       AND pv.product_id = c.product_id
                    WHERE c.user_id = @UserId
                    ORDER BY c.product_id, c.variant_key";
                cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));

                using (DbDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        long? variantId = reader.IsDBNull(reader.GetOrdinal("product_variant_id"))
                            ? (long?)null
                            : reader.GetInt64(reader.GetOrdinal("product_variant_id"));
                        string variantValue = reader.IsDBNull(reader.GetOrdinal("variant_value"))
                            ? null
                            : reader.GetString(reader.GetOrdinal("variant_value"));

                        if (variantId.HasValue && string.IsNullOrWhiteSpace(variantValue))
                        {
                            throw new InvalidOperationException("A product option in your cart is no longer available.");
                        }

                        string productName = reader.GetString(reader.GetOrdinal("product_name"));
                        items.Add(new CheckoutItem
                        {
                            ProductId = reader.GetInt64(reader.GetOrdinal("product_id")),
                            VariantId = variantId,
                            ProductName = string.IsNullOrWhiteSpace(variantValue)
                                ? productName
                                : productName + " (" + variantValue + ")",
                            Category = reader.GetString(reader.GetOrdinal("product_category")),
                            Quantity = reader.GetInt32(reader.GetOrdinal("quantity")),
                            UnitPrice = variantId.HasValue
                                ? reader.GetDecimal(reader.GetOrdinal("variant_price"))
                                : reader.GetDecimal(reader.GetOrdinal("product_price")),
                            VariantName = variantValue,
                            ImageUrl = ReadPreferredImageUrl(reader),
                            PhysicalStock = variantId.HasValue
                                ? reader.GetInt32(reader.GetOrdinal("variant_stock"))
                                : reader.GetInt32(reader.GetOrdinal("product_stock"))
                        });
                    }
                }
            }

            return items;
        }

        private static void ValidateAvailability(DbConnection conn, DbTransaction tx, IList<CheckoutItem> items)
        {
            foreach (CheckoutItem item in items)
            {
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.Transaction = tx;
                    cmd.CommandText = @"
                        SELECT COALESCE(SUM(quantity), 0)
                        FROM stock_reservations
                        WHERE product_id = @ProductId
                          AND product_variant_id IS NOT DISTINCT FROM @VariantId
                          AND status = @ActiveStatus";
                    cmd.Parameters.Add(new NpgsqlParameter("@ProductId", item.ProductId));
                    cmd.Parameters.Add(new NpgsqlParameter("@VariantId", item.VariantId.HasValue ? (object)item.VariantId.Value : DBNull.Value));
                    cmd.Parameters.Add(new NpgsqlParameter("@ActiveStatus", StockReservation.Active));

                    int reservedQuantity = Convert.ToInt32(cmd.ExecuteScalar());
                    int availableQuantity = Math.Max(item.PhysicalStock - reservedQuantity, 0);
                    if (item.Quantity > availableQuantity)
                    {
                        throw new InvalidOperationException(
                            item.ProductName + " only has " + availableQuantity + " available for checkout.");
                    }
                }
            }
        }

        private static long InsertPendingOrder(
            DbConnection conn,
            DbTransaction tx,
            long userId,
            decimal totalAmount,
            string shippingAddress,
            string deliveryMethod,
            string checkoutAttemptToken,
            string paymentCancellationTokenHash,
            DateTimeOffset expiresAt)
        {
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = @"
                    INSERT INTO orders
                        (user_id, status, total_amount, shipping_address, delivery_method, checkout_attempt_token, payment_cancel_token_hash, payment_expires_at)
                    VALUES
                        (@UserId, @Status, @TotalAmount, @ShippingAddress, @DeliveryMethod, @CheckoutAttemptToken, @PaymentCancellationTokenHash, @ExpiresAt)
                    RETURNING id";
                cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));
                cmd.Parameters.Add(new NpgsqlParameter("@Status", OrderStatuses.PendingPayment));
                cmd.Parameters.Add(new NpgsqlParameter("@TotalAmount", totalAmount));
                cmd.Parameters.Add(new NpgsqlParameter("@ShippingAddress", shippingAddress));
                cmd.Parameters.Add(new NpgsqlParameter("@DeliveryMethod", deliveryMethod));
                cmd.Parameters.Add(new NpgsqlParameter("@CheckoutAttemptToken", checkoutAttemptToken));
                cmd.Parameters.Add(new NpgsqlParameter("@PaymentCancellationTokenHash", paymentCancellationTokenHash));
                cmd.Parameters.Add(new NpgsqlParameter("@ExpiresAt", expiresAt));
                return Convert.ToInt64(cmd.ExecuteScalar());
            }
        }

        private static void InsertOrderItem(DbConnection conn, DbTransaction tx, long orderId, CheckoutItem item)
        {
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = @"
                    INSERT INTO order_items (order_id, product_id, product_variant_id, quantity, unit_price)
                    VALUES (@OrderId, @ProductId, @VariantId, @Quantity, @UnitPrice)";
                AddItemParameters(cmd, orderId, item);
                cmd.ExecuteNonQuery();
            }
        }

        private static void InsertReservation(
            DbConnection conn,
            DbTransaction tx,
            long orderId,
            CheckoutItem item,
            DateTimeOffset expiresAt)
        {
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = @"
                    INSERT INTO stock_reservations
                        (order_id, product_id, product_variant_id, quantity, status, expires_at)
                    VALUES
                        (@OrderId, @ProductId, @VariantId, @Quantity, @ActiveStatus, @ExpiresAt)";
                AddItemParameters(cmd, orderId, item);
                cmd.Parameters.Add(new NpgsqlParameter("@ActiveStatus", StockReservation.Active));
                cmd.Parameters.Add(new NpgsqlParameter("@ExpiresAt", expiresAt));
                cmd.ExecuteNonQuery();
            }
        }

        private static void RemoveCheckedOutCartItems(
            DbConnection conn,
            DbTransaction tx,
            long userId,
            IEnumerable<CheckoutItem> items)
        {
            foreach (CheckoutItem item in items)
            {
                CartRepository.DecrementPurchasedQuantity(
                    conn,
                    tx,
                    userId,
                    item.ProductId,
                    item.VariantId,
                    item.Quantity);
            }
        }

        private static void AddItemParameters(DbCommand cmd, long orderId, CheckoutItem item)
        {
            cmd.Parameters.Add(new NpgsqlParameter("@OrderId", orderId));
            cmd.Parameters.Add(new NpgsqlParameter("@ProductId", item.ProductId));
            cmd.Parameters.Add(new NpgsqlParameter("@VariantId", item.VariantId.HasValue ? (object)item.VariantId.Value : DBNull.Value));
            cmd.Parameters.Add(new NpgsqlParameter("@Quantity", item.Quantity));
            if (cmd.CommandText.Contains("@UnitPrice"))
            {
                cmd.Parameters.Add(new NpgsqlParameter("@UnitPrice", item.UnitPrice));
            }
        }

        private static OrderItem ToOrderItem(CheckoutItem item)
        {
            return new OrderItem
            {
                ProductId = item.ProductId,
                ProductVariantId = item.VariantId,
                ProductName = item.ProductName,
                Quantity = item.Quantity,
                UnitPrice = item.UnitPrice
            };
        }

        private static CartItem ToCartItem(CheckoutItem item)
        {
            return new CartItem
            {
                ProductId = item.ProductId,
                VariantId = item.VariantId,
                ProductName = item.ProductName,
                Category = item.Category,
                VariantName = item.VariantName,
                Price = item.UnitPrice,
                Quantity = item.Quantity,
                ImageUrl = item.ImageUrl
            };
        }

        private static string ReadPreferredImageUrl(DbDataReader reader)
        {
            int variantImageOrdinal = reader.GetOrdinal("variant_image_url");
            if (!reader.IsDBNull(variantImageOrdinal))
            {
                return reader.GetString(variantImageOrdinal);
            }

            int productImageOrdinal = reader.GetOrdinal("product_image_url");
            return reader.IsDBNull(productImageOrdinal)
                ? null
                : reader.GetString(productImageOrdinal);
        }

        private sealed class CartIdentity
        {
            public long ProductId { get; set; }
            public long? VariantId { get; set; }
        }

        private sealed class CheckoutItem
        {
            public long ProductId { get; set; }
            public long? VariantId { get; set; }
            public string ProductName { get; set; }
            public string Category { get; set; }
            public string VariantName { get; set; }
            public string ImageUrl { get; set; }
            public int Quantity { get; set; }
            public decimal UnitPrice { get; set; }
            public int PhysicalStock { get; set; }
        }
    }

    public class ActiveCheckoutAttemptException : InvalidOperationException
    {
        public ActiveCheckoutAttemptException()
            : base("You already have an active payment. Continue or cancel the existing payment before starting a new checkout.")
        {
        }
    }
}
