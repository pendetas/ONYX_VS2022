using System;
using System.Collections.Generic;
using System.Data.Common;
using Npgsql;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.DAL
{
    public class ProductRepository
    {
        public IList<Product> GetFeaturedProducts(int count)
        {
            var products = new List<Product>();

            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                    SELECT id, name, brand, category, description, price, stock_qty, image_url, created_at 
                    FROM products 
                    ORDER BY created_at DESC 
                    LIMIT @Count";
                    cmd.Parameters.Add(new NpgsqlParameter("@Count", count));
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

        public PagedResult<Product> GetCatalogProducts(CatalogQuery query)
        {
            var result = new PagedResult<Product>
            {
                Page = query.Page,
                PageSize = query.PageSize
            };

            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                string whereClause = BuildCatalogWhereClause(query);

                using (DbCommand countCommand = conn.CreateCommand())
                {
                    countCommand.CommandText = "SELECT COUNT(*) FROM products" + whereClause;
                    AddCatalogFilterParameters(countCommand, query);
                    result.TotalCount = Convert.ToInt32(countCommand.ExecuteScalar());
                }

                int totalPages = Math.Max(1, (int)Math.Ceiling(result.TotalCount / (double)query.PageSize));
                result.Page = Math.Min(query.Page, totalPages);

                using (DbCommand command = conn.CreateCommand())
                {
                    command.CommandText = @"
                        SELECT id, name, brand, category, description, price, stock_qty, image_url, created_at
                        FROM products"
                        + whereClause
                        + " ORDER BY " + GetCatalogOrderBy(query.Sort)
                        + " LIMIT @PageSize OFFSET @Offset";
                    AddCatalogFilterParameters(command, query);
                    command.Parameters.Add(new NpgsqlParameter("@PageSize", query.PageSize));
                    command.Parameters.Add(new NpgsqlParameter("@Offset", (result.Page - 1) * query.PageSize));

                    using (DbDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            result.Items.Add(MapReaderToProduct(reader));
                        }
                    }
                }
            }

            return result;
        }

        private static string BuildCatalogWhereClause(CatalogQuery query)
        {
            var filters = new List<string>();

            if (!string.IsNullOrWhiteSpace(query.Category))
            {
                filters.Add("category ILIKE @Category");
            }

            if (!string.IsNullOrWhiteSpace(query.SearchTerm))
            {
                filters.Add("(name ILIKE @Search OR brand ILIKE @Search OR category ILIKE @Search OR description ILIKE @Search)");
            }

            return filters.Count == 0 ? string.Empty : " WHERE " + string.Join(" AND ", filters);
        }

        private static void AddCatalogFilterParameters(DbCommand command, CatalogQuery query)
        {
            if (!string.IsNullOrWhiteSpace(query.Category))
            {
                command.Parameters.Add(new NpgsqlParameter("@Category", query.Category));
            }

            if (!string.IsNullOrWhiteSpace(query.SearchTerm))
            {
                command.Parameters.Add(new NpgsqlParameter("@Search", "%" + query.SearchTerm + "%"));
            }
        }

        private static string GetCatalogOrderBy(string sort)
        {
            switch (sort)
            {
                case "name":
                    return "name ASC, id ASC";
                case "price-asc":
                    return "price ASC, name ASC";
                case "price-desc":
                    return "price DESC, name ASC";
                default:
                    return "created_at DESC, id DESC";
            }
        }

        // New Method: Fetch a single product for the Details page
        public Product GetProductById(long id)
        {
            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SELECT id, name, brand, category, description, price, stock_qty, image_url, created_at FROM products WHERE id = @Id";
                    cmd.Parameters.Add(new NpgsqlParameter("@Id", id));
                    using (DbDataReader reader = cmd.ExecuteReader())
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
            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SELECT product_variant_id, product_id, variant_type, variant_value, variant_price, stock_qty, image_url FROM product_variants WHERE product_id = @ProductId";
                    cmd.Parameters.Add(new NpgsqlParameter("@ProductId", productId));
                    using (DbDataReader reader = cmd.ExecuteReader())
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
        private Product MapReaderToProduct(DbDataReader reader)
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
