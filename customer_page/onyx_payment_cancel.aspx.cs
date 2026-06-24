using System;
using System.Diagnostics;
using System.Web;
using System.Web.UI;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.customer_page
{
    public partial class onyx_payment_cancel : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!TryGetUserId(out long userId))
            {
                Response.Redirect("~/auth_page/onyx_login.aspx", true);
                return;
            }

            if (!long.TryParse(Request.QueryString["orderId"], out long orderId) || orderId <= 0)
            {
                Response.Redirect("~/customer_page/onyx_order_history.aspx?payment=invalid", true);
                return;
            }

            string paymentCancellationToken = Request.QueryString["token"];
            try
            {
                Order order = new CheckoutService().GetPendingOrderForCancellation(
                    orderId,
                    userId,
                    paymentCancellationToken);
                if (order == null)
                {
                    RedirectTo("~/customer_page/onyx_order_history.aspx?payment=invalid");
                    return;
                }

                var stripe = new StripePaymentService();
                if (!stripe.TryExpireCheckoutSessionConfirmed(order.StripeCheckoutSessionId))
                {
                    litMessage.Text = "The Stripe session could not be closed yet. Your reservation remains protected; try again shortly.";
                    return;
                }

                PaymentReconciliationResult result =
                    new PaymentCompletionService().ReconcileForUser(order.StripeCheckoutSessionId, userId);
                if (string.Equals(result.OrderStatus, OrderStatuses.Cancelled, StringComparison.OrdinalIgnoreCase))
                {
                    RedirectTo("~/customer_page/onyx_checkout.aspx?payment=cancelled");
                    return;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Payment cancellation failed for order {0}: {1}", orderId, ex);
                litMessage.Text = "The payment session could not be cancelled safely yet. Please check order history.";
            }
        }

        private static bool TryGetUserId(out long userId)
        {
            return long.TryParse(Convert.ToString(HttpContext.Current.Session["UserId"]), out userId) && userId > 0;
        }

        private void RedirectTo(string url)
        {
            Response.Redirect(url, false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}
