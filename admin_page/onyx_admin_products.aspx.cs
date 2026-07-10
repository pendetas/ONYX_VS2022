using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.admin_page
{
    public partial class onyx_admin_products : Page
    {
        private readonly ProductService _svc = new ProductService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                BindPage();
        }

        private void BindPage()
        {
            var products   = _svc.GetAllProducts();
            var categories = _svc.GetDistinctCategories();

            lblCount.Text = products.Count + " product" + (products.Count == 1 ? "" : "s");

            ProductsRepeater.DataSource = products;
            ProductsRepeater.DataBind();

            CategoryRepeater.DataSource = categories;
            CategoryRepeater.DataBind();
        }

        protected string GetStockBadge(int qty)
        {
            if (qty == 0)
                return "<span class=\"stock-badge stock-out\">Out of stock</span>";
            if (qty < 5)
                return "<span class=\"stock-badge stock-low\">" + qty + " left</span>";
            return "<span class=\"stock-badge stock-ok\">" + qty + " in stock</span>";
        }

        protected string GetProductGalleryHtml(object dataItem)
        {
            var product = dataItem as Product;
            if (product == null) return string.Empty;

            List<string> imageUrls = (product.ImageUrls ?? new List<string>())
                .Where(value => !string.IsNullOrWhiteSpace(value))
                .ToList();

            if (imageUrls.Count == 0 && !string.IsNullOrWhiteSpace(product.ImageUrl))
            {
                imageUrls.Add(product.ImageUrl);
            }

            if (imageUrls.Count == 0) return string.Empty;

            var html = new StringBuilder();
            html.AppendFormat("<div class=\"admin-product-gallery\" data-product-gallery data-gallery-index=\"0\" aria-label=\"{0} photos\">",
                HttpUtility.HtmlAttributeEncode(product.Name));

            for (int i = 0; i < imageUrls.Count; i++)
            {
                string activeClass = i == 0 ? " is-active" : string.Empty;
                html.AppendFormat(
                    "<img class=\"admin-product-gallery-slide{0}\" data-gallery-slide src=\"{1}\" alt=\"{2}\" onerror=\"this.style.display='none'\" />",
                    activeClass,
                    HttpUtility.HtmlAttributeEncode(imageUrls[i]),
                    HttpUtility.HtmlAttributeEncode(product.Name));
            }

            if (imageUrls.Count > 1)
            {
                html.Append("<button type=\"button\" class=\"admin-product-gallery-nav admin-product-gallery-nav--prev\" data-gallery-prev aria-label=\"Previous product photo\">‹</button>");
                html.Append("<button type=\"button\" class=\"admin-product-gallery-nav admin-product-gallery-nav--next\" data-gallery-next aria-label=\"Next product photo\">›</button>");
                html.AppendFormat("<span class=\"admin-product-gallery-count\">1/{0}</span>", imageUrls.Count);
            }

            html.Append("</div>");
            return html.ToString();
        }
    }
}
