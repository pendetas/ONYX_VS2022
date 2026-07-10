using System;
using System.Collections.Generic;
using System.Data.Common;
using System.Linq;
using Npgsql;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.DAL
{
    public class PaymentRepository
    {
        public bool HasLocalOrderForSession(string sessionId)
        {
            if (string.IsNullOrWhiteSpace(sessionId))
            {
                return false;
            }

            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT EXISTS (
                            SELECT 1
                            FROM orders
                            WHERE stripe_checkout_session_id = @SessionId
                        )";
                    cmd.Parameters.Add(new NpgsqlParameter("@SessionId", sessionId));
                    return Convert.ToBoolean(cmd.ExecuteScalar());
                }
            }
        }

        public PaymentReconciliationResult GetCurrentState(StripePaymentState payment)
        {
            ValidatePaymentIdentity(payment);

            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbTransaction tx = conn.BeginTransaction())
                {
                    try
                    {
                        LockedOrder order = LockOrder(conn, tx, payment);
                        tx.Commit();
                        return ToResult(order, payment.CheckoutUrl);
                    }
                    catch
                    {
                        tx.Rollback();
                        throw;
                    }
                }
            }
        }

        public PaymentReconciliationResult CompletePayment(
            StripePaymentState payment,
            string stripeEventId,
            string eventType)
        {
            ValidatePaymentIdentity(payment);

            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbTransaction tx = conn.BeginTransaction())
                {
                    try
                    {
                        bool isNewEvent = TryInsertStripeEvent(conn, tx, stripeEventId, eventType);
                        CartRepository.LockUserCart(conn, tx, payment.UserId);
                        LockedOrder order = LockOrder(conn, tx, payment);
                        ValidatePaymentTerms(payment, order);

                        if (!isNewEvent || string.Equals(order.Status, OrderStatuses.Paid, StringComparison.Ordinal))
                        {
                            tx.Commit();
                            return ToResult(order, payment.CheckoutUrl);
                        }

                        if (!string.Equals(order.Status, OrderStatuses.PendingPayment, StringComparison.Ordinal))
                        {
                            throw new InvalidOperationException("A Stripe-paid order is not pending payment.");
                        }

                        IList<LockedReservation> reservations = LockActiveReservations(conn, tx, order.OrderId);
                        if (reservations.Count == 0)
                        {
                            throw new InvalidOperationException("The pending order has no active stock reservations.");
                        }

                        LockPhysicalStockRows(conn, tx, reservations);
                        foreach (LockedReservation reservation in reservations)
                        {
                            DeductPhysicalStock(conn, tx, reservation);
                        }

                        CompleteReservations(conn, tx, order.OrderId, reservations.Count);
                        MarkOrderPaid(conn, tx, order.OrderId, payment);

                        tx.Commit();
                        return new PaymentReconciliationResult
                        {
                            OrderId = order.OrderId,
                            OrderStatus = OrderStatuses.Paid
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

        public PaymentReconciliationResult CancelPayment(
            StripePaymentState payment,
            string stripeEventId,
            string eventType)
        {
            ValidatePaymentIdentity(payment);

            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbTransaction tx = conn.BeginTransaction())
                {
                    try
                    {
                        bool isNewEvent = TryInsertStripeEvent(conn, tx, stripeEventId, eventType);
                        CartRepository.LockUserCart(conn, tx, payment.UserId);
                        LockedOrder order = LockOrder(conn, tx, payment);

                        if (!isNewEvent ||
                            string.Equals(order.Status, OrderStatuses.Paid, StringComparison.Ordinal) ||
                            string.Equals(order.Status, OrderStatuses.Cancelled, StringComparison.Ordinal))
                        {
                            tx.Commit();
                            return ToResult(order, payment.CheckoutUrl);
                        }

                        if (!string.Equals(order.Status, OrderStatuses.PendingPayment, StringComparison.Ordinal))
                        {
                            throw new InvalidOperationException("The order cannot be cancelled from its current state.");
                        }

                        CartRepository.RestoreCartItems(conn, tx, order.UserId, order.OrderId);

                        using (DbCommand release = conn.CreateCommand())
                        {
                            release.Transaction = tx;
                            release.CommandText = @"
                                UPDATE stock_reservations
                                SET status = @ReleasedStatus
                                WHERE order_id = @OrderId
                                  AND status = @ActiveStatus";
                            release.Parameters.Add(new NpgsqlParameter("@ReleasedStatus", StockReservation.Released));
                            release.Parameters.Add(new NpgsqlParameter("@OrderId", order.OrderId));
                            release.Parameters.Add(new NpgsqlParameter("@ActiveStatus", StockReservation.Active));
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
                                  AND status = @PendingStatus";
                            cancel.Parameters.Add(new NpgsqlParameter("@CancelledStatus", OrderStatuses.Cancelled));
                            cancel.Parameters.Add(new NpgsqlParameter("@OrderId", order.OrderId));
                            cancel.Parameters.Add(new NpgsqlParameter("@PendingStatus", OrderStatuses.PendingPayment));
                            if (cancel.ExecuteNonQuery() != 1)
                            {
                                throw new InvalidOperationException("The pending order could not be cancelled.");
                            }
                        }

                        tx.Commit();
                        return new PaymentReconciliationResult
                        {
                            OrderId = order.OrderId,
                            OrderStatus = OrderStatuses.Cancelled
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

        private static bool TryInsertStripeEvent(
            DbConnection conn,
            DbTransaction tx,
            string stripeEventId,
            string eventType)
        {
            if (string.IsNullOrWhiteSpace(stripeEventId))
            {
                return true;
            }

            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = @"
                    INSERT INTO stripe_events (stripe_event_id, event_type)
                    VALUES (@EventId, @EventType)
                    ON CONFLICT (stripe_event_id) DO NOTHING";
                cmd.Parameters.Add(new NpgsqlParameter("@EventId", stripeEventId));
                cmd.Parameters.Add(new NpgsqlParameter("@EventType", eventType ?? string.Empty));
                return cmd.ExecuteNonQuery() == 1;
            }
        }

        private static LockedOrder LockOrder(DbConnection conn, DbTransaction tx, StripePaymentState payment)
        {
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = @"
                    SELECT id, user_id, status, total_amount, stripe_checkout_session_id, checkout_attempt_token
                    FROM orders
                    WHERE id = @OrderId
                    FOR UPDATE";
                cmd.Parameters.Add(new NpgsqlParameter("@OrderId", payment.OrderId));

                using (DbDataReader reader = cmd.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        throw new InvalidOperationException("The Stripe Checkout Session does not match an ONYX order.");
                    }

                    var order = new LockedOrder
                    {
                        OrderId = reader.GetInt64(reader.GetOrdinal("id")),
                        UserId = reader.GetInt64(reader.GetOrdinal("user_id")),
                        Status = reader.GetString(reader.GetOrdinal("status")),
                        TotalAmount = reader.GetDecimal(reader.GetOrdinal("total_amount")),
                        SessionId = reader.IsDBNull(reader.GetOrdinal("stripe_checkout_session_id"))
                            ? null
                            : reader.GetString(reader.GetOrdinal("stripe_checkout_session_id")),
                        CheckoutAttemptToken = reader.IsDBNull(reader.GetOrdinal("checkout_attempt_token"))
                            ? null
                            : reader.GetString(reader.GetOrdinal("checkout_attempt_token"))
                    };

                    if (order.UserId != payment.UserId ||
                        !string.Equals(order.SessionId, payment.SessionId, StringComparison.Ordinal) ||
                        !string.Equals(
                            order.CheckoutAttemptToken,
                            payment.CheckoutAttemptToken,
                            StringComparison.Ordinal))
                    {
                        throw new InvalidOperationException("The Stripe Checkout Session ownership check failed.");
                    }

                    return order;
                }
            }
        }

        private static IList<LockedReservation> LockActiveReservations(
            DbConnection conn,
            DbTransaction tx,
            long orderId)
        {
            var reservations = new List<LockedReservation>();
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = @"
                    SELECT reservation_id, product_id, product_variant_id, quantity
                    FROM stock_reservations
                    WHERE order_id = @OrderId
                      AND status = @ActiveStatus
                    ORDER BY product_id, variant_key
                    FOR UPDATE";
                cmd.Parameters.Add(new NpgsqlParameter("@OrderId", orderId));
                cmd.Parameters.Add(new NpgsqlParameter("@ActiveStatus", StockReservation.Active));

                using (DbDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        reservations.Add(new LockedReservation
                        {
                            ReservationId = reader.GetInt64(reader.GetOrdinal("reservation_id")),
                            ProductId = reader.GetInt64(reader.GetOrdinal("product_id")),
                            ProductVariantId = reader.IsDBNull(reader.GetOrdinal("product_variant_id"))
                                ? (long?)null
                                : reader.GetInt64(reader.GetOrdinal("product_variant_id")),
                            Quantity = reader.GetInt32(reader.GetOrdinal("quantity"))
                        });
                    }
                }
            }

            return reservations;
        }

        private static void LockPhysicalStockRows(
            DbConnection conn,
            DbTransaction tx,
            IList<LockedReservation> reservations)
        {
            foreach (long productId in reservations.Select(item => item.ProductId).Distinct().OrderBy(id => id))
            {
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.Transaction = tx;
                    cmd.CommandText = "SELECT id FROM products WHERE id = @ProductId FOR UPDATE";
                    cmd.Parameters.Add(new NpgsqlParameter("@ProductId", productId));
                    if (cmd.ExecuteScalar() == null)
                    {
                        throw new InvalidOperationException("Reserved product stock no longer exists.");
                    }
                }
            }

            foreach (LockedReservation reservation in reservations
                .Where(item => item.ProductVariantId.HasValue)
                .OrderBy(item => item.ProductVariantId.Value))
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
                    cmd.Parameters.Add(new NpgsqlParameter("@VariantId", reservation.ProductVariantId.Value));
                    cmd.Parameters.Add(new NpgsqlParameter("@ProductId", reservation.ProductId));
                    if (cmd.ExecuteScalar() == null)
                    {
                        throw new InvalidOperationException("Reserved variant stock no longer exists.");
                    }
                }
            }
        }

        private static void DeductPhysicalStock(
            DbConnection conn,
            DbTransaction tx,
            LockedReservation reservation)
        {
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                if (reservation.ProductVariantId.HasValue)
                {
                    cmd.CommandText = @"
                        UPDATE product_variants
                        SET stock_qty = stock_qty - @Quantity
                        WHERE product_variant_id = @VariantId
                          AND product_id = @ProductId
                          AND stock_qty >= @Quantity";
                    cmd.Parameters.Add(new NpgsqlParameter("@VariantId", reservation.ProductVariantId.Value));
                }
                else
                {
                    cmd.CommandText = @"
                        UPDATE products
                        SET stock_qty = stock_qty - @Quantity
                        WHERE id = @ProductId
                          AND stock_qty >= @Quantity";
                }

                cmd.Parameters.Add(new NpgsqlParameter("@ProductId", reservation.ProductId));
                cmd.Parameters.Add(new NpgsqlParameter("@Quantity", reservation.Quantity));
                if (cmd.ExecuteNonQuery() != 1)
                {
                    throw new InvalidOperationException("Reserved stock could not be deducted safely.");
                }
            }
        }

        private static void CompleteReservations(
            DbConnection conn,
            DbTransaction tx,
            long orderId,
            int expectedCount)
        {
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = @"
                    UPDATE stock_reservations
                    SET status = @CompletedStatus
                    WHERE order_id = @OrderId
                      AND status = @ActiveStatus";
                cmd.Parameters.Add(new NpgsqlParameter("@CompletedStatus", StockReservation.Completed));
                cmd.Parameters.Add(new NpgsqlParameter("@OrderId", orderId));
                cmd.Parameters.Add(new NpgsqlParameter("@ActiveStatus", StockReservation.Active));
                if (cmd.ExecuteNonQuery() != expectedCount)
                {
                    throw new InvalidOperationException("Stock reservations changed during payment completion.");
                }
            }
        }

        private static void MarkOrderPaid(
            DbConnection conn,
            DbTransaction tx,
            long orderId,
            StripePaymentState payment)
        {
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = @"
                    UPDATE orders
                    SET status = @PaidStatus,
                        stripe_payment_intent_id = @PaymentIntentId,
                        payment_method = @PaymentMethod,
                        paid_at = now(),
                        payment_cancel_token_hash = NULL
                    WHERE id = @OrderId
                      AND status = @PendingStatus";
                cmd.Parameters.Add(new NpgsqlParameter("@PaidStatus", OrderStatuses.Paid));
                cmd.Parameters.Add(new NpgsqlParameter("@PaymentIntentId", (object)payment.PaymentIntentId ?? DBNull.Value));
                cmd.Parameters.Add(new NpgsqlParameter("@PaymentMethod", (object)payment.PaymentMethodSummary ?? DBNull.Value));
                cmd.Parameters.Add(new NpgsqlParameter("@OrderId", orderId));
                cmd.Parameters.Add(new NpgsqlParameter("@PendingStatus", OrderStatuses.PendingPayment));
                if (cmd.ExecuteNonQuery() != 1)
                {
                    throw new InvalidOperationException("The pending order could not be marked paid.");
                }
            }
        }

        private static PaymentReconciliationResult ToResult(LockedOrder order, string checkoutUrl)
        {
            return new PaymentReconciliationResult
            {
                OrderId = order.OrderId,
                OrderStatus = order.Status,
                CheckoutUrl = string.Equals(order.Status, OrderStatuses.PendingPayment, StringComparison.Ordinal)
                    ? checkoutUrl
                    : null
            };
        }

        private static void ValidatePaymentIdentity(StripePaymentState payment)
        {
            if (payment == null ||
                !payment.IsOnyxSession ||
                payment.OrderId <= 0 ||
                payment.UserId <= 0 ||
                string.IsNullOrWhiteSpace(payment.SessionId))
            {
                throw new InvalidOperationException("Stripe payment identity is invalid.");
            }
        }

        private static void ValidatePaymentTerms(StripePaymentState payment, LockedOrder order)
        {
            if (!string.Equals(payment.Mode, "payment", StringComparison.OrdinalIgnoreCase))
            {
                throw new InvalidOperationException("Stripe Checkout Session mode does not match the ONYX order.");
            }

            if (!string.Equals(payment.Currency, "myr", StringComparison.OrdinalIgnoreCase))
            {
                throw new InvalidOperationException("Stripe Checkout Session currency does not match the ONYX order.");
            }

            long expectedAmount = checked((long)Math.Round(
                order.TotalAmount * 100m,
                0,
                MidpointRounding.AwayFromZero));

            if (!payment.AmountTotal.HasValue || payment.AmountTotal.Value != expectedAmount)
            {
                throw new InvalidOperationException("Stripe Checkout Session amount does not match the ONYX order.");
            }
        }

        private sealed class LockedOrder
        {
            public long OrderId { get; set; }
            public long UserId { get; set; }
            public string Status { get; set; }
            public decimal TotalAmount { get; set; }
            public string SessionId { get; set; }
            public string CheckoutAttemptToken { get; set; }
        }

        private sealed class LockedReservation
        {
            public long ReservationId { get; set; }
            public long ProductId { get; set; }
            public long? ProductVariantId { get; set; }
            public int Quantity { get; set; }
        }
    }
}
