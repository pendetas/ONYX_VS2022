using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.customer_page
{
    public partial class onyx_catalog : Page
    {
        private const string RecentSearchSessionKey = "OnyxRecentSearchSignals";
        private readonly ProductService productService = new ProductService();
        private readonly WishlistService wishlistService = new WishlistService();
        private readonly PersonalizationService personalizationService = new PersonalizationService();
        private HashSet<long> wishlistProductIds = new HashSet<long>();

        protected string SelectedCategory { get; private set; }
        protected string SearchTerm { get; private set; }
        protected string SelectedSort { get; private set; }
        protected int CurrentPage { get; private set; }
        protected string CatalogTitle { get; private set; }
        protected string CatalogDescription { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            SelectedCategory = NormalizeCategory(Request.QueryString["category"]);
            SearchTerm = (Request.QueryString["q"] ?? string.Empty).Trim();
            SelectedSort = ResolveCatalogSort(Request.QueryString["sort"]);
            CurrentPage = ParsePage(Request.QueryString["page"]);

            if (!IsPostBack)
            {
                BindCatalog();
            }
        }

        private void BindCatalog()
        {
            long userId;
            long? recommendationUserId = TryGetCurrentUserId(out userId) ? (long?)userId : null;
            if (!string.IsNullOrWhiteSpace(SearchTerm))
            {
                StoreRecentSearchSignal(SearchTerm);
            }

            PagedResult<Product> result = productService.GetCatalogProducts(new CatalogQuery
            {
                Category = SelectedCategory,
                SearchTerm = SearchTerm,
                Sort = SelectedSort,
                Page = CurrentPage,
                PageSize = 8,
                UserId = recommendationUserId,
                CurrentSearchSignals = GetRecentSearchSignals()
            });

            if (recommendationUserId.HasValue && !string.IsNullOrWhiteSpace(SearchTerm))
            {
                personalizationService.RecordCatalogSearch(recommendationUserId.Value, SearchTerm);
            }

            CurrentPage = result.Page;
            LoadWishlistProductIds();

            ProductsRepeater.DataSource = result.Items;
            ProductsRepeater.DataBind();

            EmptyCatalogPanel.Visible = result.TotalCount == 0;
            CatalogCountLiteral.Text = string.Format(
                "<span class=\"onyx-catalog-count\">{0} {1}</span>",
                result.TotalCount,
                result.TotalCount == 1 ? "product" : "products");
            CatalogPagerLiteral.Text = BuildPager(result);

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

            bool saved = wishlistService.ToggleWishlistItem(userId, productId);
            ShowCatalogFeedback(saved ? "Added to wishlist." : "Removed from wishlist.");

            BindCatalog();
        }

        protected string GetWishlistButtonClass(object productId)
        {
            return IsProductInWishlist(productId)
                ? "onyx-product-love is-active"
                : "onyx-product-love";
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

            wishlistProductIds = new HashSet<long>(wishlistService.GetWishlistProductIds(userId));
        }

        private void ShowCatalogFeedback(string message)
        {
            CatalogFeedbackLabel.Text = Server.HtmlEncode(message);
            CatalogFeedbackLabel.Visible = true;
        }

        protected string GetFilterClass(string category)
        {
            bool isActive = string.Equals(SelectedCategory ?? string.Empty, category ?? string.Empty, StringComparison.OrdinalIgnoreCase);
            return isActive ? "onyx-catalog-pill is-active" : "onyx-catalog-pill";
        }

        protected string GetCatalogUrl(string category)
        {
            return BuildCatalogUrl(1, category, SearchTerm, SelectedSort);
        }

        protected string GetSelectedSortAttribute(string sort)
        {
            return string.Equals(SelectedSort, sort, StringComparison.OrdinalIgnoreCase)
                ? " selected=\"selected\""
                : string.Empty;
        }

        private string BuildPager(PagedResult<Product> result)
        {
            if (result.TotalPages <= 1)
            {
                return string.Empty;
            }

            var html = new StringBuilder();
            html.Append("<nav class=\"onyx-catalog-pager\" aria-label=\"Catalog pages\">");
            AppendPagerLink(html, result.Page - 1, "Previous", result.Page == 1);

            for (int page = 1; page <= result.TotalPages; page++)
            {
                string activeClass = page == result.Page ? " is-active" : string.Empty;
                html.AppendFormat(
                    "<a class=\"onyx-catalog-page-link{0}\" href=\"{1}\" aria-label=\"Page {2}\">{2}</a>",
                    activeClass,
                    Server.HtmlEncode(BuildCatalogUrl(page, SelectedCategory, SearchTerm, SelectedSort)),
                    page);
            }

            AppendPagerLink(html, result.Page + 1, "Next", result.Page == result.TotalPages);
            html.Append("</nav>");
            return html.ToString();
        }

        private void AppendPagerLink(StringBuilder html, int page, string label, bool disabled)
        {
            if (disabled)
            {
                html.AppendFormat("<span class=\"onyx-catalog-page-link is-disabled\">{0}</span>", label);
                return;
            }

            html.AppendFormat(
                "<a class=\"onyx-catalog-page-link\" href=\"{0}\">{1}</a>",
                Server.HtmlEncode(BuildCatalogUrl(page, SelectedCategory, SearchTerm, SelectedSort)),
                label);
        }

        private static string BuildCatalogUrl(int page, string category, string searchTerm, string sort)
        {
            var parameters = new List<string>();

            if (!string.IsNullOrWhiteSpace(category))
            {
                parameters.Add("category=" + Uri.EscapeDataString(category));
            }

            if (!string.IsNullOrWhiteSpace(searchTerm))
            {
                parameters.Add("q=" + Uri.EscapeDataString(searchTerm));
            }

            if (!string.IsNullOrWhiteSpace(sort) && !string.Equals(sort, "newest", StringComparison.OrdinalIgnoreCase))
            {
                parameters.Add("sort=" + Uri.EscapeDataString(sort));
            }

            if (page > 1)
            {
                parameters.Add("page=" + page);
            }

            return "onyx_catalog.aspx" + (parameters.Count == 0 ? string.Empty : "?" + string.Join("&", parameters));
        }

        private void StoreRecentSearchSignal(string searchTerm)
        {
            IList<string> signals = GetRecentSearchSignals();
            signals.Insert(0, searchTerm.Trim());
            IList<string> filteredSignals = signals
                .Where(value => !string.IsNullOrWhiteSpace(value))
                .Take(10)
                .ToList();

            Session[RecentSearchSessionKey] = filteredSignals;
            Response.Cookies["onyx_recent_search"].Value = EncodeRecentSearchSignals(filteredSignals);
            Response.Cookies["onyx_recent_search"].Expires = DateTime.UtcNow.AddDays(14);
        }

        private IList<string> GetRecentSearchSignals()
        {
            var values = Session[RecentSearchSessionKey] as IList<string>;
            if (values != null)
            {
                return values.ToList();
            }

            string cookieValue = Request.Cookies["onyx_recent_search"] == null
                ? string.Empty
                : Request.Cookies["onyx_recent_search"].Value;

            return DecodeRecentSearchSignals(cookieValue);
        }

        private static string EncodeRecentSearchSignals(IList<string> signals)
        {
            return string.Join("|", (signals ?? new List<string>())
                .Where(value => !string.IsNullOrWhiteSpace(value))
                .Take(10)
                .Select(value => HttpUtility.UrlEncode(value.Trim())));
        }

        private static IList<string> DecodeRecentSearchSignals(string encodedValue)
        {
            return (encodedValue ?? string.Empty)
                .Split(new[] { '|' }, StringSplitOptions.RemoveEmptyEntries)
                .Select(HttpUtility.UrlDecode)
                .Select(value => (value ?? string.Empty).Trim())
                .Where(value => value.Length > 0)
                .Take(10)
                .ToList();
        }

        private static int ParsePage(string value)
        {
            return int.TryParse(value, out int page) && page > 0 ? page : 1;
        }

        private static string NormalizeSort(string value)
        {
            switch ((value ?? string.Empty).Trim().ToLowerInvariant())
            {
                case "name":
                case "price-asc":
                case "price-desc":
                case "recommended":
                    return value.Trim().ToLowerInvariant();
                default:
                    return "newest";
            }
        }

        private string ResolveCatalogSort(string value)
        {
            string explicitSort = Request.QueryString["sort"];
            if (!string.IsNullOrWhiteSpace(explicitSort))
            {
                return NormalizeSort(explicitSort);
            }

            if (TryGetCurrentUserId(out _))
            {
                return "recommended";
            }

            return NormalizeSort(value);
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

        // Returns a browser-safe DB image URL, or a category fallback when none is stored.
        protected string GetProductImageUrl(object imageUrl, object category)
        {
            string value = (imageUrl ?? string.Empty).ToString().Trim().Replace('\\', '/');
            if (!string.IsNullOrWhiteSpace(value))
            {
                Uri absoluteUri;
                if (Uri.TryCreate(value, UriKind.Absolute, out absoluteUri)
                    && (absoluteUri.Scheme == Uri.UriSchemeHttp || absoluteUri.Scheme == Uri.UriSchemeHttps))
                {
                    return value;
                }

                string applicationPath = value.StartsWith("~/", StringComparison.Ordinal)
                    ? value.Substring(2)
                    : value.TrimStart('/');

                return ResolveUrl("~/" + applicationPath);
            }

            // Fallback: no image in DB — serve by category from products folder
            switch (NormalizeCategory((category ?? string.Empty).ToString()))
            {
                case "Keyboard":
                    return "/Content/home/products/onyx-keyboard.png";
                case "Headset":
                    return "/Content/home/products/onyx-headset.png";
                case "Monitor":
                case "Monitor Extension":
                    return "/Content/home/products/onyx-monitor.png";
                case "Mic":
                    return "/Content/home/products/onyx-headset.png";
                default: // Mouse, Chair, Accessory, unknown
                    return "/Content/home/products/onyx-mouse.png";
            }
        }

        protected string GetProductGalleryHtml(object dataItem)
        {
            var product = dataItem as Product;
            if (product == null) return string.Empty;

            IList<string> imageUrls = product.ImageUrls != null && product.ImageUrls.Count > 0
                ? product.ImageUrls
                : new List<string> { product.ImageUrl };
            List<string> resolvedUrls = imageUrls
                .Where(value => !string.IsNullOrWhiteSpace(value))
                .Select(value => GetProductImageUrl(value, product.Category))
                .ToList();

            if (resolvedUrls.Count == 0)
            {
                resolvedUrls.Add(GetProductImageUrl(null, product.Category));
            }

            var html = new StringBuilder();
            html.AppendFormat("<div class=\"onyx-product-gallery\" data-product-gallery data-gallery-index=\"0\" aria-label=\"{0} photos\">",
                HttpUtility.HtmlAttributeEncode(product.Name));

            for (int i = 0; i < resolvedUrls.Count; i++)
            {
                string activeClass = i == 0 ? " is-active" : string.Empty;
                html.AppendFormat(
                    "<img class=\"onyx-product-gallery-slide{0}\" data-gallery-slide src=\"{1}\" alt=\"{2}\" loading=\"lazy\" />",
                    activeClass,
                    HttpUtility.HtmlAttributeEncode(resolvedUrls[i]),
                    HttpUtility.HtmlAttributeEncode(product.Name));
            }

            if (resolvedUrls.Count > 1)
            {
                html.Append("<button type=\"button\" class=\"onyx-product-gallery-nav onyx-product-gallery-nav--prev\" data-gallery-prev aria-label=\"Previous product photo\">‹</button>");
                html.Append("<button type=\"button\" class=\"onyx-product-gallery-nav onyx-product-gallery-nav--next\" data-gallery-next aria-label=\"Next product photo\">›</button>");
                html.AppendFormat("<span class=\"onyx-product-gallery-count\">1/{0}</span>", resolvedUrls.Count);
            }

            html.Append("</div>");
            return html.ToString();
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
                case "monitor":
                case "monitors":
                    return "Monitor";
                case "chair":
                case "chairs":
                    return "Chair";
                case "mic":
                case "mics":
                case "microphone":
                case "microphones":
                    return "Mic";
                case "monitor extension":
                case "monitor-extension":
                case "monitor arm":
                case "monitor mount":
                    return "Monitor Extension";
                case "mousepad":
                case "mouse pad":
                case "mousepads":
                    return "Mousepad";
                case "cable":
                case "cables":
                    return "Cable";
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
                case "Monitor":
                    return "Monitors";
                case "Chair":
                    return "Gaming Chairs";
                case "Mic":
                    return "Microphones";
                case "Monitor Extension":
                    return "Monitor Arms";
                case "Mousepad":
                    return "Mousepads";
                case "Cable":
                    return "Cables";
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
                case "Monitor":
                    return "ONYX displays for complete gaming and work setups.";
                case "Chair":
                    return "Seating options available in the current ONYX catalog.";
                case "Mic":
                    return "Microphones for voice, team communication and content setups.";
                case "Monitor Extension":
                    return "Monitor arms and mounts for a more flexible desk layout.";
                case "Mousepad":
                    return "Mouse surfaces for consistent movement across your setup.";
                case "Cable":
                    return "Cables and connection essentials from the current catalog.";
                default:
                    return "Curated ONYX gaming gear across mice, keyboards, audio and desk essentials.";
            }
        }
    }
}
