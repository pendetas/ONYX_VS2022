using System;
using System.Collections.Generic;
using System.Data.Common;
using System.Linq;
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
            HydrateProductImageUrls(list);
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
                        if (r.Read())
                        {
                            Product product = MapRow(r);
                            HydrateProductImageUrls(new List<Product> { product });
                            return product;
                        }
                    }
                }
            }
            return null;
        }

        public void UpdateProductImageUrl(long productId, string imageUrl)
        {
            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "UPDATE products SET image_url = @ImageUrl WHERE id = @ProductId";

                    DbParameter imageParam = cmd.CreateParameter();
                    imageParam.ParameterName = "@ImageUrl";
                    imageParam.Value = string.IsNullOrWhiteSpace(imageUrl) ? (object)DBNull.Value : imageUrl.Trim();
                    cmd.Parameters.Add(imageParam);

                    DbParameter productIdParam = cmd.CreateParameter();
                    productIdParam.ParameterName = "@ProductId";
                    productIdParam.Value = productId;
                    cmd.Parameters.Add(productIdParam);

                    cmd.ExecuteNonQuery();
                }
            }
        }

        public List<ProductImage> GetProductImages(long productId)
        {
            var list = new List<ProductImage>();
            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT id, product_id, image_path, display_order, is_primary, created_at
                        FROM product_images
                        WHERE product_id = @ProductId
                        ORDER BY display_order ASC, id ASC";

                    DbParameter productIdParam = cmd.CreateParameter();
                    productIdParam.ParameterName = "@ProductId";
                    productIdParam.Value = productId;
                    cmd.Parameters.Add(productIdParam);

                    using (DbDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                            list.Add(MapProductImageRow(r));
                    }
                }
            }
            return list;
        }

        public void EnsureProductImageRows(long productId, string imageUrl)
        {
            if (productId <= 0 || string.IsNullOrWhiteSpace(imageUrl)) return;

            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        INSERT INTO product_images (product_id, image_path, display_order, is_primary)
                        SELECT @ProductId, @ImagePath, 0, true
                        WHERE NOT EXISTS (
                            SELECT 1
                            FROM product_images
                            WHERE product_id = @ProductId
                        )";

                    DbParameter productIdParam = cmd.CreateParameter();
                    productIdParam.ParameterName = "@ProductId";
                    productIdParam.Value = productId;
                    cmd.Parameters.Add(productIdParam);

                    DbParameter imagePathParam = cmd.CreateParameter();
                    imagePathParam.ParameterName = "@ImagePath";
                    imagePathParam.Value = imageUrl.Trim();
                    cmd.Parameters.Add(imagePathParam);

                    cmd.ExecuteNonQuery();
                }
            }
        }

        public void ReplaceProductImages(long productId, IList<ProductImage> images)
        {
            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbTransaction tx = conn.BeginTransaction())
                {
                    using (DbCommand deleteCmd = conn.CreateCommand())
                    {
                        deleteCmd.Transaction = tx;
                        deleteCmd.CommandText = "DELETE FROM product_images WHERE product_id = @ProductId";

                        DbParameter productIdParam = deleteCmd.CreateParameter();
                        productIdParam.ParameterName = "@ProductId";
                        productIdParam.Value = productId;
                        deleteCmd.Parameters.Add(productIdParam);

                        deleteCmd.ExecuteNonQuery();
                    }

                    int order = 0;
                    foreach (ProductImage image in images ?? new List<ProductImage>())
                    {
                        if (image == null || string.IsNullOrWhiteSpace(image.ImagePath)) continue;

                        using (DbCommand insertCmd = conn.CreateCommand())
                        {
                            insertCmd.Transaction = tx;
                            insertCmd.CommandText = @"
                                INSERT INTO product_images (product_id, image_path, display_order, is_primary)
                                VALUES (@ProductId, @ImagePath, @DisplayOrder, @IsPrimary)";

                            void Add(string n, object v) { DbParameter p = insertCmd.CreateParameter(); p.ParameterName = n; p.Value = v; insertCmd.Parameters.Add(p); }

                            Add("@ProductId", productId);
                            Add("@ImagePath", image.ImagePath.Trim());
                            Add("@DisplayOrder", order);
                            Add("@IsPrimary", order == 0);

                            insertCmd.ExecuteNonQuery();
                        }
                        order++;
                    }

                    using (DbCommand syncCmd = conn.CreateCommand())
                    {
                        syncCmd.Transaction = tx;
                        syncCmd.CommandText = @"
                            UPDATE products
                            SET image_url = (
                                SELECT image_path
                                FROM product_images
                                WHERE product_id = @ProductId
                                ORDER BY is_primary DESC, display_order ASC, id ASC
                                LIMIT 1
                            )
                            WHERE id = @ProductId";

                        DbParameter productIdParam = syncCmd.CreateParameter();
                        productIdParam.ParameterName = "@ProductId";
                        productIdParam.Value = productId;
                        syncCmd.Parameters.Add(productIdParam);

                        syncCmd.ExecuteNonQuery();
                    }

                    tx.Commit();
                }
            }
        }

        public void SyncPrimaryProductImage(long productId)
        {
            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        UPDATE products
                        SET image_url = (
                            SELECT image_path
                            FROM product_images
                            WHERE product_id = @ProductId
                            ORDER BY is_primary DESC, display_order ASC, id ASC
                            LIMIT 1
                        )
                        WHERE id = @ProductId";

                    DbParameter productIdParam = cmd.CreateParameter();
                    productIdParam.ParameterName = "@ProductId";
                    productIdParam.Value = productId;
                    cmd.Parameters.Add(productIdParam);

                    cmd.ExecuteNonQuery();
                }
            }
        }

        public ProductCampaign GetProductCampaign(long productId)
        {
            try
            {
                using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
                {
                    conn.Open();
                    using (DbCommand cmd = conn.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT product_id, campaign_enabled, hero_eyebrow, hero_headline, hero_body, hero_image_url,
                                   overview_eyebrow, overview_headline, overview_body,
                                   performance_eyebrow, performance_headline, performance_body,
                                   feature_cards, specs_text, created_at, updated_at
                            FROM product_campaigns
                            WHERE product_id = @ProductId";

                        DbParameter productIdParam = cmd.CreateParameter();
                        productIdParam.ParameterName = "@ProductId";
                        productIdParam.Value = productId;
                        cmd.Parameters.Add(productIdParam);

                        using (DbDataReader r = cmd.ExecuteReader())
                        {
                            if (r.Read()) return MapProductCampaignRow(r);
                        }
                    }
                }
            }
            catch (PostgresException ex) when (ex.SqlState == PostgresErrorCodes.UndefinedTable)
            {
                return null;
            }

            return null;
        }

        public void SaveProductCampaign(ProductCampaign campaign)
        {
            if (campaign == null || campaign.ProductId <= 0) return;

            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        INSERT INTO product_campaigns (
                            product_id, campaign_enabled, hero_eyebrow, hero_headline, hero_body, hero_image_url,
                            overview_eyebrow, overview_headline, overview_body,
                            performance_eyebrow, performance_headline, performance_body,
                            feature_cards, specs_text, updated_at
                        )
                        VALUES (
                            @ProductId, @CampaignEnabled, @HeroEyebrow, @HeroHeadline, @HeroBody, @HeroImageUrl,
                            @OverviewEyebrow, @OverviewHeadline, @OverviewBody,
                            @PerformanceEyebrow, @PerformanceHeadline, @PerformanceBody,
                            @FeatureCards, @SpecsText, now()
                        )
                        ON CONFLICT (product_id) DO UPDATE SET
                            campaign_enabled = EXCLUDED.campaign_enabled,
                            hero_eyebrow = EXCLUDED.hero_eyebrow,
                            hero_headline = EXCLUDED.hero_headline,
                            hero_body = EXCLUDED.hero_body,
                            hero_image_url = EXCLUDED.hero_image_url,
                            overview_eyebrow = EXCLUDED.overview_eyebrow,
                            overview_headline = EXCLUDED.overview_headline,
                            overview_body = EXCLUDED.overview_body,
                            performance_eyebrow = EXCLUDED.performance_eyebrow,
                            performance_headline = EXCLUDED.performance_headline,
                            performance_body = EXCLUDED.performance_body,
                            feature_cards = EXCLUDED.feature_cards,
                            specs_text = EXCLUDED.specs_text,
                            updated_at = now()";

                    void Add(string n, object v)
                    {
                        DbParameter p = cmd.CreateParameter();
                        p.ParameterName = n;
                        p.Value = v ?? DBNull.Value;
                        cmd.Parameters.Add(p);
                    }

                    Add("@ProductId", campaign.ProductId);
                    Add("@CampaignEnabled", campaign.CampaignEnabled);
                    Add("@HeroEyebrow", NormalizeOptionalText(campaign.HeroEyebrow));
                    Add("@HeroHeadline", NormalizeOptionalText(campaign.HeroHeadline));
                    Add("@HeroBody", NormalizeOptionalText(campaign.HeroBody));
                    Add("@HeroImageUrl", NormalizeOptionalText(campaign.HeroImageUrl));
                    Add("@OverviewEyebrow", NormalizeOptionalText(campaign.OverviewEyebrow));
                    Add("@OverviewHeadline", NormalizeOptionalText(campaign.OverviewHeadline));
                    Add("@OverviewBody", NormalizeOptionalText(campaign.OverviewBody));
                    Add("@PerformanceEyebrow", NormalizeOptionalText(campaign.PerformanceEyebrow));
                    Add("@PerformanceHeadline", NormalizeOptionalText(campaign.PerformanceHeadline));
                    Add("@PerformanceBody", NormalizeOptionalText(campaign.PerformanceBody));
                    Add("@FeatureCards", NormalizeOptionalText(campaign.FeatureCards));
                    Add("@SpecsText", NormalizeOptionalText(campaign.SpecsText));

                    cmd.ExecuteNonQuery();
                }
            }
        }

        public void EnsureProductCampaignEnabled(long productId)
        {
            if (productId <= 0) return;

            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        INSERT INTO product_campaigns (
                            product_id, campaign_enabled, updated_at
                        )
                        VALUES (
                            @ProductId, true, now()
                        )
                        ON CONFLICT (product_id) DO UPDATE SET
                            campaign_enabled = true,
                            updated_at = now()
                        WHERE product_campaigns.campaign_enabled = false";

                    DbParameter productIdParam = cmd.CreateParameter();
                    productIdParam.ParameterName = "@ProductId";
                    productIdParam.Value = productId;
                    cmd.Parameters.Add(productIdParam);

                    cmd.ExecuteNonQuery();
                }
            }
        }

        public List<ProductCampaignBlock> GetCampaignBlocksByProductId(long productId)
        {
            var list = new List<ProductCampaignBlock>();
            if (productId <= 0) return list;

            try
            {
                using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
                {
                    conn.Open();
                    using (DbCommand cmd = conn.CreateCommand())
                    {
                        cmd.CommandText = @"
                            SELECT id, product_id, block_type, sort_order, is_enabled,
                                   eyebrow, headline, body,
                                   media_type, media_url, media_alt,
                                   layout_variant, background_variant, json_content,
                                   created_at, updated_at
                            FROM public.product_campaign_blocks
                            WHERE product_id = @ProductId
                            ORDER BY sort_order ASC, id ASC";

                        DbParameter productIdParam = cmd.CreateParameter();
                        productIdParam.ParameterName = "@ProductId";
                        productIdParam.Value = productId;
                        cmd.Parameters.Add(productIdParam);

                        using (DbDataReader r = cmd.ExecuteReader())
                        {
                            while (r.Read())
                                list.Add(MapProductCampaignBlockRow(r));
                        }
                    }
                }
            }
            catch (PostgresException ex) when (ex.SqlState == PostgresErrorCodes.UndefinedTable)
            {
                return list;
            }

            return list;
        }

        public long AddCampaignBlock(ProductCampaignBlock block)
        {
            if (block == null || block.ProductId <= 0 || string.IsNullOrWhiteSpace(block.BlockType)) return 0;

            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                EnsureProductCampaignBlocksTable(conn);
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        INSERT INTO public.product_campaign_blocks (
                            product_id, block_type, sort_order, is_enabled,
                            eyebrow, headline, body,
                            media_type, media_url, media_alt,
                            layout_variant, background_variant, json_content,
                            updated_at
                        )
                        VALUES (
                            @ProductId,
                            @BlockType,
                            COALESCE((
                                SELECT MAX(sort_order) + 1
                                FROM public.product_campaign_blocks
                                WHERE product_id = @ProductId
                            ), 1),
                            @IsEnabled,
                            @Eyebrow, @Headline, @Body,
                            @MediaType, @MediaUrl, @MediaAlt,
                            @LayoutVariant, @BackgroundVariant, @JsonContent,
                            now()
                        )
                        RETURNING id";

                    AddCampaignBlockParameters(cmd, block);
                    object result = cmd.ExecuteScalar();
                    return result == null || result == DBNull.Value ? 0 : Convert.ToInt64(result);
                }
            }
        }

        private static void EnsureProductCampaignBlocksTable(DbConnection conn)
        {
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.CommandText = @"
                    CREATE TABLE IF NOT EXISTS public.product_campaign_blocks (
                      id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                      product_id BIGINT NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
                      block_type VARCHAR(50) NOT NULL,
                      sort_order INTEGER NOT NULL,
                      is_enabled BOOLEAN NOT NULL DEFAULT true,
                      eyebrow VARCHAR(100),
                      headline VARCHAR(200),
                      body TEXT,
                      media_type VARCHAR(20),
                      media_url TEXT,
                      media_alt VARCHAR(200),
                      layout_variant VARCHAR(50),
                      background_variant VARCHAR(50),
                      json_content TEXT,
                      created_at TIMESTAMP NOT NULL DEFAULT now(),
                      updated_at TIMESTAMP
                    );

                    CREATE INDEX IF NOT EXISTS ix_product_campaign_blocks_product_sort
                      ON public.product_campaign_blocks (product_id, sort_order, id);";

                cmd.ExecuteNonQuery();
            }
        }

        public void UpdateCampaignBlock(ProductCampaignBlock block)
        {
            if (block == null || block.Id <= 0 || block.ProductId <= 0) return;

            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        UPDATE public.product_campaign_blocks
                        SET is_enabled = @IsEnabled,
                            eyebrow = @Eyebrow,
                            headline = @Headline,
                            body = @Body,
                            media_type = @MediaType,
                            media_url = @MediaUrl,
                            media_alt = @MediaAlt,
                            layout_variant = @LayoutVariant,
                            background_variant = @BackgroundVariant,
                            json_content = @JsonContent,
                            updated_at = now()
                        WHERE id = @Id
                          AND product_id = @ProductId";

                    AddCampaignBlockParameters(cmd, block);
                    DbParameter idParam = cmd.CreateParameter();
                    idParam.ParameterName = "@Id";
                    idParam.Value = block.Id;
                    cmd.Parameters.Add(idParam);

                    cmd.ExecuteNonQuery();
                }
            }
        }

        public void DeleteCampaignBlock(long blockId, long productId)
        {
            if (blockId <= 0 || productId <= 0) return;

            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        DELETE FROM public.product_campaign_blocks
                        WHERE id = @Id
                          AND product_id = @ProductId";

                    DbParameter idParam = cmd.CreateParameter();
                    idParam.ParameterName = "@Id";
                    idParam.Value = blockId;
                    cmd.Parameters.Add(idParam);

                    DbParameter productIdParam = cmd.CreateParameter();
                    productIdParam.ParameterName = "@ProductId";
                    productIdParam.Value = productId;
                    cmd.Parameters.Add(productIdParam);

                    cmd.ExecuteNonQuery();
                }
            }

            EnsureSortOrderIntegrity(productId);
        }

        public void MoveCampaignBlockUp(long blockId, long productId)
        {
            MoveCampaignBlock(blockId, productId, moveUp: true);
        }

        public void MoveCampaignBlockDown(long blockId, long productId)
        {
            MoveCampaignBlock(blockId, productId, moveUp: false);
        }

        public void ReorderCampaignBlocks(long productId)
        {
            EnsureSortOrderIntegrity(productId);
        }

        public void EnsureSortOrderIntegrity(long productId)
        {
            if (productId <= 0) return;

            try
            {
                using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
                {
                    conn.Open();
                    using (DbCommand cmd = conn.CreateCommand())
                    {
                        cmd.CommandText = @"
                            WITH ordered AS (
                                SELECT id,
                                       ROW_NUMBER() OVER (ORDER BY sort_order ASC, id ASC) AS new_sort_order
                                FROM public.product_campaign_blocks
                                WHERE product_id = @ProductId
                            )
                            UPDATE public.product_campaign_blocks AS block
                            SET sort_order = ordered.new_sort_order
                            FROM ordered
                            WHERE block.id = ordered.id";

                        DbParameter productIdParam = cmd.CreateParameter();
                        productIdParam.ParameterName = "@ProductId";
                        productIdParam.Value = productId;
                        cmd.Parameters.Add(productIdParam);

                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (PostgresException ex) when (ex.SqlState == PostgresErrorCodes.UndefinedTable)
            {
            }
        }

        private void MoveCampaignBlock(long blockId, long productId, bool moveUp)
        {
            if (blockId <= 0 || productId <= 0) return;

            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbTransaction tx = conn.BeginTransaction())
                {
                    int currentSortOrder;
                    using (DbCommand currentCmd = conn.CreateCommand())
                    {
                        currentCmd.Transaction = tx;
                        currentCmd.CommandText = @"
                            SELECT sort_order
                            FROM public.product_campaign_blocks
                            WHERE id = @Id
                              AND product_id = @ProductId";

                        DbParameter idParam = currentCmd.CreateParameter();
                        idParam.ParameterName = "@Id";
                        idParam.Value = blockId;
                        currentCmd.Parameters.Add(idParam);

                        DbParameter productIdParam = currentCmd.CreateParameter();
                        productIdParam.ParameterName = "@ProductId";
                        productIdParam.Value = productId;
                        currentCmd.Parameters.Add(productIdParam);

                        object current = currentCmd.ExecuteScalar();
                        if (current == null || current == DBNull.Value)
                        {
                            tx.Rollback();
                            return;
                        }

                        currentSortOrder = Convert.ToInt32(current);
                    }

                    long neighborId = 0;
                    int neighborSortOrder = 0;
                    using (DbCommand neighborCmd = conn.CreateCommand())
                    {
                        neighborCmd.Transaction = tx;
                        neighborCmd.CommandText = moveUp
                            ? @"
                                SELECT id, sort_order
                                FROM public.product_campaign_blocks
                                WHERE product_id = @ProductId
                                  AND is_enabled = true
                                  AND sort_order < @SortOrder
                                ORDER BY sort_order DESC, id DESC
                                LIMIT 1"
                            : @"
                                SELECT id, sort_order
                                FROM public.product_campaign_blocks
                                WHERE product_id = @ProductId
                                  AND is_enabled = true
                                  AND sort_order > @SortOrder
                                ORDER BY sort_order ASC, id ASC
                                LIMIT 1";

                        DbParameter productIdParam = neighborCmd.CreateParameter();
                        productIdParam.ParameterName = "@ProductId";
                        productIdParam.Value = productId;
                        neighborCmd.Parameters.Add(productIdParam);

                        DbParameter sortParam = neighborCmd.CreateParameter();
                        sortParam.ParameterName = "@SortOrder";
                        sortParam.Value = currentSortOrder;
                        neighborCmd.Parameters.Add(sortParam);

                        using (DbDataReader r = neighborCmd.ExecuteReader())
                        {
                            if (r.Read())
                            {
                                neighborId = r.GetInt64(0);
                                neighborSortOrder = r.GetInt32(1);
                            }
                        }
                    }

                    if (neighborId <= 0)
                    {
                        tx.Rollback();
                        return;
                    }

                    using (DbCommand updateCmd = conn.CreateCommand())
                    {
                        updateCmd.Transaction = tx;
                        updateCmd.CommandText = @"
                            UPDATE public.product_campaign_blocks
                            SET sort_order = CASE
                                    WHEN id = @CurrentId THEN @NeighborSortOrder
                                    WHEN id = @NeighborId THEN @CurrentSortOrder
                                    ELSE sort_order
                                END,
                                updated_at = now()
                            WHERE product_id = @ProductId
                              AND id IN (@CurrentId, @NeighborId)";

                        DbParameter currentIdParam = updateCmd.CreateParameter();
                        currentIdParam.ParameterName = "@CurrentId";
                        currentIdParam.Value = blockId;
                        updateCmd.Parameters.Add(currentIdParam);

                        DbParameter neighborIdParam = updateCmd.CreateParameter();
                        neighborIdParam.ParameterName = "@NeighborId";
                        neighborIdParam.Value = neighborId;
                        updateCmd.Parameters.Add(neighborIdParam);

                        DbParameter currentSortParam = updateCmd.CreateParameter();
                        currentSortParam.ParameterName = "@CurrentSortOrder";
                        currentSortParam.Value = currentSortOrder;
                        updateCmd.Parameters.Add(currentSortParam);

                        DbParameter neighborSortParam = updateCmd.CreateParameter();
                        neighborSortParam.ParameterName = "@NeighborSortOrder";
                        neighborSortParam.Value = neighborSortOrder;
                        updateCmd.Parameters.Add(neighborSortParam);

                        DbParameter productIdParam = updateCmd.CreateParameter();
                        productIdParam.ParameterName = "@ProductId";
                        productIdParam.Value = productId;
                        updateCmd.Parameters.Add(productIdParam);

                        updateCmd.ExecuteNonQuery();
                    }

                    tx.Commit();
                }
            }
        }

        private static void AddCampaignBlockParameters(DbCommand cmd, ProductCampaignBlock block)
        {
            void Add(string n, object v)
            {
                DbParameter p = cmd.CreateParameter();
                p.ParameterName = n;
                p.Value = v ?? DBNull.Value;
                cmd.Parameters.Add(p);
            }

            Add("@ProductId", block.ProductId);
            Add("@BlockType", block.BlockType);
            Add("@IsEnabled", block.IsEnabled);
            Add("@Eyebrow", NormalizeOptionalText(block.Eyebrow));
            Add("@Headline", NormalizeOptionalText(block.Headline));
            Add("@Body", NormalizeOptionalText(block.Body));
            Add("@MediaType", NormalizeOptionalText(block.MediaType));
            Add("@MediaUrl", NormalizeOptionalText(block.MediaUrl));
            Add("@MediaAlt", NormalizeOptionalText(block.MediaAlt));
            Add("@LayoutVariant", NormalizeOptionalText(block.LayoutVariant));
            Add("@BackgroundVariant", NormalizeOptionalText(block.BackgroundVariant));
            Add("@JsonContent", NormalizeOptionalText(block.JsonContent));
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

        public bool DeleteProduct(long id)
        {
            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = "DELETE FROM products WHERE id = @ProductId";

                    DbParameter productIdParam = cmd.CreateParameter();
                    productIdParam.ParameterName = "@ProductId";
                    productIdParam.Value = id;
                    cmd.Parameters.Add(productIdParam);

                    return cmd.ExecuteNonQuery() > 0;
                }
            }
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

            HydrateProductImageUrls(products);
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

            HydrateProductImageUrls(result.Items);
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

        private void HydrateProductImageUrls(IList<Product> products)
        {
            if (products == null || products.Count == 0) return;

            Dictionary<long, Product> productById = products
                .Where(product => product != null)
                .GroupBy(product => product.Id)
                .ToDictionary(group => group.Key, group => group.First());
            if (productById.Count == 0) return;

            foreach (Product product in productById.Values)
            {
                product.ImageUrls = new List<string>();
            }

            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    var parameterNames = new List<string>();
                    int index = 0;
                    foreach (long productId in productById.Keys)
                    {
                        string parameterName = "@ProductId" + index.ToString();
                        parameterNames.Add(parameterName);
                        DbParameter parameter = cmd.CreateParameter();
                        parameter.ParameterName = parameterName;
                        parameter.Value = productId;
                        cmd.Parameters.Add(parameter);
                        index++;
                    }

                    cmd.CommandText = @"
                        SELECT product_id, image_path
                        FROM product_images
                        WHERE product_id IN (" + string.Join(",", parameterNames) + @")
                        ORDER BY product_id ASC, is_primary DESC, display_order ASC, id ASC";

                    using (DbDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            long productId = r.GetInt64(0);
                            string imagePath = r.IsDBNull(1) ? null : r.GetString(1);
                            Product product;
                            if (!string.IsNullOrWhiteSpace(imagePath) && productById.TryGetValue(productId, out product))
                            {
                                product.ImageUrls.Add(imagePath);
                            }
                        }
                    }
                }
            }

            foreach (Product product in productById.Values)
            {
                if (product.ImageUrls.Count == 0 && !string.IsNullOrWhiteSpace(product.ImageUrl))
                {
                    product.ImageUrls.Add(product.ImageUrl);
                }

                if (product.ImageUrls.Count > 0)
                {
                    product.ImageUrl = product.ImageUrls[0];
                }
            }
        }

        private static ProductImage MapProductImageRow(DbDataReader r)
        {
            return new ProductImage
            {
                Id = r.GetInt64(0),
                ProductId = r.GetInt64(1),
                ImagePath = r.GetString(2),
                DisplayOrder = r.GetInt32(3),
                IsPrimary = r.GetBoolean(4),
                CreatedAt = r.GetDateTime(5)
            };
        }

        private static ProductCampaign MapProductCampaignRow(DbDataReader r)
        {
            return new ProductCampaign
            {
                ProductId = r.GetInt64(0),
                CampaignEnabled = r.GetBoolean(1),
                HeroEyebrow = ReadNullableString(r, 2),
                HeroHeadline = ReadNullableString(r, 3),
                HeroBody = ReadNullableString(r, 4),
                HeroImageUrl = ReadNullableString(r, 5),
                OverviewEyebrow = ReadNullableString(r, 6),
                OverviewHeadline = ReadNullableString(r, 7),
                OverviewBody = ReadNullableString(r, 8),
                PerformanceEyebrow = ReadNullableString(r, 9),
                PerformanceHeadline = ReadNullableString(r, 10),
                PerformanceBody = ReadNullableString(r, 11),
                FeatureCards = ReadNullableString(r, 12),
                SpecsText = ReadNullableString(r, 13),
                CreatedAt = r.GetDateTime(14),
                UpdatedAt = r.GetDateTime(15)
            };
        }

        private static ProductCampaignBlock MapProductCampaignBlockRow(DbDataReader r)
        {
            return new ProductCampaignBlock
            {
                Id = r.GetInt64(0),
                ProductId = r.GetInt64(1),
                BlockType = r.GetString(2),
                SortOrder = r.GetInt32(3),
                IsEnabled = r.GetBoolean(4),
                Eyebrow = ReadNullableString(r, 5),
                Headline = ReadNullableString(r, 6),
                Body = ReadNullableString(r, 7),
                MediaType = ReadNullableString(r, 8),
                MediaUrl = ReadNullableString(r, 9),
                MediaAlt = ReadNullableString(r, 10),
                LayoutVariant = ReadNullableString(r, 11),
                BackgroundVariant = ReadNullableString(r, 12),
                JsonContent = ReadNullableString(r, 13),
                CreatedAt = r.GetDateTime(14),
                UpdatedAt = r.IsDBNull(15) ? (DateTime?)null : r.GetDateTime(15)
            };
        }

        private static string ReadNullableString(DbDataReader r, int ordinal)
        {
            return r.IsDBNull(ordinal) ? null : r.GetString(ordinal);
        }

        private static object NormalizeOptionalText(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? (object)DBNull.Value : value.Trim();
        }

    }
}
