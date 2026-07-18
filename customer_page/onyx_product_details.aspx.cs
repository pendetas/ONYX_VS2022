using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
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

        protected string DetailsPageCssClass { get; private set; } = "onyx-details-page";

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
            else
            {
                Product currentProduct = productService.GetProductById(productId);
                if (currentProduct == null)
                {
                    Response.Redirect("onyx_catalog.aspx");
                    return;
                }

                BindProductCampaign(currentProduct);
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
            litBrandCategory.Text = Encode(FirstText(currentProduct.Brand, "ONYX") + " / " + FirstText(currentProduct.Category, "Uncategorized"));
            litName.Text = Encode(currentProduct.Name);
            litPrice.Text = CurrencyHelper.FormatMyr(currentProduct.Price);
            litDescription.Text = EncodeMultiline(currentProduct.Description);
            litDetailBrand.Text = Encode(FirstText(currentProduct.Brand, "ONYX"));
            litDetailCategory.Text = Encode(FirstText(currentProduct.Category, "Uncategorized"));
            BaseStockQty = currentProduct.StockQty;
            BindProductCampaign(currentProduct);

            // Image Fallback check
            imgProduct.ImageUrl = ResolveCampaignUrl(FirstText(currentProduct.ImageUrl, "/Content/home/products/onyx-mouse.png"));
            imgProduct.AlternateText = FirstText(currentProduct.Name, "ONYX product");
            BindProductImageNavigation(currentProduct);

            // Check if this product has any variants in the product_variants table
            var variants = productService.GetProductVariants(productId);

            if (variants != null && variants.Any())
            {
                pnlVariants.Visible = true;
                litVariantType.Text = Encode(FirstText(variants.First().VariantType, "Variant"));

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

        private void BindProductCampaign(Product product)
        {
            ProductCampaign campaign = productService.GetProductCampaign(product.Id);
            IList<ProductCampaignBlock> blocks = campaign != null && campaign.CampaignEnabled
                ? productService.GetCampaignBlocksByProductId(product.Id)
                : new List<ProductCampaignBlock>();
            IList<ProductCampaignBlock> enabledBlocks = blocks
                .Where(block => block.IsEnabled)
                .Where(block => HasVisibleCampaignBlockContent(block, product))
                .OrderBy(block => block.SortOrder)
                .ThenBy(block => block.Id)
                .ToList();

            bool showCampaign = enabledBlocks.Count > 0;

            DetailsPageCssClass = showCampaign
                ? "onyx-details-page onyx-product-campaign"
                : "onyx-details-page";

            pnlProductCampaign.Visible = showCampaign;
            litCampaignBlocks.Text = string.Empty;
            if (!showCampaign) return;

            litCampaignBlocks.Text = RenderCampaignBlocks(enabledBlocks, product);
        }

        private void BindProductImageNavigation(Product product)
        {
            IList<string> imageUrls = product.ImageUrls != null && product.ImageUrls.Count > 0
                ? product.ImageUrls
                : new List<string> { product.ImageUrl };
            List<string> resolvedUrls = imageUrls
                .Where(value => !string.IsNullOrWhiteSpace(value))
                .Select(ResolveCampaignUrl)
                .Where(value => !string.IsNullOrWhiteSpace(value))
                .ToList();

            if (resolvedUrls.Count <= 1)
            {
                litProductImageNav.Text = string.Empty;
                return;
            }

            var html = new StringBuilder();
            html.Append("<div class=\"onyx-detail-gallery-nav\" aria-label=\"Product photos\">");
            for (int i = 0; i < resolvedUrls.Count; i++)
            {
                html.AppendFormat(
                    "<button type=\"button\" class=\"onyx-detail-gallery-thumb{0}\" data-detail-target=\"{1}\" data-detail-image=\"{2}\" aria-label=\"Show product photo {3}\"><img src=\"{2}\" alt=\"\" loading=\"lazy\" /></button>",
                    i == 0 ? " is-active" : string.Empty,
                    EncodeAttr(imgProduct.ClientID),
                    EncodeAttr(resolvedUrls[i]),
                    i + 1);
            }
            html.Append("</div>");
            litProductImageNav.Text = html.ToString();
        }

        private string RenderCampaignBlocks(IList<ProductCampaignBlock> blocks, Product product)
        {
            var html = new StringBuilder();
            html.Append("<div class=\"onyx-campaign\">");

            foreach (ProductCampaignBlock block in blocks)
            {
                switch ((block.BlockType ?? string.Empty).Trim())
                {
                    case "HeroMedia":
                        html.Append(RenderHeroMediaBlock(block, product));
                        break;
                    case "TextSection":
                        html.Append(RenderTextSectionBlock(block));
                        break;
                    case "TextImageSection":
                        html.Append(RenderTextImageSectionBlock(block, product));
                        break;
                    case "MediaSection":
                        html.Append(RenderMediaSectionBlock(block, product));
                        break;
                    case "VideoSection":
                        html.Append(RenderVideoSectionBlock(block, product));
                        break;
                    case "FeatureCards":
                        html.Append(RenderFeatureCardsBlock(block));
                        break;
                    case "TechSpecs":
                        html.Append(RenderTechSpecsBlock(block));
                        break;
                    case "CTASection":
                        html.Append(RenderCtaSectionBlock(block));
                        break;
                    case "SpacerSection":
                        html.Append(RenderSpacerSectionBlock(block));
                        break;
                }
            }

            html.Append("</div>");
            return html.ToString();
        }

        private static bool HasVisibleCampaignBlockContent(ProductCampaignBlock block, Product product)
        {
            if (block == null || !block.IsEnabled) return false;

            string type = (block.BlockType ?? string.Empty).Trim();
            bool hasText = !string.IsNullOrWhiteSpace(block.Eyebrow)
                || !string.IsNullOrWhiteSpace(block.Headline)
                || !string.IsNullOrWhiteSpace(block.Body);
            bool hasMedia = !string.IsNullOrWhiteSpace(block.MediaUrl);

            switch (type)
            {
                case "HeroMedia":
                    return hasText || hasMedia || (product != null && (!string.IsNullOrWhiteSpace(product.Name) || !string.IsNullOrWhiteSpace(product.ImageUrl)));
                case "TextSection":
                    return hasText;
                case "TextImageSection":
                case "MediaSection":
                case "VideoSection":
                    return hasText || hasMedia;
                case "FeatureCards":
                    return hasText || ParseDelimitedLines(block.JsonContent, 2, 3).Count > 0;
                case "TechSpecs":
                    return hasText || ParseDelimitedLines(block.JsonContent, 2, 2).Count > 0;
                case "CTASection":
                    return hasText || ParseDelimitedLines(block.JsonContent, 2, 3).Count > 0;
                case "SpacerSection":
                    return true;
                default:
                    return false;
            }
        }

        private string RenderHeroMediaBlock(ProductCampaignBlock block, Product product)
        {
            string media = RenderMediaHtml(block, product, "onyx-campaign-hero-media", useProductFallback: true);
            return string.Format(
                "<section class=\"{0}\"><div class=\"onyx-campaign-inner onyx-campaign-hero\"><div class=\"onyx-campaign-text onyx-campaign-hero-text\">{1}{2}{3}</div>{4}</div></section>",
                CampaignBlockClass(block, "onyx-campaign-block--hero"),
                RenderEyebrow(block.Eyebrow),
                RenderHeadline(block.Headline, FirstText(product.Name)),
                RenderBody(block.Body, FirstText(product.Description)),
                media);
        }

        private string RenderTextSectionBlock(ProductCampaignBlock block)
        {
            return string.Format(
                "<section class=\"{0}\"><div class=\"onyx-campaign-inner onyx-campaign-text onyx-campaign-text--{1}\">{2}{3}{4}</div></section>",
                CampaignBlockClass(block, "onyx-campaign-block--text"),
                CssToken(FirstText(block.LayoutVariant, "center")),
                RenderEyebrow(block.Eyebrow),
                RenderHeadline(block.Headline, string.Empty),
                RenderBody(block.Body, string.Empty));
        }

        private string RenderTextImageSectionBlock(ProductCampaignBlock block, Product product)
        {
            string layout = CssToken(FirstText(block.LayoutVariant, "image-right"));
            return string.Format(
                "<section class=\"{0}\"><div class=\"onyx-campaign-inner onyx-campaign-text-image onyx-campaign-text-image--{1}\"><div class=\"onyx-campaign-text\">{2}{3}{4}</div>{5}</div></section>",
                CampaignBlockClass(block, "onyx-campaign-block--text-image"),
                layout,
                RenderEyebrow(block.Eyebrow),
                RenderHeadline(block.Headline, string.Empty),
                RenderBody(block.Body, string.Empty),
                RenderMediaHtml(block, product, "onyx-campaign-media"));
        }

        private string RenderMediaSectionBlock(ProductCampaignBlock block, Product product)
        {
            return string.Format(
                "<section class=\"{0}\"><div class=\"onyx-campaign-inner onyx-campaign-media-section\">{1}{2}</div></section>",
                CampaignBlockClass(block, "onyx-campaign-block--media"),
                RenderMediaHtml(block, product, "onyx-campaign-media"),
                RenderBody(block.Body, string.Empty));
        }

        private string RenderVideoSectionBlock(ProductCampaignBlock block, Product product)
        {
            return string.Format(
                "<section class=\"{0}\"><div class=\"onyx-campaign-inner onyx-campaign-video-section\">{1}{2}{3}</div></section>",
                CampaignBlockClass(block, "onyx-campaign-block--video"),
                RenderHeadline(block.Headline, string.Empty),
                RenderMediaHtml(new ProductCampaignBlock
                {
                    MediaType = FirstText(block.MediaType, "mp4"),
                    MediaUrl = block.MediaUrl,
                    MediaAlt = block.MediaAlt
                }, product, "onyx-campaign-video"),
                RenderBody(block.Body, string.Empty));
        }

        private string RenderFeatureCardsBlock(ProductCampaignBlock block)
        {
            IList<string[]> cards = ParseDelimitedLines(block.JsonContent, 2, 3);
            var html = new StringBuilder();
            html.AppendFormat("<section class=\"{0}\"><div class=\"onyx-campaign-inner\">{1}{2}{3}<div class=\"onyx-campaign-grid\">",
                CampaignBlockClass(block, "onyx-campaign-block--features"),
                RenderEyebrow(block.Eyebrow),
                RenderHeadline(block.Headline, string.Empty),
                RenderBody(block.Body, string.Empty));

            foreach (string[] card in cards)
            {
                string imageUrl = card.Length > 2 ? ResolveCampaignUrl(card[2]) : string.Empty;
                html.Append("<article class=\"onyx-campaign-feature-card\">");
                if (!string.IsNullOrWhiteSpace(imageUrl))
                    html.AppendFormat("<img src=\"{0}\" alt=\"{1}\" loading=\"lazy\" />", EncodeAttr(imageUrl), EncodeAttr(card[0]));
                html.AppendFormat("<h3>{0}</h3><p>{1}</p>", Encode(card[0]), Encode(card[1]));
                html.Append("</article>");
            }

            html.Append("</div></div></section>");
            return html.ToString();
        }

        private string RenderTechSpecsBlock(ProductCampaignBlock block)
        {
            IList<string[]> specs = ParseDelimitedLines(block.JsonContent, 2, 2);
            var html = new StringBuilder();
            html.AppendFormat("<section class=\"{0}\"><div class=\"onyx-campaign-inner onyx-campaign-specs\">{1}{2}{3}<dl>",
                CampaignBlockClass(block, "onyx-campaign-block--specs"),
                RenderEyebrow(block.Eyebrow),
                RenderHeadline(block.Headline, "Tech Specs"),
                RenderBody(block.Body, string.Empty));

            foreach (string[] spec in specs)
                html.AppendFormat("<div><dt>{0}</dt><dd>{1}</dd></div>", Encode(spec[0]), Encode(spec[1]));

            html.Append("</dl></div></section>");
            return html.ToString();
        }

        private string RenderCtaSectionBlock(ProductCampaignBlock block)
        {
            IList<string[]> ctas = ParseDelimitedLines(block.JsonContent, 2, 3);
            var html = new StringBuilder();
            html.AppendFormat("<section class=\"{0}\"><div class=\"onyx-campaign-inner onyx-campaign-cta\">{1}{2}{3}<div class=\"onyx-campaign-cta-actions\">",
                CampaignBlockClass(block, "onyx-campaign-block--cta"),
                RenderEyebrow(block.Eyebrow),
                RenderHeadline(block.Headline, string.Empty),
                RenderBody(block.Body, string.Empty));

            foreach (string[] cta in ctas)
            {
                string url = ResolveCampaignUrl(cta[1]);
                if (string.IsNullOrWhiteSpace(url)) continue;
                string style = cta.Length > 2 ? CssToken(cta[2]) : "primary";
                html.AppendFormat("<a class=\"onyx-campaign-cta-link onyx-campaign-cta-link--{0}\" href=\"{1}\">{2}</a>",
                    style,
                    EncodeAttr(url),
                    Encode(cta[0]));
            }

            html.Append("</div></div></section>");
            return html.ToString();
        }

        private string RenderSpacerSectionBlock(ProductCampaignBlock block)
        {
            return string.Format(
                "<div class=\"onyx-campaign-spacer onyx-campaign-spacer--{0}\" aria-hidden=\"true\"></div>",
                CssToken(FirstText(block.LayoutVariant, "medium")));
        }

        private string RenderMediaHtml(ProductCampaignBlock block, Product product, string cssClass, bool useProductFallback = false)
        {
            string mediaUrl = ResolveCampaignUrl(useProductFallback ? FirstText(block.MediaUrl, product.ImageUrl) : block.MediaUrl);
            if (string.IsNullOrWhiteSpace(mediaUrl)) return string.Empty;

            string mediaType = FirstText(block.MediaType, mediaUrl.EndsWith(".mp4", StringComparison.OrdinalIgnoreCase) ? "mp4" : "image").ToLowerInvariant();
            string alt = FirstText(block.MediaAlt, product.Name, "ONYX product media");
            if (mediaType == "mp4" || mediaType == "video")
            {
                return string.Format("<video class=\"{0}\" src=\"{1}\" title=\"{2}\" controls muted loop playsinline></video>",
                    EncodeAttr(cssClass),
                    EncodeAttr(mediaUrl),
                    EncodeAttr(alt));
            }

            return string.Format("<img class=\"{0}\" src=\"{1}\" alt=\"{2}\" loading=\"lazy\" />",
                EncodeAttr(cssClass),
                EncodeAttr(mediaUrl),
                EncodeAttr(alt));
        }

        private string CampaignBlockClass(ProductCampaignBlock block, string baseClass)
        {
            string background = CssToken(FirstText(block.BackgroundVariant, block.LayoutVariant, "light"));
            string layout = CssToken(FirstText(block.LayoutVariant, "default"));
            string themeClass = background == "dark" || layout == "dark"
                ? "onyx-campaign-block--dark"
                : "onyx-campaign-block--light";

            return string.Format("onyx-campaign-block {0} {1} onyx-campaign-block--layout-{2}",
                EncodeAttr(baseClass),
                themeClass,
                EncodeAttr(layout));
        }

        private string RenderEyebrow(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? string.Empty : "<span class=\"onyx-campaign-eyebrow\">" + Encode(value) + "</span>";
        }

        private string RenderHeadline(string value, string fallback)
        {
            string text = FirstText(value, fallback);
            return string.IsNullOrWhiteSpace(text) ? string.Empty : "<h2>" + Encode(text) + "</h2>";
        }

        private string RenderBody(string value, string fallback)
        {
            string text = FirstText(value, fallback);
            return string.IsNullOrWhiteSpace(text) ? string.Empty : "<p>" + EncodeMultiline(text) + "</p>";
        }

        private static IList<string[]> ParseDelimitedLines(string rawValue, int minimumParts, int maximumParts)
        {
            var rows = new List<string[]>();
            foreach (string line in (rawValue ?? string.Empty).Split(new[] { "\r\n", "\n" }, StringSplitOptions.RemoveEmptyEntries))
            {
                string[] parts = line
                    .Split('|')
                    .Take(maximumParts)
                    .Select(part => part.Trim())
                    .ToArray();

                if (parts.Length < minimumParts) continue;
                if (parts.Take(minimumParts).Any(string.IsNullOrWhiteSpace)) continue;
                rows.Add(parts);
            }

            return rows;
        }

        private string ResolveCampaignUrl(string value)
        {
            if (string.IsNullOrWhiteSpace(value)) return string.Empty;
            string trimmed = value.Trim();

            if (trimmed.StartsWith("javascript:", StringComparison.OrdinalIgnoreCase) ||
                trimmed.StartsWith("vbscript:", StringComparison.OrdinalIgnoreCase) ||
                trimmed.StartsWith("data:", StringComparison.OrdinalIgnoreCase) ||
                trimmed.StartsWith("//", StringComparison.Ordinal))
            {
                return string.Empty;
            }

            Uri absoluteUri;
            if (Uri.TryCreate(trimmed, UriKind.Absolute, out absoluteUri))
            {
                return absoluteUri.Scheme == Uri.UriSchemeHttp || absoluteUri.Scheme == Uri.UriSchemeHttps
                    ? trimmed
                    : string.Empty;
            }

            return trimmed.StartsWith("/", StringComparison.Ordinal)
                ? trimmed
                : ResolveUrl(trimmed);
        }

        private static string Encode(string value)
        {
            return HttpUtility.HtmlEncode(value ?? string.Empty);
        }

        private static string EncodeAttr(string value)
        {
            return HttpUtility.HtmlAttributeEncode(value ?? string.Empty);
        }

        private static string EncodeMultiline(string value)
        {
            return Encode(value).Replace("\r\n", "<br />").Replace("\n", "<br />");
        }

        private static string CssToken(string value)
        {
            if (string.IsNullOrWhiteSpace(value)) return "default";

            var token = new StringBuilder();
            foreach (char c in value.Trim().ToLowerInvariant())
            {
                if ((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '-')
                    token.Append(c);
                else if (char.IsWhiteSpace(c) || c == '_')
                    token.Append('-');
            }

            return token.Length == 0 ? "default" : token.ToString();
        }

        private static string FirstText(params string[] values)
        {
            foreach (string value in values)
                if (!string.IsNullOrWhiteSpace(value))
                    return value.Trim();

            return string.Empty;
        }

        // REPLACED: Handle Swatch Clicks instead of Dropdown
        protected void rptVariants_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "SelectVariant")
            {
                long variantId;
                if (!long.TryParse(Convert.ToString(e.CommandArgument), out variantId) || variantId <= 0) return;
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
                lblSelectedVariantName.Text = Encode(variant.VariantValue);

                // Swap the main image if the variant has a custom image!
                if (!string.IsNullOrWhiteSpace(variant.ImageUrl))
                {
                    imgProduct.ImageUrl = ResolveCampaignUrl(variant.ImageUrl);
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
            litDetailAvailability.Text = Encode(text);
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
            switch ((colorName ?? string.Empty).Trim().ToLowerInvariant())
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
            AuthHelper.RequireLogin(this);

            long productId;
            int qty;
            if (!long.TryParse(Request.QueryString["id"], out productId) || productId <= 0)
            {
                Response.Redirect("onyx_catalog.aspx");
                return;
            }
            if (!int.TryParse(txtQty.Text, out qty))
            {
                lblMessage.Text = "Please enter a valid quantity.";
                lblMessage.CssClass = "d-block mt-4 fw-bold text-danger";
                lblMessage.Visible = true;
                return;
            }

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
