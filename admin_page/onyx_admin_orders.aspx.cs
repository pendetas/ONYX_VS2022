using System;
using System.Collections.Generic;
using System.Web.UI;
using ONYX_DDAC.DAL;

namespace ONYX_DDAC.admin_page
{
    public partial class onyx_admin_orders : System.Web.UI.Page
    {
        private readonly OrderRepository _repo = new OrderRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                BindOrders();
        }

        private void BindOrders()
        {
            litLastUpdated.Text = DateTime.Now.ToString("d MMM yyyy, h:mm tt");

            List<OrderRepository.OrderSummary> orders = _repo.GetAllOrders();
            OrderRepository.OrderStats stats = _repo.GetStats();

            OrdersRepeater.DataSource = orders;
            OrdersRepeater.DataBind();

            litOrderCount.Text   = orders.Count.ToString();
            litTotalRevenue.Text = "RM " + stats.Revenue.ToString("N2");

            litStatTotal.Text     = stats.Total.ToString();
            litStatPending.Text   = stats.Pending.ToString();
            litStatShipped.Text   = stats.Shipped.ToString();
            litStatDelivered.Text = stats.Delivered.ToString();
        }
    }
}
