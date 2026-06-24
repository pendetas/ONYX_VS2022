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
        private const int MaximumPendingReconciliations = 3;
        private readonly OrderService orderService = new OrderService();
        private readonly Dictionary<long, string> continuePaymentUrls = new Dictionary<long, string>();
        private string currentFilter;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!TryGetCurrentUserId(out long userId))
            {
                Response.Redirect("~/auth_page/onyx_login.aspx?profile=true");
                return;
            }

            if (!IsPostBack)
            {
                currentFilter = NormalizeFilter(Request.QueryString["status"]);
                BindOrders(userId);
            }
        }

        private void BindOrders(long userId)
        {
            IList<Order> orders = orderService.GetOrdersForUser(
                userId,
                currentFilter == "all" ? null : currentFilter,
                40);
            ReconcileShownPendingOrders(userId, orders);
            if (currentFilter == OrderStatuses.PendingPayment)
            {
                orders = orders
                    .Where(order => string.Equals(
                        order.Status,
                        OrderStatuses.PendingPayment,
                        StringComparison.Ordinal))
                    .ToList();
            }

            string payment = (Request.QueryString["payment"] ?? string.Empty).Trim().ToLowerInvariant();
            if (payment == "cancelled")
            {
                litOrderMessage.Text = "<p class=\"onyx-order-notice\">Payment was cancelled and reserved stock was released.</p>";
            }
            else if (payment == "pending")
            {
                litOrderMessage.Text = "<p class=\"onyx-order-notice\">Payment is still being confirmed. This page will show the latest Stripe status.</p>";
            }

            pnlEmptyOrders.Visible = orders.Count == 0;
            rptRecentOrders.Visible = orders.Count > 0;
            rptRecentOrders.DataSource = orders;
            rptRecentOrders.DataBind();
        }

        private void ReconcileShownPendingOrders(long userId, IList<Order> orders)
        {
            if (currentFilter == OrderStatuses.Paid || currentFilter == OrderStatuses.Cancelled)
            {
                return;
            }

            int checkedCount = 0;
            bool cartChanged = false;
            foreach (Order order in orders.Where(item =>
                string.Equals(item.Status, OrderStatuses.PendingPayment, StringComparison.Ordinal) &&
                !string.IsNullOrWhiteSpace(item.StripeCheckoutSessionId)))
            {
                if (checkedCount++ >= MaximumPendingReconciliations)
                {
                    break;
                }

                try
                {
                    PaymentReconciliationResult result =
                        new PaymentCompletionService().ReconcileForUser(order.StripeCheckoutSessionId, userId);
                    order.Status = result.OrderStatus;
                    if (string.Equals(result.OrderStatus, OrderStatuses.PendingPayment, StringComparison.Ordinal) &&
                        !string.IsNullOrWhiteSpace(result.CheckoutUrl))
                    {
                        continuePaymentUrls[order.Id] = result.CheckoutUrl;
                    }
                    else if (result.IsPaid)
                    {
                        cartChanged = true;
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Trace.TraceError("Pending order reconciliation failed for order {0}: {1}", order.Id, ex);
                }
            }

            if (cartChanged)
            {
                new CartService().RefreshCurrentUserCartFromDatabase();
            }
        }

        protected string GetFilterClass(string filter)
        {
            string selected = string.IsNullOrWhiteSpace(currentFilter) ? NormalizeFilter(Request.QueryString["status"]) : currentFilter;
            return string.Equals(selected, filter, StringComparison.Ordinal) ? "is-active" : string.Empty;
        }

        protected string GetStatusClass(object status)
        {
            string value = Convert.ToString(status);
            if (value != OrderStatuses.PendingPayment &&
                value != OrderStatuses.Paid &&
                value != OrderStatuses.Cancelled)
            {
                value = "unknown";
            }

            return "onyx-order-status status-" + value;
        }

        protected string FormatStatus(object status)
        {
            string value = Convert.ToString(status);
            if (value == OrderStatuses.PendingPayment) return "Pending Payment";
            if (value == OrderStatuses.Paid) return "Paid";
            if (value == OrderStatuses.Cancelled) return "Cancelled";
            return "Unknown";
        }

        protected bool IsPaid(object status)
        {
            return string.Equals(Convert.ToString(status), OrderStatuses.Paid, StringComparison.Ordinal);
        }

        protected bool CanContinuePayment(object orderId)
        {
            return long.TryParse(Convert.ToString(orderId), out long id) && continuePaymentUrls.ContainsKey(id);
        }

        protected string GetContinuePaymentUrl(object orderId)
        {
            return long.TryParse(Convert.ToString(orderId), out long id) &&
                   continuePaymentUrls.TryGetValue(id, out string url)
                ? HttpUtility.HtmlAttributeEncode(url)
                : "#";
        }

        private static string NormalizeFilter(string filter)
        {
            string value = (filter ?? string.Empty).Trim().ToLowerInvariant();
            return value == OrderStatuses.PendingPayment ||
                   value == OrderStatuses.Paid ||
                   value == OrderStatuses.Cancelled
                ? value
                : "all";
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
