using System;
using System.Web.UI;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.customer_page
{
    public partial class onyx_products : Page
    {
        private readonly ProductService productService = new ProductService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ProductsRepeater.DataSource = productService.GetFeaturedProducts(4);
                ProductsRepeater.DataBind();
            }
        }
    }
}
