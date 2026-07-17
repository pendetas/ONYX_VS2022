using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using ONYX_DDAC.Models;
using Stripe;
using Stripe.Checkout;

namespace ONYX_DDAC.Services
{
    public class StripePaymentService
    {
        private const string SecretKeyEnvironmentVariable = "STRIPE_SECRET_KEY";
        private const string WebhookSecretEnvironmentVariable = "STRIPE_WEBHOOK_SECRET";

        public StripePaymentService()
        {
            string secretKey = Environment.GetEnvironmentVariable(SecretKeyEnvironmentVariable);
            if (string.IsNullOrWhiteSpace(secretKey) ||
                !secretKey.StartsWith("sk_test_", StringComparison.Ordinal))
            {
                throw new InvalidOperationException("Stripe test-mode secret key is not configured.");
            }

            StripeConfiguration.ApiKey = secretKey;
        }

        public string GetWebhookSecret()
        {
            string webhookSecret = Environment.GetEnvironmentVariable(WebhookSecretEnvironmentVariable);
            if (string.IsNullOrWhiteSpace(webhookSecret) ||
                !webhookSecret.StartsWith("whsec_", StringComparison.Ordinal))
            {
                throw new InvalidOperationException("Stripe webhook secret is not configured.");
            }

            return webhookSecret;
        }

        public StripeCheckoutResult CreateCheckoutSession(
            Order order,
            Uri applicationBaseUri,
            string paymentCancellationToken)
        {
            ValidatePendingOrder(order);
            if (string.IsNullOrWhiteSpace(paymentCancellationToken))
            {
                throw new InvalidOperationException("The payment cancellation token is missing.");
            }

            string baseUrl = applicationBaseUri.AbsoluteUri.TrimEnd('/');
            var options = new SessionCreateOptions
            {
                Mode = "payment",
                ClientReferenceId = order.Id.ToString(),
                ExpiresAt = order.PaymentExpiresAt.Value.UtcDateTime,
                SuccessUrl = baseUrl + "/customer_page/onyx_payment_confirmation.aspx?session_id={CHECKOUT_SESSION_ID}",
                CancelUrl = baseUrl + "/customer_page/onyx_payment_cancel.aspx?orderId=" + order.Id +
                    "&token=" + Uri.EscapeDataString(paymentCancellationToken),
                Metadata = new Dictionary<string, string>
                {
                    { "onyx_order_id", order.Id.ToString() },
                    { "onyx_user_id", order.UserId.ToString() },
                    { "onyx_checkout_attempt", order.CheckoutAttemptToken }
                },
                LineItems = order.Items.Select(CreateLineItem).ToList()
            };
            SessionDiscountOptions orderDiscount = CreateOrderDiscount(order);
            if (orderDiscount != null)
            {
                options.Discounts = new List<SessionDiscountOptions> { orderDiscount };
            }

            var requestOptions = new RequestOptions
            {
                IdempotencyKey = BuildIdempotencyKey(order)
            };
            var service = new SessionService();

            try
            {
                return ToCheckoutResult(order.Id, service.Create(options, requestOptions));
            }
            catch (StripeException firstException)
            {
                if (IsDefinitiveCreateFailure(firstException))
                {
                    throw new StripeCheckoutCreationException(
                        "Stripe rejected the Checkout Session request.",
                        false,
                        firstException);
                }

                return RetryUncertainCreate(service, options, requestOptions, order.Id, firstException);
            }
            catch (Exception firstException)
            {
                return RetryUncertainCreate(service, options, requestOptions, order.Id, firstException);
            }
        }

        public StripeCheckoutResult GetCheckoutSession(long orderId, string sessionId)
        {
            if (string.IsNullOrWhiteSpace(sessionId))
            {
                throw new ArgumentException("Stripe Checkout Session ID is required.", nameof(sessionId));
            }

            Session session = new SessionService().Get(sessionId);
            return ToCheckoutResult(orderId, session);
        }

        public StripePaymentState RetrievePaymentState(string sessionId)
        {
            if (string.IsNullOrWhiteSpace(sessionId))
            {
                throw new ArgumentException("Stripe Checkout Session ID is required.", nameof(sessionId));
            }

            var options = new SessionGetOptions
            {
                Expand = new List<string> { "payment_intent.payment_method" }
            };
            Session session = new SessionService().Get(sessionId, options);
            return ToPaymentState(session);
        }

        public bool TryExpireCheckoutSessionConfirmed(string sessionId)
        {
            if (string.IsNullOrWhiteSpace(sessionId))
            {
                return false;
            }

            var service = new SessionService();
            try
            {
                Session expired = service.Expire(sessionId);
                if (IsExpired(expired))
                {
                    return true;
                }
            }
            catch (Exception)
            {
                // A follow-up GET below is the confirmation authority.
            }

            try
            {
                return IsExpired(service.Get(sessionId));
            }
            catch (Exception)
            {
                return false;
            }
        }

        private static StripeCheckoutResult RetryUncertainCreate(
            SessionService service,
            SessionCreateOptions options,
            RequestOptions requestOptions,
            long orderId,
            Exception firstException)
        {
            try
            {
                // The same idempotency key recovers the original Session if Stripe created it.
                return ToCheckoutResult(orderId, service.Create(options, requestOptions));
            }
            catch (StripeException retryException)
            {
                bool mayExist = !IsDefinitiveCreateFailure(retryException);
                throw new StripeCheckoutCreationException(
                    mayExist
                        ? "Stripe Checkout Session creation could not be confirmed."
                        : "Stripe rejected the Checkout Session request.",
                    mayExist,
                    new AggregateException(firstException, retryException));
            }
            catch (Exception retryException)
            {
                throw new StripeCheckoutCreationException(
                    "Stripe Checkout Session creation could not be confirmed.",
                    true,
                    new AggregateException(firstException, retryException));
            }
        }

        private static void ValidatePendingOrder(Order order)
        {
            if (order == null)
            {
                throw new ArgumentNullException(nameof(order));
            }

            if (!order.PaymentExpiresAt.HasValue ||
                order.Items == null ||
                order.Items.Count == 0 ||
                string.IsNullOrWhiteSpace(order.CheckoutAttemptToken))
            {
                throw new InvalidOperationException("The pending order is incomplete.");
            }
        }

        private static string BuildIdempotencyKey(Order order)
        {
            return "onyx-checkout-" + order.Id + "-" + order.CheckoutAttemptToken;
        }

        private static string BuildCouponIdempotencyKey(Order order)
        {
            return "onyx-voucher-coupon-" + order.Id;
        }

        private static bool IsDefinitiveCreateFailure(StripeException exception)
        {
            int statusCode = (int)exception.HttpStatusCode;
            return statusCode >= (int)HttpStatusCode.BadRequest &&
                   statusCode < (int)HttpStatusCode.InternalServerError &&
                   statusCode != 408 &&
                   statusCode != 409 &&
                   statusCode != 429;
        }

        private static bool IsExpired(Session session)
        {
            return session != null &&
                   string.Equals(session.Status, "expired", StringComparison.OrdinalIgnoreCase);
        }

        private static StripeCheckoutResult ToCheckoutResult(long orderId, Session session)
        {
            if (session == null ||
                string.IsNullOrWhiteSpace(session.Id) ||
                string.IsNullOrWhiteSpace(session.Url))
            {
                throw new InvalidOperationException("Stripe did not return a usable Checkout Session.");
            }

            return new StripeCheckoutResult
            {
                OrderId = orderId,
                SessionId = session.Id,
                CheckoutUrl = session.Url,
                ExpiresAt = new DateTimeOffset(session.ExpiresAt.ToUniversalTime())
            };
        }

        private static StripePaymentState ToPaymentState(Session session)
        {
            if (session == null || string.IsNullOrWhiteSpace(session.Id))
            {
                throw new InvalidOperationException("Stripe did not return a usable Checkout Session.");
            }

            long orderId;
            long userId;
            string metadataOrderId = GetMetadataValue(session, "onyx_order_id");
            string metadataUserId = GetMetadataValue(session, "onyx_user_id");
            bool validOrder = long.TryParse(metadataOrderId, out orderId) && orderId > 0;
            bool validUser = long.TryParse(metadataUserId, out userId) && userId > 0;
            bool validReference = string.Equals(
                session.ClientReferenceId,
                metadataOrderId,
                StringComparison.Ordinal);

            PaymentIntent paymentIntent = session.PaymentIntent;
            PaymentMethod paymentMethod = paymentIntent == null ? null : paymentIntent.PaymentMethod;

            return new StripePaymentState
            {
                OrderId = validOrder ? orderId : 0,
                UserId = validUser ? userId : 0,
                SessionId = session.Id,
                SessionStatus = session.Status,
                PaymentStatus = session.PaymentStatus,
                Mode = session.Mode,
                Currency = session.Currency,
                AmountTotal = session.AmountTotal,
                CheckoutUrl = session.Url,
                PaymentIntentId = session.PaymentIntentId,
                PaymentMethodSummary = BuildPaymentMethodSummary(paymentMethod),
                CheckoutAttemptToken = GetMetadataValue(session, "onyx_checkout_attempt"),
                IsOnyxSession = validOrder && validUser && validReference
            };
        }

        private static string GetMetadataValue(Session session, string key)
        {
            if (session.Metadata == null || !session.Metadata.TryGetValue(key, out string value))
            {
                return null;
            }

            return value;
        }

        private static string BuildPaymentMethodSummary(PaymentMethod paymentMethod)
        {
            if (paymentMethod == null || string.IsNullOrWhiteSpace(paymentMethod.Type))
            {
                return "Stripe";
            }

            if (string.Equals(paymentMethod.Type, "card", StringComparison.OrdinalIgnoreCase))
            {
                string brand = paymentMethod.Card == null
                    ? "Card"
                    : FormatCardBrand(paymentMethod.Card.Brand);
                string last4 = paymentMethod.Card == null ? null : paymentMethod.Card.Last4;
                return string.IsNullOrWhiteSpace(last4)
                    ? brand
                    : brand + " ending " + last4;
            }

            if (string.Equals(paymentMethod.Type, "fpx", StringComparison.OrdinalIgnoreCase))
            {
                return "FPX";
            }

            if (string.Equals(paymentMethod.Type, "grabpay", StringComparison.OrdinalIgnoreCase))
            {
                return "GrabPay";
            }

            return "Stripe";
        }

        private static string FormatCardBrand(string brand)
        {
            if (string.IsNullOrWhiteSpace(brand))
            {
                return "Card";
            }

            if (string.Equals(brand, "visa", StringComparison.OrdinalIgnoreCase))
            {
                return "Visa";
            }

            if (string.Equals(brand, "mastercard", StringComparison.OrdinalIgnoreCase))
            {
                return "Mastercard";
            }

            return "Card";
        }

        private static SessionDiscountOptions CreateOrderDiscount(Order order)
        {
            if (order.DiscountAmount > 0m)
            {
                long amountOff = checked((long)Math.Round(
                    order.DiscountAmount * 100m,
                    0,
                    MidpointRounding.AwayFromZero));
                if (amountOff <= 0)
                {
                    throw new InvalidOperationException("The pending order discount is invalid.");
                }

                var couponOptions = new CouponCreateOptions
                {
                    AmountOff = amountOff,
                    Currency = "myr",
                    Duration = "once",
                    Metadata = new Dictionary<string, string>
                    {
                        { "onyx_order_id", order.Id.ToString() }
                    }
                };
                var couponRequestOptions = new RequestOptions
                {
                    IdempotencyKey = BuildCouponIdempotencyKey(order)
                };

                Coupon coupon = new CouponService().Create(couponOptions, couponRequestOptions);
                if (coupon == null || string.IsNullOrWhiteSpace(coupon.Id))
                {
                    throw new InvalidOperationException("Stripe did not return a usable discount coupon.");
                }

                return new SessionDiscountOptions
                {
                    Coupon = coupon.Id
                };
            }

            return null;
        }

        private static SessionLineItemOptions CreateLineItem(OrderItem item)
        {
            if (item == null || item.Quantity <= 0 || item.UnitPrice < 0)
            {
                throw new InvalidOperationException("The pending order contains an invalid line item.");
            }

            long unitAmount = checked((long)Math.Round(
                item.UnitPrice * 100m,
                0,
                MidpointRounding.AwayFromZero));

            return new SessionLineItemOptions
            {
                Quantity = item.Quantity,
                PriceData = new SessionLineItemPriceDataOptions
                {
                    Currency = "myr",
                    UnitAmount = unitAmount,
                    ProductData = new SessionLineItemPriceDataProductDataOptions
                    {
                        Name = item.ProductName
                    }
                }
            };
        }
    }

    public class StripeCheckoutCreationException : Exception
    {
        public StripeCheckoutCreationException(
            string message,
            bool sessionMayExist,
            Exception innerException)
            : base(message, innerException)
        {
            SessionMayExist = sessionMayExist;
        }

        public bool SessionMayExist { get; private set; }
    }
}
