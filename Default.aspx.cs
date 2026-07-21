using System;
using System.Web.UI;

namespace ONYX_DDAC
{
    public partial class Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Redirect("~/customer_page/onyx_home.aspx", true);
        }
    }
}
