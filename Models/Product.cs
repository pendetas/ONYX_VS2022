using System;
using System.Collections.Generic;

namespace ONYX_DDAC.Models
{
    [Serializable]
    public class Product
    {
        public Product()
        {
            ImageUrls = new List<string>();
        }

        public long Id { get; set; }
        public string Name { get; set; }
        public string Brand { get; set; }
        public string Category { get; set; }
        public string Description { get; set; }
        public decimal Price { get; set; }
        public int StockQty { get; set; }
        public string ImageUrl { get; set; }
        public IList<string> ImageUrls { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
