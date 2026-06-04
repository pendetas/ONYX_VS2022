using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using Npgsql;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.DAL
{
    public class ProductRepository
    {
        // Helper method to grab the read connection string from Web.config
        private string GetConnectionString()
        {
            return ConfigurationManager.ConnectionStrings["ReadConnection"].ConnectionString;
        }

        public IList<Product> GetFeaturedProducts(int count)
        {
            var products = new List<Product>();

            using (var conn = new NpgsqlConnection(GetConnectionString()))
            {
                conn.Open();
                string sql = @"
                    SELECT id, name, brand, category, description, price, stock_qty, image_url, created_at 
                    FROM products 
                    ORDER BY created_at DESC 
                    LIMIT @Count";

                using (var cmd = new NpgsqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Count", count);
                    using (var reader = cmd.ExecuteReader())
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

        public IList<Product> GetCatalogProducts(string category)
        {
            var products = new List<Product>();

            using (var conn = new NpgsqlConnection(GetConnectionString()))
            {
                conn.Open();
                string sql = "SELECT id, name, brand, category, description, price, stock_qty, image_url, created_at FROM products";

                if (!string.IsNullOrWhiteSpace(category))
                {
                    sql += " WHERE category ILIKE @Category";
                }
                sql += " ORDER BY name ASC";

                using (var cmd = new NpgsqlCommand(sql, conn))
                {
                    if (!string.IsNullOrWhiteSpace(category))
                    {
                        cmd.Parameters.AddWithValue("@Category", category);
                    }
                    using (var reader = cmd.ExecuteReader())
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

        // New Method: Fetch a single product for the Details page
        public Product GetProductById(long id)
        {
            using (var conn = new NpgsqlConnection(GetConnectionString()))
            {
                conn.Open();
                string sql = "SELECT id, name, brand, category, description, price, stock_qty, image_url, created_at FROM products WHERE id = @Id";

                using (var cmd = new NpgsqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@Id", id);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            return MapReaderToProduct(reader);
                        }
                    }
                }
            }
            return null;
        }

        // New Method: Fetch product variants for the Details page
        public IList<ProductVariant> GetProductVariants(long productId)
        {
            var variants = new List<ProductVariant>();
            using (var conn = new NpgsqlConnection(GetConnectionString()))
            {
                conn.Open();
                string sql = "SELECT product_variant_id, product_id, variant_type, variant_value, variant_price, stock_qty, image_url FROM product_variants WHERE product_id = @ProductId";

                using (var cmd = new NpgsqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@ProductId", productId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            variants.Add(new ProductVariant
                            {
                                ProductVariantId = reader.GetInt64(reader.GetOrdinal("product_variant_id")),
                                ProductId = reader.GetInt64(reader.GetOrdinal("product_id")),
                                VariantType = reader.GetString(reader.GetOrdinal("variant_type")),
                                VariantValue = reader.GetString(reader.GetOrdinal("variant_value")),
                                VariantPrice = reader.GetDecimal(reader.GetOrdinal("variant_price")),
                                StockQty = reader.GetInt32(reader.GetOrdinal("stock_qty")),
                                ImageUrl = reader.IsDBNull(reader.GetOrdinal("image_url")) ? null : reader.GetString(reader.GetOrdinal("image_url"))
                            });
                        }
                    }
                }
            }
            return variants;
        }

        // Helper method to safely map PostgreSQL rows to the C# Product object
        private Product MapReaderToProduct(NpgsqlDataReader reader)
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