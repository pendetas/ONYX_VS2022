using System;
using System.Collections.Generic;
using System.Web.UI;
using ONYX_DDAC.Helpers;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.customer_page
{
    public partial class onyx_cart : Page
    {
        private readonly CartService cartService = new CartService();

        protected void Page_Load(object sender, EventArgs e)
        {
            IList<CartItem> cart = Session["Cart"] as IList<CartItem> ?? new List<CartItem>();
            decimal total = cartService.CalculateTotal(cart);
            CartSummaryLiteral.Text = cart.Count == 0
                ? "<p class=\"onyx-muted mb-0\">Your cart is empty.</p>"
                : "<p class=\"mb-0\">Cart total: " + CurrencyHelper.FormatMyr(total) + "</p>";
        }
    }
}
