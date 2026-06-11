using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.customer_page
{
    public partial class onyx_order_history : Page
    {
        private readonly OrderService orderService = new OrderService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!TryGetCurrentUserId(out long userId))
            {
                Response.Redirect("~/auth_page/onyx_login.aspx?profile=true");
                return;
            }

            if (!IsPostBack)
            {
                BindOrders(userId);
            }
        }

        private void BindOrders(long userId)
        {
            IList<Order> orders = orderService.GetOrdersForUser(userId, 20);

            pnlEmptyOrders.Visible = orders.Count == 0;
            rptRecentOrders.Visible = orders.Count > 0;
            rptRecentOrders.DataSource = orders;
            rptRecentOrders.DataBind();
        }

        protected string FormatOrderDate(object value)
        {
            if (value is DateTime date)
            {
                return Server.HtmlEncode(date.ToString("dd MMM yyyy"));
            }

            return "Recent order";
        }

        protected string GetOrderSummary(object dataItem)
        {
            Order order = dataItem as Order;
            if (order == null || order.Items == null || order.Items.Count == 0)
            {
                return "Order details are being prepared.";
            }

            string[] names = order.Items
                .Take(3)
                .Select(item => string.Format("{0} x {1}", item.Quantity, item.ProductName))
                .ToArray();

            string summary = string.Join(", ", names);
            if (order.Items.Count > 3)
            {
                summary += string.Format(" and {0} more", order.Items.Count - 3);
            }

            return Server.HtmlEncode(summary);
        }

        private static bool TryGetCurrentUserId(out long userId)
        {
            userId = 0;
            object value = HttpContext.Current.Session["UserId"];

            if (value == null)
            {
                return false;
            }

            if (value is long longValue)
            {
                userId = longValue;
                return true;
            }

            return long.TryParse(value.ToString(), out userId);
        }
    }
}
