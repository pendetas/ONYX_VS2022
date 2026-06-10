using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.customer_page
{
    public partial class onyx_catalog : Page
    {
        private readonly ProductService productService = new ProductService();
        private readonly WishlistRepository wishlistRepository = new WishlistRepository();
        private HashSet<long> wishlistProductIds = new HashSet<long>();

        protected string SelectedCategory { get; private set; }
        protected string CatalogTitle { get; private set; }
        protected string CatalogDescription { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            SelectedCategory = NormalizeCategory(Request.QueryString["category"]);

            if (!IsPostBack)
            {
                BindCatalog();
            }
        }

        private void BindCatalog()
        {
            IList<Product> products = productService.GetCatalogProducts(SelectedCategory);
            LoadWishlistProductIds();

            ProductsRepeater.DataSource = products;
            ProductsRepeater.DataBind();

            EmptyCatalogPanel.Visible = products.Count == 0;
            CatalogCountLiteral.Text = string.Format(
                "<span class=\"onyx-catalog-count\">{0} {1}</span>",
                products.Count,
                products.Count == 1 ? "drop" : "drops");

            CatalogTitle = GetCatalogTitle(SelectedCategory);
            CatalogDescription = GetCatalogDescription(SelectedCategory);
        }

        protected void ProductsRepeater_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!string.Equals(e.CommandName, "ToggleWishlist", StringComparison.OrdinalIgnoreCase))
            {
                return;
            }

            if (!TryGetCurrentUserId(out long userId))
            {
                Response.Redirect("~/auth_page/onyx_login.aspx?wishlist=true");
                return;
            }

            if (!long.TryParse((e.CommandArgument ?? string.Empty).ToString(), out long productId))
            {
                ShowCatalogFeedback("Unable to update wishlist.");
                BindCatalog();
                return;
            }

            if (wishlistRepository.IsInWishlist(userId, productId))
            {
                wishlistRepository.RemoveWishlistItem(userId, productId);
                ShowCatalogFeedback("Removed from wishlist.");
            }
            else
            {
                wishlistRepository.AddWishlistItem(userId, productId);
                ShowCatalogFeedback("Added to wishlist.");
            }

            BindCatalog();
        }

        protected string GetWishlistButtonClass(object productId)
        {
            return IsProductInWishlist(productId)
                ? "onyx-product-love hover-trigger is-active"
                : "onyx-product-love hover-trigger";
        }

        protected string GetWishlistButtonLabel(object productId)
        {
            return IsProductInWishlist(productId) ? "Remove from wishlist" : "Add to wishlist";
        }

        private bool IsProductInWishlist(object productId)
        {
            return productId != null
                && long.TryParse(productId.ToString(), out long id)
                && wishlistProductIds.Contains(id);
        }

        private void LoadWishlistProductIds()
        {
            wishlistProductIds = new HashSet<long>();

            if (!TryGetCurrentUserId(out long userId))
            {
                return;
            }

            wishlistProductIds = new HashSet<long>(
                wishlistRepository.GetWishlistProducts(userId).Select(product => product.Id));
        }

        private void ShowCatalogFeedback(string message)
        {
            CatalogFeedbackLabel.Text = Server.HtmlEncode(message);
            CatalogFeedbackLabel.Visible = true;
        }

        protected string GetFilterClass(string category)
        {
            bool isActive = string.Equals(SelectedCategory ?? string.Empty, category ?? string.Empty, StringComparison.OrdinalIgnoreCase);
            return isActive ? "onyx-catalog-pill is-active hover-trigger" : "onyx-catalog-pill hover-trigger";
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

            return value;
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

        protected string GetStockLabel(object stockQty)
        {
            int stock;
            if (stockQty == null || !int.TryParse(stockQty.ToString(), out stock))
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

        private static string NormalizeCategory(string rawCategory)
        {
            string value = (rawCategory ?? string.Empty).Trim().ToLowerInvariant();

            switch (value)
            {
                case "mouse":
                case "mice":
                case "gaming-mice":
                case "gaming mice":
                    return "Mouse";
                case "keyboard":
                case "keyboards":
                    return "Keyboard";
                case "audio":
                case "headset":
                case "headsets":
                case "headphone":
                case "headphones":
                    return "Headset";
                case "accessory":
                case "accessories":
                    return "Accessory";
                default:
                    return string.Empty;
            }
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

        private static string GetCatalogTitle(string category)
        {
            switch (category)
            {
                case "Mouse":
                    return "Gaming Mice";
                case "Keyboard":
                    return "Keyboards";
                case "Headset":
                    return "Audio";
                case "Accessory":
                    return "Accessories";
                default:
                    return "Catalog";
            }
        }

        private static string GetCatalogDescription(string category)
        {
            switch (category)
            {
                case "Mouse":
                    return "Precision mice built for control, low-latency aim and long sessions under pressure.";
                case "Keyboard":
                    return "Tactile boards, tuned acoustics and compact layouts for fast command flow.";
                case "Headset":
                    return "Spatial audio and clean comms for players who need every cue to land clearly.";
                case "Accessory":
                    return "Desk essentials that complete the setup without adding clutter.";
                default:
                    return "Curated ONYX gaming gear across mice, keyboards, audio and desk essentials.";
            }
        }
    }
}
