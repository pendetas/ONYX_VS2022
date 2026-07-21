using System;
using System.Diagnostics;
using System.Web;
using System.Web.UI;
using ONYX_DDAC.Helpers;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.customer_page
{
    public partial class onyx_payment_confirmation : Page
    {
        private const int MaximumPolls = 5;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!TryGetUserId(out long userId))
            {
                Response.Redirect("~/auth_page/onyx_login.aspx", true);
                return;
            }

            string sessionId = Request.QueryString["session_id"];
            if (string.IsNullOrWhiteSpace(sessionId))
            {
                Response.Redirect("~/customer_page/onyx_order_history.aspx?payment=invalid", true);
                return;
            }

            try
            {
                litTitle.Text = "Confirming your payment";
                litMessage.Text = "<p>Please wait while ONYX verifies your payment securely.</p>";
                int poll = GetPollCount();
                if (poll >= MaximumPolls)
                {
                    RedirectTo("~/customer_page/onyx_order_history.aspx?payment=pending");
                    return;
                }

                PaymentReconciliationResult result = new PaymentCompletionService().ReconcileForUser(sessionId, userId);
                if (result.IsPaid)
                {
                    // The order is confirmed paid and already committed to the database.
                    // Cart refresh and the receipt email are best-effort follow-ups: a
                    // failure there must not surface to the customer as a payment problem.
                    RunPostPaymentSideEffects(result.OrderId, userId);
                    RedirectTo("~/customer_page/onyx_invoice.aspx?orderId=" + result.OrderId);
                    return;
                }

                if (string.Equals(result.OrderStatus, OrderStatuses.Cancelled, StringComparison.OrdinalIgnoreCase))
                {
                    RedirectTo("~/customer_page/onyx_order_history.aspx?payment=cancelled");
                    return;
                }

                string next = ResolveUrl("~/customer_page/onyx_payment_confirmation.aspx?session_id=") +
                    HttpUtility.UrlEncode(sessionId) + "&poll=" + (poll + 1);
                if (result.OrderId > 0)
                {
                    Order order = new OrderService().GetOrderForUser(result.OrderId, userId);
                    litMessage.Text = BuildPendingMessage(order);
                }
                litRefresh.Text = "<meta http-equiv=\"refresh\" content=\"2;url=" +
                    HttpUtility.HtmlAttributeEncode(next) + "\" />";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Payment confirmation failed: {0}", ex);
                litTitle.Text = "Payment verification delayed";
                litMessage.Text = "<p>Your payment status could not be confirmed yet. Check order history shortly.</p>";
            }
        }

        private void RunPostPaymentSideEffects(long orderId, long userId)
        {
            try
            {
                new CartService().RefreshCurrentUserCartFromDatabase();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceWarning(
                    "Post-payment cart refresh failed for paid order {0}: {1}", orderId, ex);
            }

            try
            {
                new OrderService().SendCheckoutSuccessEmailOnce(
                    orderId,
                    userId,
                    BuildInvoiceUrl(orderId));
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceWarning(
                    "Checkout success email dispatch failed for paid order {0}: {1}", orderId, ex);
            }
        }

        private int GetPollCount()
        {
            return int.TryParse(Request.QueryString["poll"], out int poll) && poll > 0 ? poll : 0;
        }

        private void RedirectTo(string url)
        {
            Response.Redirect(url, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private string BuildInvoiceUrl(long orderId)
        {
            return AppUrlHelper.BuildAbsoluteUrl(this, "~/customer_page/onyx_invoice.aspx") +
                   "?orderId=" +
                   HttpUtility.UrlEncode(orderId.ToString());
        }

        private string BuildPendingMessage(Order order)
        {
            if (order == null)
            {
                return "<p>Please wait while ONYX verifies your payment securely.</p>";
            }

            bool hasVoucherDiscount = order.DiscountAmount > 0m;
            string voucherLabel = BuildVoucherLabel(order);
            string summary = "<div class=\"onyx-payment-summary\">" +
                "<div class=\"onyx-payment-summary-row\"><span>Items subtotal</span><strong>" +
                HttpUtility.HtmlEncode(CurrencyHelper.FormatMyr(order.SubtotalAmount)) +
                "</strong></div>";

            if (hasVoucherDiscount)
            {
                summary += "<div class=\"onyx-payment-summary-row\"><span>" +
                    voucherLabel +
                    "</span><strong>-" +
                    HttpUtility.HtmlEncode(CurrencyHelper.FormatMyr(order.DiscountAmount)) +
                    "</strong></div>";
            }

            summary += "<div class=\"onyx-payment-summary-row\"><span>Shipping</span><strong>RM 0.00</strong></div>" +
                "<div class=\"onyx-payment-summary-row onyx-payment-summary-row--total\"><span>Total charged</span><strong>" +
                HttpUtility.HtmlEncode(CurrencyHelper.FormatMyr(order.TotalAmount)) +
                "</strong></div></div>";

            return "<p>ONYX is still confirming your Stripe payment. These stored order totals will stay consistent once your receipt is ready.</p>" + summary;
        }

        private string BuildVoucherLabel(Order order)
        {
            string code = string.IsNullOrWhiteSpace(order.VoucherCode) ? string.Empty : order.VoucherCode.Trim();
            string name = string.IsNullOrWhiteSpace(order.VoucherName) ? string.Empty : order.VoucherName.Trim();

            if (!string.IsNullOrEmpty(code) && !string.IsNullOrEmpty(name) &&
                !string.Equals(code, name, StringComparison.OrdinalIgnoreCase))
            {
                return HttpUtility.HtmlEncode("Voucher (" + code + " · " + name + ")");
            }

            if (!string.IsNullOrEmpty(code))
            {
                return HttpUtility.HtmlEncode("Voucher (" + code + ")");
            }

            if (!string.IsNullOrEmpty(name))
            {
                return HttpUtility.HtmlEncode("Voucher (" + name + ")");
            }

            return "Voucher";
        }

        private static bool TryGetUserId(out long userId)
        {
            return long.TryParse(Convert.ToString(HttpContext.Current.Session["UserId"]), out userId) && userId > 0;
        }
    }
}
