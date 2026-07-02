using System;
using System.Collections.Generic;
using System.Data.Common;
using Npgsql;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.DAL
{
    public class ProductRepository
    {
        public List<Product> GetAllProducts()
        {
            var list = new List<Product>();
            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT id, name, brand, category, description, price, stock_qty, image_url, created_at
                        FROM products
                        ORDER BY created_at DESC";

                    using (DbDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                            list.Add(MapRow(r));
                    }
                }
            }
            return list;
        }

        public List<string> GetDistinctCategories()
        {
            var list = new List<string>();
            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "SELECT DISTINCT category FROM products ORDER BY category";
                    using (DbDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                            list.Add(r.GetString(0));
                    }
                }
            }
            return list;
        }

        public Product GetProductById(long id)
        {
            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT id, name, brand, category, description, price, stock_qty, image_url, created_at
                        FROM products WHERE id = @id";

                    DbParameter p = cmd.CreateParameter();
                    p.ParameterName = "@id";
                    p.Value = id;
                    cmd.Parameters.Add(p);

                    using (DbDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read()) return MapRow(r);
                    }
                }
            }
            return null;
        }

        // =====================================================================
        //  PRODUCT VARIANTS
        // =====================================================================

        public System.Collections.Generic.List<ONYX_DDAC.Models.ProductVariant> GetVariantsByProductId(long productId)
        {
            var list = new System.Collections.Generic.List<ONYX_DDAC.Models.ProductVariant>();

            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT product_variant_id, product_id, variant_type, variant_value,
                               variant_price, stock_qty, image_url
                        FROM product_variants
                        WHERE product_id = @ProductId
                        ORDER BY variant_type, variant_value";

                    DbParameter p = cmd.CreateParameter();
                    p.ParameterName = "@ProductId";
                    p.Value = productId;
                    cmd.Parameters.Add(p);

                    using (DbDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            list.Add(new ONYX_DDAC.Models.ProductVariant
                            {
                                ProductVariantId = r.GetInt64(0),
                                ProductId        = r.GetInt64(1),
                                VariantType      = r.GetString(2),
                                VariantValue     = r.GetString(3),
                                VariantPrice     = r.GetDecimal(4),
                                StockQty         = r.GetInt32(5),
                                ImageUrl         = r.IsDBNull(6) ? null : r.GetString(6)
                            });
                        }
                    }
                }
            }
            return list;
        }

        public void AddVariant(long productId, string type, string value, decimal price, int stockQty)
        {
            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        INSERT INTO product_variants (product_id, variant_type, variant_value, variant_price, stock_qty)
                        VALUES (@ProductId, @Type, @Value, @Price, @StockQty)";

                    void Add(string n, object v) { DbParameter p = cmd.CreateParameter(); p.ParameterName = n; p.Value = v; cmd.Parameters.Add(p); }

                    Add("@ProductId", productId);
                    Add("@Type",      type);
                    Add("@Value",     value);
                    Add("@Price",     price);
                    Add("@StockQty",  stockQty);

                    cmd.ExecuteNonQuery();
                }
            }
            SyncProductStock(productId);
        }

        public void UpdateVariant(long variantId, long productId, decimal price, int stockQty)
        {
            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        UPDATE product_variants
                        SET variant_price = @Price, stock_qty = @StockQty
                        WHERE product_variant_id = @VariantId";

                    void Add(string n, object v) { DbParameter p = cmd.CreateParameter(); p.ParameterName = n; p.Value = v; cmd.Parameters.Add(p); }

                    Add("@Price",     price);
                    Add("@StockQty",  stockQty);
                    Add("@VariantId", variantId);

                    cmd.ExecuteNonQuery();
                }
            }
            SyncProductStock(productId);
        }

        public void DeleteVariant(long variantId, long productId)
        {
            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "UPDATE order_items SET product_variant_id = NULL WHERE product_variant_id = @VariantId";

                    DbParameter p = cmd.CreateParameter();
                    p.ParameterName = "@VariantId";
                    p.Value = variantId;
                    cmd.Parameters.Add(p);
                    cmd.ExecuteNonQuery();

                    cmd.Parameters.Clear();
                    cmd.CommandText = "DELETE FROM product_variants WHERE product_variant_id = @VariantId";

                    DbParameter p2 = cmd.CreateParameter();
                    p2.ParameterName = "@VariantId";
                    p2.Value = variantId;
                    cmd.Parameters.Add(p2);
                    cmd.ExecuteNonQuery();
                }
            }
            SyncProductStock(productId);
        }

        // Keeps products.stock_qty in sync with the sum of all variant stocks.
        // Only updates if variants exist; leaves manual stock untouched otherwise.
        private void SyncProductStock(long productId)
        {
            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        UPDATE products
                        SET stock_qty = (SELECT COALESCE(SUM(stock_qty), 0)
                                         FROM product_variants
                                         WHERE product_id = @Id)
                        WHERE id = @Id
                          AND EXISTS (SELECT 1 FROM product_variants WHERE product_id = @Id)";

                    DbParameter p = cmd.CreateParameter();
                    p.ParameterName = "@Id";
                    p.Value = productId;
                    cmd.Parameters.Add(p);

                    cmd.ExecuteNonQuery();
                }
            }
        }

        // =====================================================================
        //  INSERT / UPDATE
        // =====================================================================

        public long InsertProduct(string name, string brand, string category,
            string description, decimal price, int stockQty, string imageUrl)
        {
            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        INSERT INTO products (name, brand, category, description, price, stock_qty, image_url)
                        VALUES (@Name, @Brand, @Category, @Description, @Price, @StockQty, @ImageUrl)
                        RETURNING id";

                    void Add(string n, object v) { DbParameter p = cmd.CreateParameter(); p.ParameterName = n; p.Value = v ?? DBNull.Value; cmd.Parameters.Add(p); }

                    Add("@Name",        name);
                    Add("@Brand",       string.IsNullOrWhiteSpace(brand)       ? (object)DBNull.Value : brand.Trim());
                    Add("@Category",    category);
                    Add("@Description", string.IsNullOrWhiteSpace(description) ? (object)DBNull.Value : description.Trim());
                    Add("@Price",       price);
                    Add("@StockQty",    stockQty);
                    Add("@ImageUrl",    string.IsNullOrWhiteSpace(imageUrl)    ? (object)DBNull.Value : imageUrl.Trim());

                    return Convert.ToInt64(cmd.ExecuteScalar());
                }
            }
        }

        public void UpdateProduct(long id, string name, string brand, string category,
            string description, decimal price, int stockQty, string imageUrl)
        {
            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    // Only update stock_qty when no variants control it.
                    cmd.CommandText = @"
                        UPDATE products SET
                            name        = @Name,
                            brand       = @Brand,
                            category    = @Category,
                            description = @Description,
                            price       = @Price,
                            image_url   = @ImageUrl,
                            stock_qty   = CASE
                                WHEN NOT EXISTS (SELECT 1 FROM product_variants WHERE product_id = @Id)
                                THEN @StockQty
                                ELSE stock_qty
                            END
                        WHERE id = @Id";

                    void Add(string n, object v) { DbParameter p = cmd.CreateParameter(); p.ParameterName = n; p.Value = v ?? DBNull.Value; cmd.Parameters.Add(p); }

                    Add("@Id",          id);
                    Add("@Name",        name);
                    Add("@Brand",       string.IsNullOrWhiteSpace(brand)       ? (object)DBNull.Value : brand.Trim());
                    Add("@Category",    category);
                    Add("@Description", string.IsNullOrWhiteSpace(description) ? (object)DBNull.Value : description.Trim());
                    Add("@Price",       price);
                    Add("@StockQty",    stockQty);
                    Add("@ImageUrl",    string.IsNullOrWhiteSpace(imageUrl)    ? (object)DBNull.Value : imageUrl.Trim());

                    cmd.ExecuteNonQuery();
                }
            }
        }

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
                            products.Add(MapRow(reader));
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
                            result.Items.Add(MapRow(reader));
                        }
                    }
                }
            }

            return result;
        }

        public IList<ProductVariant> GetProductVariants(long productId)
        {
            return GetVariantsByProductId(productId);
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

        private static Product MapRow(DbDataReader r)
        {
            return new Product
            {
                Id          = r.GetInt64(0),
                Name        = r.GetString(1),
                Brand       = r.IsDBNull(2) ? null : r.GetString(2),
                Category    = r.GetString(3),
                Description = r.IsDBNull(4) ? null : r.GetString(4),
                Price       = r.GetDecimal(5),
                StockQty    = r.GetInt32(6),
                ImageUrl    = r.IsDBNull(7) ? null : r.GetString(7),
                CreatedAt   = r.GetDateTime(8)
            };
        }
    }
}
