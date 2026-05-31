using System;
using System.Web.UI;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.admin_page
{
    public partial class onyx_admin_products : Page
    {
        private readonly ProductService productService = new ProductService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ProductsGridView.DataSource = productService.GetFeaturedProducts(4);
                ProductsGridView.DataBind();
            }
        }
    }
}
