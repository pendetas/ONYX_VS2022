using System.Collections.Generic;
using System.Linq;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.Services
{
    public class ProductService
    {
        private readonly ProductRepository _repo;
        private readonly PersonalizationService _personalizationService;

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

            if (string.Equals(normalizedQuery.Sort, "recommended", System.StringComparison.OrdinalIgnoreCase) &&
                normalizedQuery.UserId.HasValue)
            {
                IList<PersonalizedProduct> recommended =
                    _personalizationService.GetRecommendedProducts(normalizedQuery.UserId.Value, 48);

                IList<Product> filtered = recommended
                    .Select(item => item.Product)
                    .Where(product => string.IsNullOrWhiteSpace(normalizedQuery.Category) ||
                        string.Equals(product.Category, normalizedQuery.Category, System.StringComparison.OrdinalIgnoreCase))
                    .Where(product => string.IsNullOrWhiteSpace(normalizedQuery.SearchTerm) ||
                        (product.Name ?? string.Empty).IndexOf(normalizedQuery.SearchTerm, System.StringComparison.OrdinalIgnoreCase) >= 0 ||
                        (product.Description ?? string.Empty).IndexOf(normalizedQuery.SearchTerm, System.StringComparison.OrdinalIgnoreCase) >= 0)
                    .ToList();

                int totalCount = filtered.Count;
                int skip = (normalizedQuery.Page - 1) * normalizedQuery.PageSize;

                return new PagedResult<Product>
                {
                    Items = filtered.Skip(skip).Take(normalizedQuery.PageSize).ToList(),
                    Page = normalizedQuery.Page,
                    PageSize = normalizedQuery.PageSize,
                    TotalCount = totalCount
                };
            }

            return _repo.GetCatalogProducts(normalizedQuery);
        }

        public IList<ProductVariant> GetProductVariants(long productId)
        {
            return _repo.GetProductVariants(productId);
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
    }
}
