using System;
using System.Collections.Generic;
using System.Web.UI;
using System.Web.UI.WebControls;
using ONYX_DDAC.Helpers;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.admin_page
{
    public partial class onyx_admin_order_details : Page
    {
        private const string PendingPaymentGuardMessage = "This order has an active Stripe payment. Cancel it through the payment cancellation flow.";
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

            string statusKey = string.IsNullOrEmpty(order.Status) ? "" : order.Status.ToLower();
            string statusCap = string.IsNullOrEmpty(order.Status) ? "Unknown" : char.ToUpper(order.Status[0]) + order.Status.Substring(1);

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

            SelectStatusValueSafely(statusKey, statusCap);
            ConfigurePendingPaymentControls(order);

            litMetaOrderId.Text = "#ORD-" + order.Id;
            litMetaDate.Text    = order.OrderedAt.ToString("d MMM yyyy, h:mm tt");
            litReceiptKey.Text  = string.IsNullOrEmpty(order.ReceiptS3Key) ? "—" : Server.HtmlEncode(order.ReceiptS3Key);

            var items = _svc.GetOrderItems(id);
            OrderItemsRepeater.DataSource = items;
            OrderItemsRepeater.DataBind();

            litSubtotal.Text = CurrencyHelper.FormatMyr(order.SubtotalAmount);
            litTotal.Text    = CurrencyHelper.FormatMyr(order.TotalAmount);

            bool hasVoucherDiscount = order.DiscountAmount > 0m;
            pnlVoucherSummary.Visible = hasVoucherDiscount;
            litVoucherLabel.Text = hasVoucherDiscount ? BuildVoucherLabel(order.VoucherCode, order.VoucherName) : string.Empty;
            litDiscount.Text = hasVoucherDiscount ? CurrencyHelper.FormatMyr(order.DiscountAmount) : string.Empty;

            TimelineRepeater.DataSource = BuildTimeline(statusKey, order.OrderedAt, order.StatusUpdatedAt);
            TimelineRepeater.DataBind();
        }

        private string BuildVoucherLabel(string voucherCode, string voucherName)
        {
            string code = string.IsNullOrWhiteSpace(voucherCode) ? string.Empty : voucherCode.Trim();
            string name = string.IsNullOrWhiteSpace(voucherName) ? string.Empty : voucherName.Trim();

            if (!string.IsNullOrEmpty(code) && !string.IsNullOrEmpty(name) &&
                !string.Equals(code, name, StringComparison.OrdinalIgnoreCase))
            {
                return "Voucher (" + Server.HtmlEncode(code) + " · " + Server.HtmlEncode(name) + ")";
            }

            if (!string.IsNullOrEmpty(code))
            {
                return "Voucher (" + Server.HtmlEncode(code) + ")";
            }

            if (!string.IsNullOrEmpty(name))
            {
                return "Voucher (" + Server.HtmlEncode(name) + ")";
            }

            return "Voucher";
        }

        protected void btnUpdateStatus_Click(object sender, EventArgs e)
        {
            long id = CurrentOrderId;
            if (id <= 0) return;

            OrderDetail order = _svc.GetOrderById(id);
            if (IsPendingPaymentOrder(order))
            {
                pnlStatusMsg.Visible = true;
                litStatusMsg.Text = PendingPaymentGuardMessage;
                ConfigurePendingPaymentControls(order);
                return;
            }

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

            OrderDetail order = _svc.GetOrderById(id);
            if (IsPendingPaymentOrder(order))
            {
                pnlStatusMsg.Visible = true;
                litStatusMsg.Text = PendingPaymentGuardMessage;
                ConfigurePendingPaymentControls(order);
                return;
            }

            try
            {
                _svc.DeleteOrder(id);
                Response.Redirect("~/admin_page/onyx_admin_orders.aspx");
            }
            catch (InvalidOperationException ex)
            {
                pnlStatusMsg.Visible = true;
                litStatusMsg.Text    = ex.Message;
            }
            catch (Exception)
            {
                pnlStatusMsg.Visible = true;
                litStatusMsg.Text    = "Failed to delete order. Please try again.";
            }
        }

        private void SelectStatusValueSafely(string statusKey, string statusCap)
        {
            ddlStatus.ClearSelection();
            var statusItem = ddlStatus.Items.FindByValue(statusKey);
            if (statusItem == null && !string.IsNullOrWhiteSpace(statusKey))
            {
                ddlStatus.Items.Insert(0, new ListItem(statusCap, statusKey));
                statusItem = ddlStatus.Items.FindByValue(statusKey);
            }

            if (statusItem != null)
            {
                statusItem.Selected = true;
            }
        }

        private void ConfigurePendingPaymentControls(OrderDetail order)
        {
            bool isPendingPayment = IsPendingPaymentOrder(order);
            ddlStatus.Enabled = !isPendingPayment;
            btnUpdateStatus.Enabled = !isPendingPayment;
            btnDeleteOrder.Enabled = !isPendingPayment;

            if (isPendingPayment)
            {
                ddlStatus.Enabled = false;
                btnUpdateStatus.Enabled = false;
                btnDeleteOrder.Enabled = false;
                pnlStatusMsg.Visible = true;
                litStatusMsg.Text = PendingPaymentGuardMessage;
            }
        }

        private static bool IsPendingPaymentOrder(OrderDetail order)
        {
            return order != null &&
                string.Equals(order.Status, OrderStatuses.PendingPayment, StringComparison.OrdinalIgnoreCase);
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

            if (status == OrderStatuses.PendingPayment)
            {
                t.Add(new { Event = "Awaiting Payment", Timestamp = "Pending", DotClass = "dot-pending" });
                return t;
            }

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
