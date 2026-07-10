using System;
using System.Collections.Generic;
using System.Data.Common;
using System.Diagnostics;
using System.Linq;
using Npgsql;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.Services
{
    public class ProductService
    {
        private readonly ProductRepository _repo;
        private readonly PersonalizationService _personalizationService;
        private static readonly HashSet<string> AllowedCampaignBlockTypes =
            new HashSet<string>(StringComparer.OrdinalIgnoreCase)
            {
                "HeroMedia",
                "TextSection",
                "TextImageSection",
                "MediaSection",
                "VideoSection",
                "FeatureCards",
                "TechSpecs",
                "CTASection",
                "SpacerSection"
            };

        public ProductService() : this(new ProductRepository(), new PersonalizationService()) { }

        public ProductService(ProductRepository repo)
            : this(repo, new PersonalizationService())
        {
        }

        public ProductService(ProductRepository repo, PersonalizationService personalizationService)
        {
            _repo = repo;
            _personalizationService = personalizationService;
        }

        // ── Customer-facing ──────────────────────────────────────────────────
        public IList<Product> GetFeaturedProducts(int count)
        {
            return _repo.GetFeaturedProducts(count);
        }

        // ── Admin: product list ──────────────────────────────────────────────
        public List<Product> GetAllProducts()
        {
            return _repo.GetAllProducts();
        }

        public List<string> GetDistinctCategories()
        {
            return _repo.GetDistinctCategories();
        }

        // ── Admin: single product ────────────────────────────────────────────
        public Product GetProductById(long id)
        {
            return _repo.GetProductById(id);
        }

        public List<ProductImage> GetProductImages(long productId)
        {
            return _repo.GetProductImages(productId);
        }

        public ProductCampaign GetProductCampaign(long productId)
        {
            return _repo.GetProductCampaign(productId);
        }

        public void SaveProductCampaign(ProductCampaign campaign)
        {
            if (campaign == null || campaign.ProductId <= 0) return;

            campaign.HeroEyebrow = NormalizeCampaignText(campaign.HeroEyebrow);
            campaign.HeroHeadline = NormalizeCampaignText(campaign.HeroHeadline);
            campaign.HeroBody = NormalizeCampaignText(campaign.HeroBody);
            campaign.HeroImageUrl = NormalizeCampaignText(campaign.HeroImageUrl);
            campaign.OverviewEyebrow = NormalizeCampaignText(campaign.OverviewEyebrow);
            campaign.OverviewHeadline = NormalizeCampaignText(campaign.OverviewHeadline);
            campaign.OverviewBody = NormalizeCampaignText(campaign.OverviewBody);
            campaign.PerformanceEyebrow = NormalizeCampaignText(campaign.PerformanceEyebrow);
            campaign.PerformanceHeadline = NormalizeCampaignText(campaign.PerformanceHeadline);
            campaign.PerformanceBody = NormalizeCampaignText(campaign.PerformanceBody);
            campaign.FeatureCards = NormalizeCampaignText(campaign.FeatureCards);
            campaign.SpecsText = NormalizeCampaignText(campaign.SpecsText);

            _repo.SaveProductCampaign(campaign);
        }

        public IList<ProductCampaignBlock> GetCampaignBlocksByProductId(long productId)
        {
            return _repo.GetCampaignBlocksByProductId(productId);
        }

        public string AddCampaignBlock(long productId, string blockType)
        {
            string normalizedBlockType = NormalizeCampaignBlockType(blockType);
            if (productId <= 0) return "Product not found.";
            if (string.IsNullOrWhiteSpace(normalizedBlockType)) return "Choose a valid campaign block type.";

            _repo.AddCampaignBlock(new ProductCampaignBlock
            {
                ProductId = productId,
                BlockType = normalizedBlockType,
                IsEnabled = true
            });

            _repo.EnsureProductCampaignEnabled(productId);
            _repo.EnsureSortOrderIntegrity(productId);
            return null;
        }

        public string AddCampaignBlock(ProductCampaignBlock block)
        {
            if (block == null || block.ProductId <= 0) return "Campaign block not found.";

            string normalizedBlockType = NormalizeCampaignBlockType(block.BlockType);
            if (string.IsNullOrWhiteSpace(normalizedBlockType)) return "Choose a valid campaign block type.";

            block.BlockType = normalizedBlockType;
            block.Eyebrow = NormalizeCampaignText(block.Eyebrow);
            block.Headline = NormalizeCampaignText(block.Headline);
            block.Body = NormalizeCampaignText(block.Body);
            block.MediaType = NormalizeCampaignText(block.MediaType);
            block.MediaUrl = NormalizeCampaignText(block.MediaUrl);
            block.MediaAlt = NormalizeCampaignText(block.MediaAlt);
            block.LayoutVariant = NormalizeCampaignText(block.LayoutVariant);
            block.BackgroundVariant = NormalizeCampaignText(block.BackgroundVariant);
            block.JsonContent = NormalizeCampaignText(block.JsonContent);

            _repo.AddCampaignBlock(block);
            if (block.IsEnabled)
            {
                _repo.EnsureProductCampaignEnabled(block.ProductId);
            }
            return null;
        }

        public string UpdateCampaignBlock(ProductCampaignBlock block)
        {
            if (block == null || block.Id <= 0 || block.ProductId <= 0) return "Campaign block not found.";

            string normalizedBlockType = NormalizeCampaignBlockType(block.BlockType);
            if (string.IsNullOrWhiteSpace(normalizedBlockType)) return "Choose a valid campaign block type.";

            block.BlockType = normalizedBlockType;
            block.Eyebrow = NormalizeCampaignText(block.Eyebrow);
            block.Headline = NormalizeCampaignText(block.Headline);
            block.Body = NormalizeCampaignText(block.Body);
            block.MediaType = NormalizeCampaignText(block.MediaType);
            block.MediaUrl = NormalizeCampaignText(block.MediaUrl);
            block.MediaAlt = NormalizeCampaignText(block.MediaAlt);
            block.LayoutVariant = NormalizeCampaignText(block.LayoutVariant);
            block.BackgroundVariant = NormalizeCampaignText(block.BackgroundVariant);
            block.JsonContent = NormalizeCampaignText(block.JsonContent);

            _repo.UpdateCampaignBlock(block);
            if (block.IsEnabled)
            {
                _repo.EnsureProductCampaignEnabled(block.ProductId);
            }
            return null;
        }

        public void DeleteCampaignBlock(long blockId, long productId)
        {
            _repo.DeleteCampaignBlock(blockId, productId);
        }

        public void MoveCampaignBlockUp(long blockId, long productId)
        {
            _repo.MoveCampaignBlockUp(blockId, productId);
        }

        public void MoveCampaignBlockDown(long blockId, long productId)
        {
            _repo.MoveCampaignBlockDown(blockId, productId);
        }

        public void ReorderCampaignBlocks(long productId)
        {
            _repo.ReorderCampaignBlocks(productId);
        }

        public void EnsureSortOrderIntegrity(long productId)
        {
            _repo.EnsureSortOrderIntegrity(productId);
        }

        public void EnsureProductImageRows(long productId, string imageUrl)
        {
            _repo.EnsureProductImageRows(productId, imageUrl);
        }

        public void SaveProductImages(long productId, IList<string> imageOrderTokens,
            ISet<long> removedImageIds, IList<string> newImagePaths, string fallbackImageUrl)
        {
            IList<string> orderTokens = imageOrderTokens ?? new List<string>();
            ISet<long> removedIds = removedImageIds ?? new HashSet<long>();
            IList<string> uploadedPaths = newImagePaths ?? new List<string>();
            Dictionary<long, ProductImage> existingImages = _repo.GetProductImages(productId)
                .ToDictionary(image => image.Id);
            var orderedImages = new List<ProductImage>();

            foreach (string rawToken in orderTokens)
            {
                string token = (rawToken ?? string.Empty).Trim();
                if (token.StartsWith("existing:", StringComparison.OrdinalIgnoreCase))
                {
                    long id;
                    if (!long.TryParse(token.Substring("existing:".Length), out id)) continue;
                    if (removedIds.Contains(id)) continue;
                    ProductImage image;
                    if (!existingImages.TryGetValue(id, out image)) continue;
                    orderedImages.Add(new ProductImage { ImagePath = image.ImagePath });
                }
                else if (token.StartsWith("new:", StringComparison.OrdinalIgnoreCase))
                {
                    int index;
                    if (int.TryParse(token.Substring("new:".Length), out index) &&
                        index >= 0 &&
                        index < uploadedPaths.Count &&
                        !string.IsNullOrWhiteSpace(uploadedPaths[index]))
                    {
                        orderedImages.Add(new ProductImage { ImagePath = uploadedPaths[index] });
                    }
                }
            }

            if (orderedImages.Count == 0 && orderTokens.Count == 0 && removedIds.Count == 0)
            {
                orderedImages.AddRange(existingImages
                    .Values
                    .OrderBy(image => image.DisplayOrder)
                    .ThenBy(image => image.Id)
                    .Select(image => new ProductImage { ImagePath = image.ImagePath }));
            }

            if (orderedImages.Count == 0 && orderTokens.Count == 0 && removedIds.Count == 0 &&
                !string.IsNullOrWhiteSpace(fallbackImageUrl))
            {
                orderedImages.Add(new ProductImage { ImagePath = fallbackImageUrl.Trim() });
            }

            for (int i = 0; i < orderedImages.Count; i++)
            {
                orderedImages[i].ProductId = productId;
                orderedImages[i].DisplayOrder = i;
                orderedImages[i].IsPrimary = i == 0;
            }

            _repo.ReplaceProductImages(productId, orderedImages);
        }

        // Validates and inserts a new product. Returns the new product ID,
        // or throws ArgumentException on invalid input.
        public long CreateProduct(string name, string brand, string category,
            string description, decimal price, int stockQty, string imageUrl)
        {
            if (string.IsNullOrWhiteSpace(name))
                throw new System.ArgumentException("Product name is required.");
            if (string.IsNullOrWhiteSpace(category))
                throw new System.ArgumentException("Category is required.");
            if (price < 0)
                throw new System.ArgumentException("Price must be 0 or greater.");
            if (stockQty < 0)
                throw new System.ArgumentException("Stock quantity must be 0 or greater.");

            return _repo.InsertProduct(name, brand, category, description, price, stockQty, imageUrl);
        }

        // Validates and updates an existing product.
        public void UpdateProduct(long id, string name, string brand, string category,
            string description, decimal price, int stockQty, string imageUrl)
        {
            if (string.IsNullOrWhiteSpace(name))
                throw new System.ArgumentException("Product name is required.");
            if (string.IsNullOrWhiteSpace(category))
                throw new System.ArgumentException("Category is required.");
            if (price < 0)
                throw new System.ArgumentException("Price must be 0 or greater.");
            if (stockQty < 0)
                throw new System.ArgumentException("Stock quantity must be 0 or greater.");

            _repo.UpdateProduct(id, name, brand, category, description, price, stockQty, imageUrl);
        }

        // ── Admin: variants ──────────────────────────────────────────────────
        public List<ProductVariant> GetVariantsByProductId(long productId)
        {
            return _repo.GetVariantsByProductId(productId);
        }

        // Returns error string or null on success.
        public string AddVariant(long productId, string type, string value,
            decimal price, int stockQty)
        {
            if (string.IsNullOrWhiteSpace(type))  return "Variant type is required.";
            if (string.IsNullOrWhiteSpace(value)) return "Variant value is required.";
            if (price < 0)    return "Price must be 0 or greater.";
            if (stockQty < 0) return "Stock must be 0 or greater.";

            _repo.AddVariant(productId, type, value, price, stockQty);
            return null;
        }

        // Returns error string or null on success.
        public string UpdateVariant(long variantId, long productId, decimal price, int stockQty)
        {
            if (price < 0)    return "Price must be 0 or greater.";
            if (stockQty < 0) return "Stock must be 0 or greater.";

            _repo.UpdateVariant(variantId, productId, price, stockQty);
            return null;
        }

        public void DeleteVariant(long variantId, long productId)
        {
            _repo.DeleteVariant(variantId, productId);
        }

        public string DeleteProduct(long id)
        {
            if (id <= 0) return "Product not found.";

            try
            {
                bool deleted = _repo.DeleteProduct(id);
                return deleted ? null : "Product not found.";
            }
            catch (PostgresException ex) when (ex.SqlState == PostgresErrorCodes.ForeignKeyViolation)
            {
                return "This product is linked to existing orders, reviews, or wishlists and cannot be deleted.";
            }
            catch (DbException)
            {
                throw;
            }
        }

        public PagedResult<Product> GetCatalogProducts(CatalogQuery query)
        {
            CatalogQuery normalizedQuery = query ?? new CatalogQuery();
            normalizedQuery.Category = (normalizedQuery.Category ?? string.Empty).Trim();
            normalizedQuery.SearchTerm = (normalizedQuery.SearchTerm ?? string.Empty).Trim();
            normalizedQuery.Sort = NormalizeSort(normalizedQuery.Sort);
            normalizedQuery.Page = normalizedQuery.Page < 1 ? 1 : normalizedQuery.Page;
            normalizedQuery.PageSize = normalizedQuery.PageSize < 1 || normalizedQuery.PageSize > 48
                ? 8
                : normalizedQuery.PageSize;

            if (string.Equals(normalizedQuery.Sort, "recommended", System.StringComparison.OrdinalIgnoreCase))
            {
                if (!normalizedQuery.UserId.HasValue)
                {
                    return GetRepositoryCatalogProducts(normalizedQuery);
                }

                try
                {
                    if (!_personalizationService.HasCompletedProfile(normalizedQuery.UserId.Value))
                    {
                        return GetRepositoryCatalogProducts(normalizedQuery);
                    }

                    IList<Product> filteredCandidates = _repo.GetAllProducts()
                        .Where(product => MatchesCategory(product, normalizedQuery.Category))
                        .Where(product => MatchesSearchTerm(product, normalizedQuery.SearchTerm))
                        .ToList();

                    if (filteredCandidates.Count <= 0)
                    {
                        return BuildPagedCatalogResult(new List<Product>(), normalizedQuery);
                    }

                    IList<Product> filtered = _personalizationService
                        .GetRecommendedProducts(
                            normalizedQuery.UserId.Value,
                            filteredCandidates,
                            normalizedQuery.CurrentSearchSignals,
                            filteredCandidates.Count)
                        .Select(item => item.Product)
                        .ToList();

                    if (filtered.Count <= 0)
                    {
                        return GetRepositoryCatalogProducts(normalizedQuery);
                    }

                    return BuildPagedCatalogResult(filtered, normalizedQuery);
                }
                catch (Exception exception)
                {
                    Trace.TraceWarning(
                        "Recommended catalog personalization lookup failed for user {0}: {1}",
                        normalizedQuery.UserId.Value,
                        exception);

                    return GetRepositoryCatalogProducts(normalizedQuery);
                }
            }

            return GetRepositoryCatalogProducts(normalizedQuery);
        }

        public IList<ProductVariant> GetProductVariants(long productId)
        {
            return _repo.GetProductVariants(productId);
        }

        private static PagedResult<Product> BuildPagedCatalogResult(IList<Product> filtered, CatalogQuery normalizedQuery)
        {
            int totalCount = filtered.Count;
            int totalPages = System.Math.Max(1, (int)System.Math.Ceiling(totalCount / (double)normalizedQuery.PageSize));
            int page = System.Math.Min(normalizedQuery.Page, totalPages);
            int skip = (page - 1) * normalizedQuery.PageSize;

            return new PagedResult<Product>
            {
                Items = filtered.Skip(skip).Take(normalizedQuery.PageSize).ToList(),
                Page = page,
                PageSize = normalizedQuery.PageSize,
                TotalCount = totalCount
            };
        }

        private static bool MatchesCategory(Product product, string category)
        {
            return string.IsNullOrWhiteSpace(category) ||
                string.Equals(product.Category, category, System.StringComparison.OrdinalIgnoreCase);
        }

        private static bool MatchesSearchTerm(Product product, string searchTerm)
        {
            return string.IsNullOrWhiteSpace(searchTerm) ||
                (product.Name ?? string.Empty).IndexOf(searchTerm, System.StringComparison.OrdinalIgnoreCase) >= 0 ||
                (product.Brand ?? string.Empty).IndexOf(searchTerm, System.StringComparison.OrdinalIgnoreCase) >= 0 ||
                (product.Category ?? string.Empty).IndexOf(searchTerm, System.StringComparison.OrdinalIgnoreCase) >= 0 ||
                (product.Description ?? string.Empty).IndexOf(searchTerm, System.StringComparison.OrdinalIgnoreCase) >= 0;
        }

        private static string NormalizeSort(string sort)
        {
            switch ((sort ?? string.Empty).Trim().ToLowerInvariant())
            {
                case "name":
                case "price-asc":
                case "price-desc":
                case "recommended":
                    return sort.Trim().ToLowerInvariant();
                default:
                    return "newest";
            }
        }

        private PagedResult<Product> GetRepositoryCatalogProducts(CatalogQuery query)
        {
            CatalogQuery repositoryQuery = new CatalogQuery
            {
                Category = query.Category,
                SearchTerm = query.SearchTerm,
                Sort = string.Equals(query.Sort, "recommended", System.StringComparison.OrdinalIgnoreCase)
                    ? "newest"
                    : query.Sort,
                Page = query.Page,
                PageSize = query.PageSize,
                UserId = query.UserId,
                CurrentSearchSignals = query.CurrentSearchSignals
            };

            return _repo.GetCatalogProducts(repositoryQuery);
        }

        private static string NormalizeCampaignText(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? null : value.Trim();
        }

        private static string NormalizeCampaignBlockType(string blockType)
        {
            string value = NormalizeCampaignText(blockType);
            if (value == null) return null;

            return AllowedCampaignBlockTypes.Contains(value) ? value : null;
        }
    }
}
