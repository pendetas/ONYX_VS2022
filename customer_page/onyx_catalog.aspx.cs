using System;
using System.Collections.Generic;
using System.Web.UI;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.customer_page
{
    public partial class onyx_catalog : Page
    {
        private readonly ProductService productService = new ProductService();

        protected string SelectedCategory { get; private set; }
        protected string CatalogTitle { get; private set; }
        protected string CatalogDescription { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            SelectedCategory = NormalizeCategory(Request.QueryString["category"]);
            BindCatalog();
        }

        private void BindCatalog()
        {
            IList<Product> products = productService.GetCatalogProducts(SelectedCategory);

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
