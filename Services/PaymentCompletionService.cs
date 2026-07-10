using System;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Models;
using Stripe;

namespace ONYX_DDAC.Services
{
    public class PaymentCompletionService
    {
        private readonly StripePaymentService _stripePaymentService;
        private readonly PaymentRepository _paymentRepository;

        public PaymentCompletionService()
        {
            _stripePaymentService = new StripePaymentService();
            _paymentRepository = new PaymentRepository();
        }

        public PaymentReconciliationResult Reconcile(
            string sessionId,
            string stripeEventId,
            string eventType)
        {
            return Reconcile(sessionId, stripeEventId, eventType, null);
        }

        public PaymentReconciliationResult ReconcileForUser(string sessionId, long userId)
        {
            if (userId <= 0)
            {
                throw new InvalidOperationException("A valid user is required.");
            }

            return Reconcile(sessionId, null, null, userId);
        }

        private PaymentReconciliationResult Reconcile(
            string sessionId,
            string stripeEventId,
            string eventType,
            long? expectedUserId)
        {
            StripePaymentState payment = _stripePaymentService.RetrievePaymentState(sessionId);
            if (!payment.IsOnyxSession)
            {
                if (_paymentRepository.HasLocalOrderForSession(sessionId))
                {
                    throw new InvalidOperationException(
                        "A locally linked Stripe Checkout Session has inconsistent ownership metadata.");
                }

                return new PaymentReconciliationResult
                {
                    OrderStatus = "ignored"
                };
            }

            if (expectedUserId.HasValue && payment.UserId != expectedUserId.Value)
            {
                throw new InvalidOperationException("The Stripe Checkout Session does not belong to this user.");
            }

            if (payment.IsPaid)
            {
                if (string.IsNullOrWhiteSpace(payment.PaymentIntentId))
                {
                    throw new InvalidOperationException("Stripe reported a paid Session without a PaymentIntent.");
                }

                return _paymentRepository.CompletePayment(payment, stripeEventId, eventType);
            }

            bool asynchronousFailure = string.Equals(
                eventType,
                EventTypes.CheckoutSessionAsyncPaymentFailed,
                StringComparison.Ordinal);

            if (payment.IsExpired || asynchronousFailure)
            {
                return _paymentRepository.CancelPayment(payment, stripeEventId, eventType);
            }

            if (!payment.IsOpen)
            {
                payment.CheckoutUrl = null;
            }

            return _paymentRepository.GetCurrentState(payment);
        }
    }
}
