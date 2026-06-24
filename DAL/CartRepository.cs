using System;
using System.Collections.Generic;
using System.Data.Common;
using Npgsql;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.DAL
{
    public class CartRepository
    {
        public IList<CartItem> GetCartItems(long userId)
        {
            var items = new List<CartItem>();

            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT
                            c.product_id,
                            c.product_variant_id,
                            c.quantity,
                            p.name AS product_name,
                            p.price AS product_price,
                            p.image_url AS product_image_url,
                            pv.variant_value,
                            pv.variant_price,
                            pv.image_url AS variant_image_url
                        FROM cart c
                        INNER JOIN products p ON p.id = c.product_id
                        LEFT JOIN product_variants pv ON pv.product_variant_id = c.product_variant_id
                        WHERE c.user_id = @UserId
                        ORDER BY c.created_at ASC, c.cart_id ASC";
                    cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));

                    using (DbDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            long? variantId = reader.IsDBNull(reader.GetOrdinal("product_variant_id"))
                                ? (long?)null
                                : reader.GetInt64(reader.GetOrdinal("product_variant_id"));

                            string productName = reader.GetString(reader.GetOrdinal("product_name"));
                            string variantValue = reader.IsDBNull(reader.GetOrdinal("variant_value"))
                                ? null
                                : reader.GetString(reader.GetOrdinal("variant_value"));

                            decimal price = reader.IsDBNull(reader.GetOrdinal("variant_price"))
                                ? reader.GetDecimal(reader.GetOrdinal("product_price"))
                                : reader.GetDecimal(reader.GetOrdinal("variant_price"));

                            string imageUrl = reader.IsDBNull(reader.GetOrdinal("variant_image_url"))
                                ? (reader.IsDBNull(reader.GetOrdinal("product_image_url")) ? null : reader.GetString(reader.GetOrdinal("product_image_url")))
                                : reader.GetString(reader.GetOrdinal("variant_image_url"));

                            items.Add(new CartItem
                            {
                                ProductId = reader.GetInt64(reader.GetOrdinal("product_id")),
                                VariantId = variantId,
                                ProductName = string.IsNullOrWhiteSpace(variantValue)
                                    ? productName
                                    : $"{productName} ({variantValue})",
                                VariantName = variantValue,
                                Price = price,
                                Quantity = reader.GetInt32(reader.GetOrdinal("quantity")),
                                ImageUrl = imageUrl
                            });
                        }
                    }
                }
            }

            return items;
        }

        public void UpsertCartItem(long userId, CartItem item)
        {
            if (item == null)
            {
                throw new ArgumentNullException(nameof(item));
            }

            if (item.Quantity <= 0)
            {
                RemoveCartItem(userId, item.ProductId, item.VariantId);
                return;
            }

            ExecuteUserCartMutation(userId, (conn, tx) =>
            {
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.Transaction = tx;
                    cmd.CommandText = @"
                        INSERT INTO cart (user_id, product_id, product_variant_id, quantity)
                        VALUES (@UserId, @ProductId, @VariantId, @Quantity)
                        ON CONFLICT (user_id, product_id, variant_key)
                        DO UPDATE SET
                            quantity = cart.quantity + EXCLUDED.quantity,
                            updated_at = now()";
                    AddCartParameters(cmd, userId, item.ProductId, item.VariantId, item.Quantity);
                    cmd.ExecuteNonQuery();
                }
            });
        }

        public void SetCartItemQuantity(long userId, long productId, long? variantId, int quantity)
        {
            if (quantity <= 0)
            {
                RemoveCartItem(userId, productId, variantId);
                return;
            }

            ExecuteUserCartMutation(userId, (conn, tx) =>
            {
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.Transaction = tx;
                    cmd.CommandText = @"
                        INSERT INTO cart (user_id, product_id, product_variant_id, quantity)
                        VALUES (@UserId, @ProductId, @VariantId, @Quantity)
                        ON CONFLICT (user_id, product_id, variant_key)
                        DO UPDATE SET
                            quantity = EXCLUDED.quantity,
                            updated_at = now()";
                    AddCartParameters(cmd, userId, productId, variantId, quantity);
                    cmd.ExecuteNonQuery();
                }
            });
        }

        public void RemoveCartItem(long userId, long productId, long? variantId)
        {
            ExecuteUserCartMutation(userId, (conn, tx) =>
            {
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.Transaction = tx;
                    cmd.CommandText = @"
                        DELETE FROM cart
                        WHERE user_id = @UserId
                          AND product_id = @ProductId
                          AND product_variant_id IS NOT DISTINCT FROM @VariantId";
                    AddCartParameters(cmd, userId, productId, variantId, 0);
                    cmd.ExecuteNonQuery();
                }
            });
        }

        public void ClearCart(long userId)
        {
            ExecuteUserCartMutation(userId, (conn, tx) =>
            {
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.Transaction = tx;
                    cmd.CommandText = "DELETE FROM cart WHERE user_id = @UserId";
                    cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));
                    cmd.ExecuteNonQuery();
                }
            });
        }

        public void MergeCartItems(long userId, IEnumerable<CartItem> items)
        {
            if (items == null)
            {
                return;
            }

            ExecuteUserCartMutation(userId, (conn, tx) =>
            {
                foreach (CartItem item in items)
                {
                    if (item == null || item.Quantity <= 0)
                    {
                        continue;
                    }

                    using (DbCommand cmd = conn.CreateCommand())
                    {
                        cmd.Transaction = tx;
                        cmd.CommandText = @"
                            INSERT INTO cart (user_id, product_id, product_variant_id, quantity)
                            VALUES (@UserId, @ProductId, @VariantId, @Quantity)
                            ON CONFLICT (user_id, product_id, variant_key)
                            DO UPDATE SET
                                quantity = cart.quantity + EXCLUDED.quantity,
                                updated_at = now()";
                        AddCartParameters(cmd, userId, item.ProductId, item.VariantId, item.Quantity);
                        cmd.ExecuteNonQuery();
                    }
                }
            });
        }

        internal static void DecrementPurchasedQuantity(
            DbConnection conn,
            DbTransaction tx,
            long userId,
            long productId,
            long? variantId,
            int purchasedQuantity)
        {
            using (DbCommand delete = conn.CreateCommand())
            {
                delete.Transaction = tx;
                delete.CommandText = @"
                    DELETE FROM cart
                    WHERE user_id = @UserId
                      AND product_id = @ProductId
                      AND product_variant_id IS NOT DISTINCT FROM @VariantId
                      AND quantity <= @Quantity";
                AddCartParameters(delete, userId, productId, variantId, purchasedQuantity);
                if (delete.ExecuteNonQuery() == 1)
                {
                    return;
                }
            }

            using (DbCommand update = conn.CreateCommand())
            {
                update.Transaction = tx;
                update.CommandText = @"
                    UPDATE cart
                    SET quantity = quantity - @Quantity,
                        updated_at = now()
                    WHERE user_id = @UserId
                      AND product_id = @ProductId
                      AND product_variant_id IS NOT DISTINCT FROM @VariantId
                      AND quantity > @Quantity";
                AddCartParameters(update, userId, productId, variantId, purchasedQuantity);
                update.ExecuteNonQuery();
            }
        }

        internal static void LockUserCart(DbConnection conn, DbTransaction tx, long userId)
        {
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = "SELECT pg_advisory_xact_lock(@UserId)";
                cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));
                cmd.ExecuteNonQuery();
            }
        }

        private static void ExecuteUserCartMutation(
            long userId,
            Action<DbConnection, DbTransaction> mutation)
        {
            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbTransaction tx = conn.BeginTransaction())
                {
                    try
                    {
                        LockUserCart(conn, tx, userId);
                        mutation(conn, tx);
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

        private static void AddCartParameters(DbCommand cmd, long userId, long productId, long? variantId, int quantity)
        {
            cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));
            cmd.Parameters.Add(new NpgsqlParameter("@ProductId", productId));
            cmd.Parameters.Add(new NpgsqlParameter("@VariantId", variantId.HasValue ? (object)variantId.Value : DBNull.Value));
            cmd.Parameters.Add(new NpgsqlParameter("@Quantity", quantity));
        }
    }
}
