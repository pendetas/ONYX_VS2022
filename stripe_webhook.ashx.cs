using System;
using System.Diagnostics;
using System.IO;
using System.Web;
using ONYX_DDAC.Services;
using Stripe;
using Stripe.Checkout;

namespace ONYX_DDAC
{
    public class StripeWebhook : IHttpHandler
    {
        public bool IsReusable
        {
            get { return false; }
        }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "application/json";

            Event stripeEvent;
            try
            {
                string requestBody;
                using (var reader = new StreamReader(context.Request.InputStream))
                {
                    requestBody = reader.ReadToEnd();
                }

                var stripePaymentService = new StripePaymentService();
                stripeEvent = EventUtility.ConstructEvent(
                    requestBody,
                    context.Request.Headers["Stripe-Signature"],
                    stripePaymentService.GetWebhookSecret(),
                    300,
                    false);
            }
            catch (StripeException ex)
            {
                Trace.TraceWarning("Stripe webhook signature verification failed: {0}", ex.Message);
                WriteResponse(context, 400, "{\"error\":\"invalid_signature\"}");
                return;
            }
            catch (Exception ex)
            {
                Trace.TraceError("Stripe webhook initialization failed: {0}", ex);
                WriteResponse(context, 500, "{\"error\":\"webhook_unavailable\"}");
                return;
            }

            if (!IsSupportedEvent(stripeEvent.Type))
            {
                WriteResponse(context, 200, "{\"received\":true,\"status\":\"ignored\"}");
                return;
            }

            try
            {
                Session session = stripeEvent.Data.Object as Session;
                if (session == null || string.IsNullOrWhiteSpace(session.Id))
                {
                    throw new InvalidOperationException("The Stripe event did not contain a Checkout Session.");
                }

                var completionService = new PaymentCompletionService();
                completionService.Reconcile(session.Id, stripeEvent.Id, stripeEvent.Type);
                WriteResponse(context, 200, "{\"received\":true}");
            }
            catch (Exception ex)
            {
                Trace.TraceError(
                    "Stripe webhook processing failed for event {0} ({1}): {2}",
                    stripeEvent.Id,
                    stripeEvent.Type,
                    ex);
                WriteResponse(context, 500, "{\"error\":\"processing_failed\"}");
            }
        }

        private static bool IsSupportedEvent(string eventType)
        {
            return string.Equals(eventType, EventTypes.CheckoutSessionCompleted, StringComparison.Ordinal) ||
                   string.Equals(eventType, EventTypes.CheckoutSessionAsyncPaymentSucceeded, StringComparison.Ordinal) ||
                   string.Equals(eventType, EventTypes.CheckoutSessionAsyncPaymentFailed, StringComparison.Ordinal) ||
                   string.Equals(eventType, EventTypes.CheckoutSessionExpired, StringComparison.Ordinal);
        }

        private static void WriteResponse(HttpContext context, int statusCode, string body)
        {
            context.Response.StatusCode = statusCode;
            context.Response.TrySkipIisCustomErrors = true;
            context.Response.Write(body);
        }
    }
}
