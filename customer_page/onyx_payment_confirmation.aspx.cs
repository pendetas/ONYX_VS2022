using System;
using System.Diagnostics;
using System.Web;
using System.Web.UI;
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
                int poll = GetPollCount();
                if (poll >= MaximumPolls)
                {
                    RedirectTo("~/customer_page/onyx_order_history.aspx?payment=pending");
                    return;
                }

                PaymentReconciliationResult result = new PaymentCompletionService().ReconcileForUser(sessionId, userId);
                if (result.IsPaid)
                {
                    new CartService().RefreshCurrentUserCartFromDatabase();
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
                litRefresh.Text = "<meta http-equiv=\"refresh\" content=\"2;url=" +
                    HttpUtility.HtmlAttributeEncode(next) + "\" />";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Payment confirmation failed: {0}", ex);
                litTitle.Text = "Payment verification delayed";
                litMessage.Text = "Your payment status could not be confirmed yet. Check order history shortly.";
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

        private static bool TryGetUserId(out long userId)
        {
            return long.TryParse(Convert.ToString(HttpContext.Current.Session["UserId"]), out userId) && userId > 0;
        }
    }
}
