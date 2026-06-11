using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.customer_page
{
    public partial class onyx_wishlist : Page
    {
        private readonly WishlistService wishlistService = new WishlistService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!TryGetCurrentUserId(out long userId))
            {
                Response.Redirect("~/auth_page/onyx_login.aspx?wishlist=true");
                return;
            }

            if (!IsPostBack)
            {
                BindWishlist(userId);
            }
        }

        private void BindWishlist(long userId)
        {
            IList<Product> products = wishlistService.GetWishlistProducts(userId);

            pnlEmptyWishlist.Visible = products.Count == 0;
            pnlWishlist.Visible = products.Count > 0;

            rptWishlistItems.DataSource = products;
            rptWishlistItems.DataBind();

            litWishlistCount.Text = string.Format(
                "<span class=\"onyx-wishlist-count\">{0} {1}</span>",
                products.Count,
                products.Count == 1 ? "saved item" : "saved items");
        }

        protected void rptWishlistItems_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!TryGetCurrentUserId(out long userId))
            {
                Response.Redirect("~/auth_page/onyx_login.aspx?wishlist=true");
                return;
            }

            if (!long.TryParse((e.CommandArgument ?? string.Empty).ToString(), out long productId))
            {
                ShowFeedback("Unable to update that wishlist item.");
                BindWishlist(userId);
                return;
            }

            if (string.Equals(e.CommandName, "Remove", StringComparison.OrdinalIgnoreCase))
            {
                wishlistService.RemoveWishlistItem(userId, productId);
                ShowFeedback("Removed from wishlist.");
            }
            else if (string.Equals(e.CommandName, "MoveToCart", StringComparison.OrdinalIgnoreCase))
            {
                wishlistService.MoveWishlistItemToCart(userId, productId);
                ShowFeedback("Moved to cart.");
            }

            BindWishlist(userId);
        }

        protected string GetProductImageUrl(object imageUrl, object category)
        {
            string value = (imageUrl ?? string.Empty).ToString();
            if (!string.IsNullOrWhiteSpace(value))
            {
                return value;
            }

            switch (NormalizeCategory((category ?? string.Empty).ToString()))
            {
                case "Keyboard":
                    return "/Content/home/products/onyx-keyboard.png";
                case "Headset":
                    return "/Content/home/products/onyx-headset.png";
                case "Accessory":
                    return "/Content/home/onyx-pro-mouse.png";
                default:
                    return "/Content/home/products/onyx-mouse.png";
            }
        }

        protected string GetCategoryDisplayName(object category)
        {
            string value = (category ?? string.Empty).ToString();

            if (string.Equals(value, "Headset", StringComparison.OrdinalIgnoreCase))
            {
                return "Audio";
            }

            if (string.Equals(value, "Mouse", StringComparison.OrdinalIgnoreCase))
            {
                return "Gaming Mice";
            }

            return string.IsNullOrWhiteSpace(value) ? "Gear" : value;
        }

        protected string GetStockLabel(object stockQty)
        {
            if (stockQty == null || !int.TryParse(stockQty.ToString(), out int stock))
            {
                return "Ready";
            }

            if (stock <= 0)
            {
                return "Sold out";
            }

            if (stock <= 12)
            {
                return "Low stock";
            }

            return "In stock";
        }

        private void ShowFeedback(string message)
        {
            lblFeedback.Text = Server.HtmlEncode(message);
            lblFeedback.Visible = true;
        }

        private static bool TryGetCurrentUserId(out long userId)
        {
            userId = 0;
            object value = System.Web.HttpContext.Current.Session["UserId"];

            if (value == null)
            {
                return false;
            }

            if (value is long longValue)
            {
                userId = longValue;
                return true;
            }

            return long.TryParse(value.ToString(), out userId);
        }

        private static string NormalizeCategory(string rawCategory)
        {
            string value = (rawCategory ?? string.Empty).Trim().ToLowerInvariant();

            switch (value)
            {
                case "keyboard":
                case "keyboards":
                    return "Keyboard";
                case "audio":
                case "headset":
                case "headsets":
                    return "Headset";
                case "accessory":
                case "accessories":
                    return "Accessory";
                default:
                    return "Mouse";
            }
        }
    }
}
