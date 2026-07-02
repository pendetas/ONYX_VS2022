using System;
using System.Collections.Generic;
using System.Linq;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.Services
{
    public class CheckoutService
    {
        private static readonly HashSet<string> FreeDeliveryMethods = new HashSet<string>(
            new[] { "Standard Delivery", "Express Delivery", "Self Pickup" },
            StringComparer.Ordinal);

        private readonly CheckoutRepository _checkoutRepository;

        public CheckoutService()
        {
            _checkoutRepository = new CheckoutRepository();
        }

        public IList<CartItem> GetValidatedCheckoutCart(long userId)
        {
            if (userId <= 0)
            {
                throw new InvalidOperationException("You must be logged in to checkout.");
            }

            return _checkoutRepository.GetValidatedCartForCheckout(userId)
                .ToList();
        }

        public StripeCheckoutResult StartCheckout(
            long userId,
            string shippingAddress,
            string deliveryMethod,
            string checkoutAttemptToken,
            string applicationBaseUrl)
        {
            shippingAddress = (shippingAddress ?? string.Empty).Trim();
            deliveryMethod = (deliveryMethod ?? string.Empty).Trim();
            checkoutAttemptToken = (checkoutAttemptToken ?? string.Empty).Trim();

            ValidateRequest(userId, shippingAddress, deliveryMethod, checkoutAttemptToken);

            if (!Uri.TryCreate(applicationBaseUrl, UriKind.Absolute, out Uri baseUri) ||
                (baseUri.Scheme != Uri.UriSchemeHttp && baseUri.Scheme != Uri.UriSchemeHttps))
            {
                throw new InvalidOperationException("The trusted Stripe callback URL is invalid.");
            }

            // Stripe requires expires_at to be at least 30 minutes in the future when
            // it receives the request. The extra minute covers database and network work.
            DateTimeOffset expiresAt = DateTimeOffset.UtcNow.AddMinutes(31);
            string paymentCancellationToken = PaymentCancellationTokenService.GenerateToken();
            Order order = _checkoutRepository.CreatePendingOrderWithReservations(
                userId,
                shippingAddress,
                deliveryMethod,
                checkoutAttemptToken,
                PaymentCancellationTokenService.HashToken(paymentCancellationToken),
                expiresAt);

            StripePaymentService stripePaymentService;
            try
            {
                stripePaymentService = new StripePaymentService();
            }
            catch
            {
                if (!order.IsExistingCheckoutAttempt)
                {
                    CancelDefiniteFailure(order.Id, userId);
                }
                throw;
            }

            if (!string.IsNullOrWhiteSpace(order.StripeCheckoutSessionId))
            {
                return stripePaymentService.GetCheckoutSession(order.Id, order.StripeCheckoutSessionId);
            }

            StripeCheckoutResult stripeResult;
            try
            {
                stripeResult = stripePaymentService.CreateCheckoutSession(
                    order,
                    baseUri,
                    paymentCancellationToken);
            }
            catch (StripeCheckoutCreationException ex)
            {
                if (!ex.SessionMayExist)
                {
                    CancelDefiniteFailure(order.Id, userId);
                }

                throw;
            }
            catch
            {
                if (!order.IsExistingCheckoutAttempt)
                {
                    CancelDefiniteFailure(order.Id, userId);
                }
                throw;
            }

            try
            {
                _checkoutRepository.SaveStripeSession(
                    order.Id,
                    userId,
                    stripeResult.SessionId,
                    stripeResult.ExpiresAt);
                return stripeResult;
            }
            catch (Exception persistenceException)
            {
                try
                {
                    _checkoutRepository.SaveStripeSession(
                        order.Id,
                        userId,
                        stripeResult.SessionId,
                        stripeResult.ExpiresAt);
                    return stripeResult;
                }
                catch (Exception retryException)
                {
                    if (stripePaymentService.TryExpireCheckoutSessionConfirmed(stripeResult.SessionId))
                    {
                        CancelDefiniteFailure(order.Id, userId);
                    }

                    throw new InvalidOperationException(
                        "Stripe Checkout was created but its local state could not be confirmed.",
                        new AggregateException(persistenceException, retryException));
                }
            }
        }

        private static void ValidateRequest(
            long userId,
            string shippingAddress,
            string deliveryMethod,
            string checkoutAttemptToken)
        {
            if (userId <= 0)
            {
                throw new InvalidOperationException("You must be logged in to checkout.");
            }

            if (string.IsNullOrWhiteSpace(shippingAddress))
            {
                throw new InvalidOperationException("Shipping address is required.");
            }

            if (!FreeDeliveryMethods.Contains(deliveryMethod))
            {
                throw new InvalidOperationException("Select a valid free delivery method.");
            }

            if (!Guid.TryParse(checkoutAttemptToken, out Guid parsedToken) ||
                parsedToken == Guid.Empty)
            {
                throw new InvalidOperationException("The checkout attempt is invalid. Refresh and try again.");
            }
        }

        private void CancelDefiniteFailure(long orderId, long userId)
        {
            _checkoutRepository.CancelPendingOrderAndReleaseReservations(orderId, userId);
        }

        public Order GetPendingOrderForCancellation(
            long orderId,
            long userId,
            string paymentCancellationToken)
        {
            if (orderId <= 0 || userId <= 0 || string.IsNullOrWhiteSpace(paymentCancellationToken))
            {
                return null;
            }

            Order order = _checkoutRepository.GetPendingOrderForCancellation(orderId, userId);
            return order != null &&
                   PaymentCancellationTokenService.Matches(
                       paymentCancellationToken,
                       order.PaymentCancellationTokenHash)
                ? order
                : null;
        }

        public PaymentReconciliationResult CancelPendingPayment(long orderId, long userId)
        {
            if (orderId <= 0 || userId <= 0)
            {
                throw new InvalidOperationException("A valid pending order and user are required.");
            }

            Order order = _checkoutRepository.GetPendingOrderForCancellation(orderId, userId);
            if (order == null || string.IsNullOrWhiteSpace(order.StripeCheckoutSessionId))
            {
                throw new InvalidOperationException("The pending payment was not found.");
            }

            var stripe = new StripePaymentService();
            if (!stripe.TryExpireCheckoutSessionConfirmed(order.StripeCheckoutSessionId))
            {
                throw new InvalidOperationException(
                    "Stripe could not confirm cancellation. Refresh the order before retrying.");
            }

            PaymentReconciliationResult result =
                new PaymentCompletionService().ReconcileForUser(order.StripeCheckoutSessionId, userId);
            if (!string.Equals(result.OrderStatus, OrderStatuses.Cancelled, StringComparison.OrdinalIgnoreCase))
            {
                throw new InvalidOperationException("The payment was not cancelled.");
            }

            return result;
        }
    }
}
