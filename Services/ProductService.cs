using System.Collections.Generic;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.Services
{
    public class ProductService
    {
        private readonly ProductRepository productRepository;

        public ProductService() : this(new ProductRepository())
        {
        }

        public ProductService(ProductRepository productRepository)
        {
            this.productRepository = productRepository;
        }

        public IList<Product> GetFeaturedProducts(int count)
        {
            return productRepository.GetFeaturedProducts(count);
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

            return productRepository.GetCatalogProducts(normalizedQuery);
        }

        private static string NormalizeSort(string sort)
        {
            switch ((sort ?? string.Empty).Trim().ToLowerInvariant())
            {
                case "name":
                case "price-asc":
                case "price-desc":
                    return sort.Trim().ToLowerInvariant();
                default:
                    return "newest";
            }
        }

        // Added missing method for the Details page
        public Product GetProductById(long id)
        {
            return productRepository.GetProductById(id);
        }

        // Added missing method for the Variants
        public IList<ProductVariant> GetProductVariants(long productId)
        {
            return productRepository.GetProductVariants(productId);
        }
    }
}
