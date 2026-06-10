using System;
using System.Collections.Generic;
using System.Web.UI;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.admin_page
{
    public partial class onyx_admin_order_details : Page
    {
        private readonly OrderService _svc = new OrderService();

        private long CurrentOrderId
        {
            get { return ViewState["OrderId"] != null ? (long)ViewState["OrderId"] : 0; }
            set { ViewState["OrderId"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                long id;
                if (!long.TryParse(Request.QueryString["id"], out id) || id <= 0)
                { ShowNotFound(); return; }

                CurrentOrderId = id;
                BindOrder(id);

                if (Request.QueryString["updated"] == "1")
                {
                    pnlStatusMsg.Visible = true;
                    litStatusMsg.Text    = "Status updated successfully.";
                }
            }
        }

        private void BindOrder(long id)
        {
            var order = _svc.GetOrderById(id);
            if (order == null) { ShowNotFound(); return; }

            pnlOrderDetail.Visible = true;
            pnlNotFound.Visible    = false;

            string statusKey = order.Status.ToLower();
            string statusCap = char.ToUpper(order.Status[0]) + order.Status.Substring(1);

            litOrderId.Text            = "#ORD-" + order.Id;
            litOrderDate.Text          = order.OrderedAt.ToString("d MMM yyyy, h:mm tt");
            litCustomerNameHeader.Text = Server.HtmlEncode(order.CustomerName);
            lblStatusBadge.Text        = BuildBadge(statusKey, statusCap);

            litCustName.Text  = Server.HtmlEncode(order.CustomerName);
            litCustEmail.Text = Server.HtmlEncode(order.CustomerEmail);
            litCustPhone.Text = Server.HtmlEncode(order.CustomerPhone);
            litCustSince.Text = order.CustomerSince == DateTime.MinValue
                                ? "—"
                                : order.CustomerSince.ToString("d MMM yyyy");

            if (string.IsNullOrWhiteSpace(order.ShippingAddress))
                litShippingAddress.Text = "<span style=\"color:rgba(255,255,255,0.28);font-style:italic;\">No address recorded.</span>";
            else
                litShippingAddress.Text = Server.HtmlEncode(order.ShippingAddress).Replace("\n", "<br/>");

            ddlStatus.SelectedValue = statusKey;

            litMetaOrderId.Text = "#ORD-" + order.Id;
            litMetaDate.Text    = order.OrderedAt.ToString("d MMM yyyy, h:mm tt");
            litReceiptKey.Text  = string.IsNullOrEmpty(order.ReceiptS3Key) ? "—" : Server.HtmlEncode(order.ReceiptS3Key);

            var items = _svc.GetOrderItems(id);
            OrderItemsRepeater.DataSource = items;
            OrderItemsRepeater.DataBind();

            decimal subtotal = 0;
            foreach (var item in items)
                subtotal += item.UnitPrice * item.Quantity;

            litSubtotal.Text = "RM " + subtotal.ToString("N2");
            litTotal.Text    = "RM " + order.TotalAmount.ToString("N2");

            TimelineRepeater.DataSource = BuildTimeline(statusKey, order.OrderedAt, order.StatusUpdatedAt);
            TimelineRepeater.DataBind();
        }

        protected void btnUpdateStatus_Click(object sender, EventArgs e)
        {
            long id = CurrentOrderId;
            if (id <= 0) return;

            string err = _svc.UpdateStatus(id, ddlStatus.SelectedValue);
            if (err != null)
            {
                pnlStatusMsg.Visible = true;
                litStatusMsg.Text    = err;
                return;
            }

            Response.Redirect("onyx_admin_order_details.aspx?id=" + id + "&updated=1");
        }

        protected void btnDeleteOrder_Click(object sender, EventArgs e)
        {
            long id = CurrentOrderId;
            if (id <= 0) return;

            _svc.DeleteOrder(id);
            Response.Redirect("~/admin_page/onyx_admin_orders.aspx");
        }

        private void ShowNotFound()
        {
            pnlOrderDetail.Visible = false;
            pnlNotFound.Visible    = true;
        }

        private static string BuildBadge(string key, string display)
        {
            return "<span class=\"status-badge status-" + key + "\">" + display + "</span>";
        }

        private static List<object> BuildTimeline(string status, DateTime orderedAt, DateTime? statusUpdatedAt)
        {
            string ts      = orderedAt.ToString("d MMM yyyy, h:mm tt");
            string updated = statusUpdatedAt.HasValue
                             ? statusUpdatedAt.Value.ToString("d MMM yyyy, h:mm tt")
                             : "—";
            var t = new List<object>();

            t.Add(new { Event = "Order Placed",       Timestamp = ts,      DotClass = "dot-done" });

            if (status != "cancelled")
                t.Add(new { Event = "Payment Confirmed", Timestamp = ts,      DotClass = "dot-done" });

            if (status == "shipped" || status == "delivered")
                t.Add(new { Event = "Shipped",           Timestamp = updated, DotClass = "dot-done" });

            if (status == "delivered")
                t.Add(new { Event = "Delivered",         Timestamp = updated, DotClass = "dot-done" });

            if (status == "pending")
                t.Add(new { Event = "Awaiting Shipment", Timestamp = "Pending", DotClass = "dot-pending" });

            if (status == "cancelled")
                t.Add(new { Event = "Order Cancelled",   Timestamp = updated, DotClass = "dot-cancel" });

            return t;
        }
    }
}
