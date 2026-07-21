using System;
using System.Web.UI;
using ONYX_DDAC.Helpers;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.customer_page
{
    public partial class Home : Page
    {
        private readonly ProductService productService = new ProductService();
        private readonly PersonalizationService personalizationService = new PersonalizationService();

        protected string PersonalizedSetupHeadline { get; private set; } = "Recommended products";
        protected string PersonalizedSetupSubheadline { get; private set; } = "A tighter edit of the catalog, ranked from your saved ONYX setup.";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindFeaturedProducts();
                BindPersonalizedProducts();
            }
        }

        protected bool IsLoggedIn
        {
            get { return Session["UserId"] != null; }
        }

        protected string CurrentUsername
        {
            get { return (Session["Username"] ?? "").ToString(); }
        }

        protected string GetFeaturedProductImageUrl(object dataItem, int itemIndex)
        {
            Product product = dataItem as Product;
            string value = product == null ? string.Empty : product.ImageUrl;
            Uri uri;

            // ponytail: the repository hydrates ImageUrl from the primary product_images row.
            if (!string.IsNullOrWhiteSpace(value) &&
                Uri.TryCreate(value, UriKind.Absolute, out uri) &&
                (uri.Scheme == Uri.UriSchemeHttp || uri.Scheme == Uri.UriSchemeHttps))
            {
                return value;
            }

            return GetFallbackProductImageUrl(product == null ? null : product.Category, itemIndex);
        }

        private static string GetFallbackProductImageUrl(object category, int itemIndex)
        {
            return MediaUrlHelper.Resolve("site-photos/image-unavailable.svg");
        }

        protected string GetFeaturedProductAlt(object dataItem)
        {
            Product product = dataItem as Product;
            return product == null || string.IsNullOrWhiteSpace(product.Name)
                ? "Featured product image"
                : product.Name + " product image";
        }

        protected string GetFeaturedProductCue(object category, int itemIndex)
        {
            switch (GetProductVisualKey(category, itemIndex))
            {
                case "keyboard":
                    return "Fast actuation for sharper inputs and cleaner desk rhythm.";
                case "headset":
                    return "Closed-in focus for clearer calls, footsteps, and late-round cues.";
                case "monitor":
                    return "High-refresh clarity for tracking motion without visual drag.";
                default:
                    return "Stable tracking, confident grip, and crisp click control.";
            }
        }

        private void BindFeaturedProducts()
        {
            try
            {
                FeaturedProductsRepeater.DataSource = productService.GetFeaturedProducts(4);
            }
            catch (Exception exception)
            {
                System.Diagnostics.Trace.TraceWarning(
                    "Featured home products unavailable: {0}",
                    exception);
                FeaturedProductsRepeater.DataSource = Array.Empty<Product>();
            }

            FeaturedProductsRepeater.DataBind();
        }

        private void BindPersonalizedProducts()
        {
            try
            {
                if (!TryGetCurrentUserId(out long userId) || !personalizationService.HasCompletedProfile(userId))
                {
                    PersonalizedProductsPanel.Visible = false;
                    return;
                }

                UserPersonalizationProfile profile = personalizationService.GetProfile(userId);
                if (profile == null || !profile.CompletedAt.HasValue)
                {
                    PersonalizedProductsPanel.Visible = false;
                    return;
                }

                var recommendations = personalizationService.GetRecommendedProducts(userId, 4);
                PersonalizedProductsPanel.Visible = recommendations.Count > 0;
                PersonalizedProductsRepeater.DataSource = recommendations;
                PersonalizedProductsRepeater.DataBind();
            }
            catch (Exception exception)
            {
                System.Diagnostics.Trace.TraceWarning(
                    "Personalized home strip unavailable for user '{0}': {1}",
                    Session["UserId"] ?? "(null)",
                    exception);
                PersonalizedProductsPanel.Visible = false;
            }
        }

        protected string GetPersonalizedProductReason(object dataItem)
        {
            PersonalizedProduct recommendation = dataItem as PersonalizedProduct;
            return recommendation == null ? string.Empty : recommendation.Reason ?? string.Empty;
        }

        protected string GetPersonalizedProductName(object dataItem)
        {
            PersonalizedProduct recommendation = dataItem as PersonalizedProduct;
            return recommendation == null || recommendation.Product == null
                ? string.Empty
                : recommendation.Product.Name ?? string.Empty;
        }

        protected string GetPersonalizedProductPrice(object dataItem)
        {
            PersonalizedProduct recommendation = dataItem as PersonalizedProduct;
            return recommendation == null || recommendation.Product == null
                ? string.Empty
                : CurrencyHelper.FormatMyr(recommendation.Product.Price);
        }

        protected string GetPersonalizedProductUrl(object dataItem)
        {
            PersonalizedProduct recommendation = dataItem as PersonalizedProduct;
            return recommendation == null || recommendation.Product == null
                ? "onyx_product_details.aspx"
                : "onyx_product_details.aspx?id=" + recommendation.Product.Id;
        }

        protected string GetPersonalizedProductImageUrl(object dataItem, int itemIndex)
        {
            PersonalizedProduct recommendation = dataItem as PersonalizedProduct;
            return GetFeaturedProductImageUrl(recommendation == null || recommendation.Product == null ? null : recommendation.Product, itemIndex);
        }

        protected string GetPersonalizedProductAlt(object dataItem)
        {
            string name = GetPersonalizedProductName(dataItem);
            return string.IsNullOrWhiteSpace(name) ? "Recommended product render" : name + " product render";
        }

        private bool TryGetCurrentUserId(out long userId)
        {
            userId = 0;
            object value = Session["UserId"];
            return value != null && long.TryParse(value.ToString(), out userId);
        }

        private static string GetProductVisualKey(object category, int itemIndex)
        {
            var categoryText = (category ?? string.Empty).ToString();

            if (categoryText.IndexOf("keyboard", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                return "keyboard";
            }

            if (categoryText.IndexOf("headset", StringComparison.OrdinalIgnoreCase) >= 0 ||
                categoryText.IndexOf("audio", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                return "headset";
            }

            if (categoryText.IndexOf("monitor", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                return "monitor";
            }

            if (categoryText.IndexOf("mouse", StringComparison.OrdinalIgnoreCase) >= 0)
            {
                return "mouse";
            }

            switch (itemIndex % 4)
            {
                case 1:
                    return "keyboard";
                case 2:
                    return "headset";
                case 3:
                    return "monitor";
                default:
                    return "mouse";
            }
        }
    }
}
