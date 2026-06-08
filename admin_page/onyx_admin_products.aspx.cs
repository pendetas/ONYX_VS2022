using System;
using System.Collections.Generic;
using System.Web.UI;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.admin_page
{
    public partial class onyx_admin_products : Page
    {
        private readonly ProductRepository _repo = new ProductRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                BindPage();
        }

        private void BindPage()
        {
            List<Product> products   = _repo.GetAllProducts();
            List<string>  categories = _repo.GetDistinctCategories();

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
