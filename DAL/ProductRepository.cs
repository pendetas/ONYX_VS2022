using System.Collections.Generic;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.DAL
{
    public class ProductRepository
    {
        public IList<Product> GetFeaturedProducts(int count)
        {
            return new List<Product>
            {
                new Product { Id = 1, Name = "Viper V2 Pro", Brand = "Razer", Category = "Mouse", Price = 599.00m, StockQty = 23 },
                new Product { Id = 2, Name = "BlackWidow V3", Brand = "Razer", Category = "Keyboard", Price = 449.00m, StockQty = 15 },
                new Product { Id = 3, Name = "Kraken X", Brand = "Razer", Category = "Headset", Price = 299.00m, StockQty = 31 },
                new Product { Id = 4, Name = "Predator XB273U", Brand = "Acer", Category = "Monitor", Price = 1899.00m, StockQty = 8 }
            }.GetRange(0, count > 4 ? 4 : count);
        }
    }
}
