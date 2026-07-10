using System;
using System.Collections.Generic;
using System.Data.Common;
using Npgsql;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.DAL
{
    public class WishlistRepository
    {
        public IList<Product> GetWishlistProducts(long userId)
        {
            var products = new List<Product>();

            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT
                            p.id,
                            p.name,
                            p.brand,
                            p.category,
                            p.description,
                            p.price,
                            p.stock_qty,
                            p.image_url,
                            p.created_at
                        FROM wishlists w
                        INNER JOIN products p ON p.id = w.product_id
                        WHERE w.user_id = @UserId
                        ORDER BY w.added_at DESC, w.wishlist_id DESC";
                    cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));

                    using (DbDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            products.Add(MapReaderToProduct(reader));
                        }
                    }
                }
            }

            return products;
        }

        public void AddWishlistItem(long userId, long productId)
        {
            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        INSERT INTO wishlists (user_id, product_id)
                        VALUES (@UserId, @ProductId)
                        ON CONFLICT (user_id, product_id)
                        DO NOTHING";
                    AddWishlistParameters(cmd, userId, productId);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        public void RemoveWishlistItem(long userId, long productId)
        {
            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        DELETE FROM wishlists
                        WHERE user_id = @UserId
                          AND product_id = @ProductId";
                    AddWishlistParameters(cmd, userId, productId);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        public bool IsInWishlist(long userId, long productId)
        {
            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT 1
                        FROM wishlists
                        WHERE user_id = @UserId
                          AND product_id = @ProductId
                        LIMIT 1";
                    AddWishlistParameters(cmd, userId, productId);
                    object result = cmd.ExecuteScalar();
                    return result != null;
                }
            }
        }

        private static void AddWishlistParameters(DbCommand cmd, long userId, long productId)
        {
            cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));
            cmd.Parameters.Add(new NpgsqlParameter("@ProductId", productId));
        }

        private static Product MapReaderToProduct(DbDataReader reader)
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
    }
}
