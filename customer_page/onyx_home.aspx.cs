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

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                FeaturedProductsRepeater.DataSource = productService.GetFeaturedProducts(4);
                FeaturedProductsRepeater.DataBind();
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

        protected string GetFeaturedProductBrandLine(object category, int itemIndex)
        {
            return "ONYX / " + GetProductCategoryLabel(category, itemIndex);
        }

        protected string GetFeaturedProductName(object category, int itemIndex)
        {
            switch (GetProductVisualKey(category, itemIndex))
            {
                case "keyboard":
                    return "ONYX Forge V3";
                case "headset":
                    return "ONYX Pulse X";
                case "monitor":
                    return "ONYX Eclipse X27";
                default:
                    return "ONYX Vanta Pro";
            }
        }

        protected string GetFeaturedProductImageUrl(object category, int itemIndex)
        {
            return "/Content/home/products/onyx-" + GetProductVisualKey(category, itemIndex) + ".png?v=20260603-studio";
        }

        protected string GetFeaturedProductAlt(object category, int itemIndex)
        {
            return GetFeaturedProductName(category, itemIndex) + " product render";
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

        private void BindPersonalizedProducts()
        {
            try
            {
                if (!TryGetCurrentUserId(out long userId) || !personalizationService.HasCompletedProfile(userId))
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
            return GetFeaturedProductImageUrl(
                recommendation == null || recommendation.Product == null ? null : recommendation.Product.Category,
                itemIndex);
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

        private static string GetProductCategoryLabel(object category, int itemIndex)
        {
            switch (GetProductVisualKey(category, itemIndex))
            {
                case "keyboard":
                    return "Keyboard";
                case "headset":
                    return "Headset";
                case "monitor":
                    return "Monitor";
                default:
                    return "Mouse";
            }
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
