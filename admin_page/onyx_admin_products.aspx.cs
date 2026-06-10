using System;
using System.Web.UI;
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
    }
}
