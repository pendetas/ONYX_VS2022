using System;
using System.Linq;
using System.Web.UI;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;
using ONYX_DDAC.Helpers;

namespace ONYX_DDAC.customer_page
{
    public partial class onyx_product_details : Page
    {
        private readonly ProductService productService = new ProductService();
        private readonly WishlistService wishlistService = new WishlistService();

        // NEW: Property to track the currently selected variant across postbacks
        protected long? SelectedVariantId
        {
            get { return ViewState["SelectedVariantId"] as long?; }
            set { ViewState["SelectedVariantId"] = value; }
        }

        protected int BaseStockQty
        {
            get { return ViewState["BaseStockQty"] == null ? 0 : (int)ViewState["BaseStockQty"]; }
            set { ViewState["BaseStockQty"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // If there's no ID in the URL, kick them back to the catalog
            if (!long.TryParse(Request.QueryString["id"], out long productId))
            {
                Response.Redirect("onyx_catalog.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadProductDetails(productId);
            }

            UpdateWishlistButton(productId);
        }

        private void LoadProductDetails(long productId)
        {
            Product currentProduct = productService.GetProductById(productId);

            // If the product doesn't exist in the DB, redirect
            if (currentProduct == null)
            {
                Response.Redirect("onyx_catalog.aspx");
                return;
            }

            // Bind base product details to the UI
            litBrandCategory.Text = $"{currentProduct.Brand} / {currentProduct.Category}";
            litName.Text = currentProduct.Name;
            litPrice.Text = CurrencyHelper.FormatMyr(currentProduct.Price);
            litDescription.Text = currentProduct.Description;
            BaseStockQty = currentProduct.StockQty;

            // Image Fallback check
            imgProduct.ImageUrl = string.IsNullOrWhiteSpace(currentProduct.ImageUrl)
                ? "/Content/home/products/onyx-mouse.png"
                : currentProduct.ImageUrl;

            // Check if this product has any variants in the product_variants table
            var variants = productService.GetProductVariants(productId);

            if (variants != null && variants.Any())
            {
                pnlVariants.Visible = true;
                litVariantType.Text = variants.First().VariantType; // E.g., "Color"

                // If nothing is selected yet, default to the first variant
                if (SelectedVariantId == null)
                {
                    SelectedVariantId = variants.First().ProductVariantId;
                }

                // Bind the swatches
                rptVariants.DataSource = variants;
                rptVariants.DataBind();

                // Update price, image, and the label text for the selected variant
                UpdatePriceForSelectedVariant(productId, SelectedVariantId.Value);
            }
            else
            {
                ApplyStockState(currentProduct.StockQty);
            }
        }

        // REPLACED: Handle Swatch Clicks instead of Dropdown
        protected void rptVariants_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "SelectVariant")
            {
                long variantId = long.Parse(e.CommandArgument.ToString());
                SelectedVariantId = variantId; // Save the newly selected ID

                if (long.TryParse(Request.QueryString["id"], out long productId))
                {
                    UpdatePriceForSelectedVariant(productId, variantId);

                    // Rebind the repeater so the green "is-active" border moves to the clicked swatch
                    var variants = productService.GetProductVariants(productId);
                    rptVariants.DataSource = variants;
                    rptVariants.DataBind();
                }
            }
        }

        private void UpdatePriceForSelectedVariant(long productId, long variantId)
        {
            var variants = productService.GetProductVariants(productId);
            var variant = variants.FirstOrDefault(v => v.ProductVariantId == variantId);

            if (variant != null)
            {
                // Update the displayed price
                litPrice.Text = CurrencyHelper.FormatMyr(variant.VariantPrice);

                // Update the label next to "COLOR:"
                lblSelectedVariantName.Text = variant.VariantValue;

                // Swap the main image if the variant has a custom image!
                if (!string.IsNullOrWhiteSpace(variant.ImageUrl))
                {
                    imgProduct.ImageUrl = variant.ImageUrl;
                }

                ApplyStockState(variant.StockQty);
            }
        }

        private void ApplyStockState(int stockQty)
        {
            string cssClass = "onyx-stock-status";
            string text;

            if (stockQty <= 0)
            {
                cssClass += " is-out";
                text = "Out of stock";
            }
            else if (stockQty <= 5)
            {
                cssClass += " is-low";
                text = $"Only {stockQty} left";
            }
            else
            {
                text = $"In stock: {stockQty}";
            }

            litStockStatus.Text = $"<span class=\"{cssClass}\">{Server.HtmlEncode(text)}</span>";
            txtQty.Attributes["max"] = Math.Max(stockQty, 0).ToString();
            btnAddToCart.Enabled = stockQty > 0;
            btnAddToCart.Text = stockQty > 0 ? "Add to Cart" : "Out of Stock";
            btnAddToCart.CssClass = stockQty > 0
                ? "onyx-add-to-cart flex-grow-1"
                : "onyx-add-to-cart flex-grow-1 disabled";
        }

        private int GetActiveStockQty(long productId, long? variantId)
        {
            if (variantId.HasValue)
            {
                var variants = productService.GetProductVariants(productId);
                var variant = variants.FirstOrDefault(v => v.ProductVariantId == variantId.Value);
                return variant == null ? 0 : variant.StockQty;
            }

            return BaseStockQty;
        }

        // NEW: Helper to assign the green glowing border to the active swatch
        protected string GetSwatchClass(object variantIdObj)
        {
            long variantId = Convert.ToInt64(variantIdObj);
            string baseClass = "onyx-color-swatch";

            if (SelectedVariantId.HasValue && SelectedVariantId.Value == variantId)
            {
                return baseClass + " is-active";
            }
            return baseClass;
        }

        // NEW: Helper to map database text strings to actual CSS Hex colors
        protected string GetColorHex(string colorName)
        {
            switch (colorName.Trim().ToLower())
            {
                case "white": return "#ffffff";

                // Grouping our green variants together
                case "toxic green":
                case "tactile green":
                    return "#39FF14";

                // Added a yellow hex for the linear switch
                case "linear yellow":
                    return "#FFD700";

                // Added a distinct light gray for the silent switch
                case "silent linear":
                    return "#888888";

                case "red": return "#ff0000";
                case "blue": return "#0000ff";
                case "pink": return "#ff1493";
                case "black":
                default:
                    // Using a dark grey instead of pure #000 so it doesn't vanish into the background
                    return "#1a1a1a";
            }
        }

        protected void btnAddToCart_Click(object sender, EventArgs e)
        {
            long productId = long.Parse(Request.QueryString["id"]);
            int qty = int.Parse(txtQty.Text);

            // Replaced dropdown value with the ViewState value
            long? variantId = null;
            if (pnlVariants.Visible && SelectedVariantId.HasValue)
            {
                variantId = SelectedVariantId.Value;
            }

            int activeStock = GetActiveStockQty(productId, variantId);
            ApplyStockState(activeStock);

            if (qty <= 0)
            {
                lblMessage.Text = "Please enter a valid quantity.";
                lblMessage.CssClass = "d-block mt-4 fw-bold text-danger";
                lblMessage.Visible = true;
                return;
            }

            if (qty > activeStock)
            {
                lblMessage.Text = $"Only {activeStock} item(s) are available for this selection.";
                lblMessage.CssClass = "d-block mt-4 fw-bold text-danger";
                lblMessage.Visible = true;
                return;
            }

            // --- ADD THIS TO CALL THE CART SERVICE ---
            CartService cartService = new CartService();
            cartService.AddToCart(productId, variantId, qty);

            lblMessage.Text = $"Successfully added {qty} item(s) to your cart.";
            lblMessage.CssClass = "d-block mt-4 fw-bold text-success";
            lblMessage.Visible = true;
        }

        protected void btnWishlist_Click(object sender, EventArgs e)
        {
            if (!long.TryParse(Request.QueryString["id"], out long productId))
            {
                Response.Redirect("onyx_catalog.aspx");
                return;
            }

            if (!TryGetCurrentUserId(out long userId))
            {
                Response.Redirect("~/auth_page/onyx_login.aspx?wishlist=true");
                return;
            }

            bool saved = wishlistService.ToggleWishlistItem(userId, productId);
            lblMessage.Text = saved ? "Saved to wishlist." : "Removed from wishlist.";

            lblMessage.CssClass = "d-block mt-3 fw-bold text-success";
            lblMessage.Visible = true;
            UpdateWishlistButton(productId);
        }

        private void UpdateWishlistButton(long productId)
        {
            bool saved = TryGetCurrentUserId(out long userId)
                && wishlistService.IsInWishlist(userId, productId);

            btnWishlist.CssClass = saved
                ? "onyx-detail-wishlist is-active"
                : "onyx-detail-wishlist";
            btnWishlist.ToolTip = saved ? "Remove from wishlist" : "Add to wishlist";
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
    }
}
