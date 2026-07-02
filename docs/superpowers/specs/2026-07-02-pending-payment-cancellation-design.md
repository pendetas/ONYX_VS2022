# Pending Payment Cancellation Design

## Goal

Allow an authenticated customer to cancel their own `pending_payment` order from order history when Stripe Checkout cannot be opened.

## User flow

The order-history card shows **Cancel Payment** beside **Continue Payment** only while the order is still pending and has a Stripe Checkout Session. Clicking it presents a native confirmation prompt. Confirmation submits a server-side postback; cancellation is never performed through a GET request.

## Server flow

1. Read the authenticated user ID from the existing session.
2. Load the pending order by order ID and user ID. Ownership and pending status are enforced by the repository query.
3. Ask Stripe to expire the stored Checkout Session and confirm that it is expired.
4. Reconcile the Stripe state through the existing payment-completion flow.
5. Mark the order cancelled and release stock reservations through the existing repository transaction.
6. Refresh order history with a cancellation success message.

The Stripe cancellation token remains required for Stripe's `cancel_url`. The authenticated order-history action uses session ownership instead, because the raw cancellation token is intentionally not stored.

## Failure handling

- Missing authentication redirects to login.
- Invalid, paid, cancelled, expired, or another customer's order is rejected without changing data.
- If Stripe cannot confirm expiration, the order and reservation remain pending and the page shows a retryable error.
- Repeated cancellation requests are safe and do not release stock twice.

## Files

- `customer_page/onyx_order_history.aspx`: pending-order cancel button and confirmation prompt.
- `customer_page/onyx_order_history.aspx.cs`: postback handler and status message.
- `Services/CheckoutService.cs`: authenticated cancellation orchestration.
- Existing repository, Stripe expiration, reconciliation, and reservation-release methods are reused.

## Verification

- A focused check proves only the owning authenticated user can request cancellation.
- Core compilation succeeds.
- Source validation confirms cancellation uses a postback and no conflict markers are introduced.
- Manual smoke test: cancel a pending test-mode session, confirm Stripe reports it expired, the order becomes cancelled, and reserved stock is released.
