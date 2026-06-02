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
                // Note: productService.GetFeaturedProducts(4) requires actual DB connection to not crash.
                // Wrapped in try/catch to ensure UI renders even without DB.
                try
                {
                    ProductsGridView.DataSource = productService.GetFeaturedProducts(4);
                    ProductsGridView.DataBind();
                }
                catch
                {
                    // Ignore DB errors so the template UI can still be viewed
                }
            }
        }
    }
}