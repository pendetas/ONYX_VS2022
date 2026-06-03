using System;
using System.Web.UI;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.user_page
{
    public partial class Home : Page
    {
        private readonly ProductService productService = new ProductService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                FeaturedProductsRepeater.DataSource = productService.GetFeaturedProducts(4);
                FeaturedProductsRepeater.DataBind();
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
