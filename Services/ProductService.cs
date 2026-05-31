using System.Collections.Generic;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.Services
{
    public class ProductService
    {
        private readonly ProductRepository productRepository;

        public ProductService()
            : this(new ProductRepository())
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
    }
}
