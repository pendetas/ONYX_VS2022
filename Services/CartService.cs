using System.Collections.Generic;
using System.Linq;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.Services
{
    public class CartService
    {
        public decimal CalculateSubtotal(IEnumerable<CartItem> items)
        {
            return items == null ? 0m : items.Sum(item => item.Subtotal);
        }

        public decimal CalculateTotal(IEnumerable<CartItem> items)
        {
            decimal subtotal = CalculateSubtotal(items);
            return subtotal == 0m ? 0m : subtotal + 10m;
        }
    }
}
