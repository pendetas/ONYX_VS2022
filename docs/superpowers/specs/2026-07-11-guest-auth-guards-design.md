# Guest Authentication Guards

## Goal

Prevent logged-out visitors from using customer-owned features. When a guest attempts one of these actions, ONYX sends them to the existing login page. A successful login continues to the customer homepage, subject to the existing first-time personalization requirement.

## Protected actions and pages

- Adding a product to the cart
- Opening or modifying the cart
- Adding, removing, or moving wishlist items
- Checkout and payment pages
- Profile, order history, invoices, reviews, and personalization

Catalog browsing, product viewing, public content, login, and registration remain available to guests.

## Design

Authentication is enforced on the server through `AuthHelper`, before any cart, wishlist, order, or review service call. Product buttons remain visible so a guest can express intent, but the server redirects an unauthenticated postback to `~/auth_page/onyx_login.aspx` instead of changing session or database state.

The cart page also requires authentication during page load. Existing page-specific authentication checks are normalized to the shared helper where that can be done without changing their current behavior.

The login flow keeps its existing default customer destination, `~/customer_page/onyx_home.aspx`. No pending cart action or guest cart is retained. Registration remains reachable through the existing link on the login page.

## Security and error handling

The server-side guard is authoritative; client-side hiding is not used as a security control. Redirects use application-local paths and do not accept an arbitrary return URL, avoiding open-redirect risk. Authentication is checked before request values are parsed or state-changing services run.

## Verification

Add a source-contract regression test that proves:

- Add-to-cart checks authentication before calling `CartService.AddToCart`.
- The cart page requires authentication before binding or modifying cart state.
- Wishlist and customer-owned pages retain authentication guards.
- Login continues to use the customer homepage as its default destination.

Run all existing PowerShell contract tests and the Release package build.
