# Voucher Loyalty Management Design

**Date:** 2026-07-17
**Status:** Approved design
**Application:** ONYX ASP.NET Web Forms storefront and admin portal

## Goal

Replace the existing UI-only Promotions page with a production-ready Loyalty Management area where administrators can create and manage public voucher codes. Customers apply one voucher during checkout, see its terms and discount before payment, and pay the server-authoritative reduced total through Stripe.

The implementation must preserve ONYX's current checkout guarantees: authoritative database prices, stock reservation, idempotent Stripe session creation, safe cancellation, and payment reconciliation.

## Scope

### Included

- Public voucher codes available to any authenticated customer who knows the code.
- Percentage and fixed-MYR discounts.
- Optional maximum discount for percentage vouchers.
- Minimum pre-discount cart subtotal.
- Eligibility for all categories or multiple selected product categories.
- Valid-from and expiry timestamps.
- Active/paused control, total redemption limit, and per-customer limit.
- One voucher per order with no stacking.
- Multiline terms and conditions entered by an administrator.
- Checkout voucher application, T&C modal, discount summary, and Stripe integration.
- Pending, redeemed, and released redemption lifecycle.
- Admin reporting for active vouchers, redemptions, and savings.
- Voucher audit snapshots on orders and voucher information on order/receipt views.

### Excluded

- Loyalty points, membership tiers, cashback, referrals, gift cards, and customer-targeted vouchers.
- Multiple vouchers on one order.
- Shipping vouchers because ONYX delivery is currently free.
- File uploads or raw HTML for terms and conditions.
- Automatic voucher distribution by email or notification.

These exclusions keep the first Loyalty Management release focused while leaving room for later modules.

## Recommended Architecture

The existing `onyx_admin_promos.aspx` page is mock-data-only and has no persistence. Replace that experience with a Loyalty Management module rather than maintaining two overlapping promotion systems.

The admin sidebar label becomes **Loyalty**. The module contains a voucher list and a dedicated create/edit page. The checkout integration is split across four bounded responsibilities:

1. `VoucherRepository` owns voucher persistence, row locks, redemption counts, and lifecycle updates.
2. `VoucherService` owns input validation, eligibility rules, and discount calculation.
3. `CheckoutRepository` remains the transaction authority that reloads the cart, locks stock and the voucher, reserves redemption, and creates the order.
4. `StripePaymentService` sends the already-calculated order discount to Stripe and never calculates eligibility itself.

Payment completion and cancellation update voucher redemptions in the same transactions that update order and stock state.

## Data Model

### `vouchers`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | `BIGINT` identity | Primary key |
| `name` | `VARCHAR(120)` | Required display name |
| `code` | `VARCHAR(40)` | Required, stored uppercase |
| `discount_type` | `VARCHAR(20)` | `percentage` or `fixed` |
| `discount_value` | `NUMERIC(10,2)` | Greater than zero; percentage at most 100 |
| `maximum_discount_amount` | `NUMERIC(10,2)` nullable | Percentage vouchers only |
| `minimum_purchase_amount` | `NUMERIC(10,2)` | Non-negative, default zero |
| `applies_to_all_categories` | `BOOLEAN` | True means category rows are unnecessary |
| `valid_from` | `TIMESTAMPTZ` | Required |
| `expires_at` | `TIMESTAMPTZ` | Required and later than `valid_from` |
| `total_usage_limit` | `INTEGER` nullable | Null means unlimited; otherwise positive |
| `per_user_usage_limit` | `INTEGER` | Positive, default one |
| `is_active` | `BOOLEAN` | Admin pause/resume control |
| `terms_and_conditions` | `TEXT` | Required multiline plain text |
| `created_by_user_id` | `BIGINT` nullable | References the creating admin when available |
| `created_at` | `TIMESTAMPTZ` | Required |
| `updated_at` | `TIMESTAMPTZ` | Required |
| `archived_at` | `TIMESTAMPTZ` nullable | Soft-delete marker |

Create a unique case-insensitive index on `LOWER(code)`. Add database checks for discount type/value, limits, non-negative amounts, and date order. A fixed voucher must have a null maximum-discount value; a percentage voucher may have a positive maximum-discount value or no cap.

### `voucher_categories`

| Column | Type | Rules |
| --- | --- | --- |
| `voucher_id` | `BIGINT` | References `vouchers(id)` with cascade delete before use |
| `category` | `VARCHAR(50)` | Matches a current product category |

The composite primary key is `(voucher_id, category)`. A voucher with `applies_to_all_categories = false` must have at least one category, enforced by service validation in the same save transaction. Category rows may cascade-delete only when deleting a voucher that has never produced a redemption; used vouchers are archived instead.

### `voucher_redemptions`

| Column | Type | Rules |
| --- | --- | --- |
| `id` | `BIGINT` identity | Primary key |
| `voucher_id` | `BIGINT` | Required voucher reference |
| `user_id` | `BIGINT` | Required customer reference |
| `order_id` | `BIGINT` | Required unique order reference |
| `eligible_subtotal` | `NUMERIC(10,2)` | Eligible amount used in calculation |
| `discount_amount` | `NUMERIC(10,2)` | Final reserved discount |
| `status` | `VARCHAR(20)` | `pending`, `redeemed`, or `released` |
| `reserved_at` | `TIMESTAMPTZ` | Required |
| `redeemed_at` | `TIMESTAMPTZ` nullable | Set on successful payment |
| `released_at` | `TIMESTAMPTZ` nullable | Set on cancellation/expiry/failure |

Pending and redeemed rows count toward total and per-user limits. Released rows do not. Index `(voucher_id, status)` and `(voucher_id, user_id, status)` to support locked limit checks.

### Order snapshots

Add these columns to `orders`:

- `subtotal_amount NUMERIC(10,2) NOT NULL DEFAULT 0`
- `discount_amount NUMERIC(10,2) NOT NULL DEFAULT 0`
- `voucher_id BIGINT NULL`
- `voucher_code VARCHAR(40) NULL`
- `voucher_name VARCHAR(120) NULL`

`total_amount` remains the final payable amount. Existing orders are backfilled so `subtotal_amount = total_amount` and `discount_amount = 0`. The code and name snapshots keep historical receipts stable after voucher edits.

## Voucher Rules

### Eligibility

The server loads authoritative product categories and prices from the database. For an all-category voucher, every order item is eligible. Otherwise, only items whose product category matches `voucher_categories` contribute to the eligible subtotal.

The minimum purchase check uses the full cart subtotal before discount. At least one item must be eligible.

### Discount calculation

- Percentage: `eligible subtotal × percentage ÷ 100`, rounded to two decimals using away-from-zero monetary rounding, then limited by the optional maximum discount.
- Fixed: the configured amount, limited to the eligible subtotal.
- The discount can never be negative or greater than the full cart subtotal.
- Final total: `cart subtotal - discount amount`.

All calculations use `decimal`; floating-point values are not allowed.

### Usage and lifecycle

- Only one voucher can be attached to an order.
- The default per-user limit is one but remains configurable.
- Status is displayed as upcoming, active, paused, expired, exhausted, or archived based on flags, dates, and limits.
- Once any redemption row exists, the code, discount type/value/cap, minimum purchase, and category eligibility become immutable. Administrators may still update the display name and terms, pause the voucher, extend its expiry, or raise its limits. They may not shorten validity below an active pending checkout or reduce a limit below current pending plus redeemed usage.
- Used vouchers are archived, not hard-deleted.

## Admin Experience

### Navigation and list

Rename the current Promos navigation item to **Loyalty**, using the existing admin master and active-navigation behavior. The Loyalty page has a **Vouchers** section with:

- Active voucher, total redemption, and total savings metrics.
- Search by name/code and filters for all, active, upcoming, paused, expired, exhausted, and archived.
- Columns for code/name, discount, eligibility, minimum purchase, usage/limit, validity, and status.
- Edit, pause/resume, and archive actions.
- Empty and database-error states.

### Create/edit form

Use a dedicated form because the approved fields and T&C do not fit safely in the existing modal. Sections are:

1. Identity: name and uppercase code.
2. Discount: type, value, optional cap, and minimum purchase.
3. Eligibility: all categories or a multi-select populated from distinct product categories.
4. Availability: valid-from, expiry, active switch, total limit, and per-user limit.
5. Terms: required multiline text with a live plain-text preview.

The form follows the current polished admin language: Inter font, monochrome surfaces, subtle borders, 10px cards, restrained status colors, responsive layout, light-theme overrides, visible keyboard focus, and a sticky save/cancel action bar. Remove the current Promotions page's Bootstrap dependency and bright green/purple primary styling.

## Customer Checkout Experience

The checkout summary contains a voucher field and **Apply** action above the totals. Applying a voucher performs a server postback that displays one of two states:

- Applied: voucher name/code, eligible scope, discount, remove action, and a small **T&C apply** link.
- Rejected: a concise reason such as invalid code, not started, expired, paused, minimum not reached, no eligible products, or usage limit reached.

The T&C link opens an accessible modal. Terms are stored as plain text, HTML-encoded during rendering, and displayed with preserved line breaks and administrator-entered bullet characters. Raw administrator HTML is never rendered.

The summary displays subtotal, voucher discount as a negative amount, and final total. The checkout page may retain the entered code in ViewState for display, but ViewState is not a pricing authority.

## Authoritative Checkout Flow

1. The customer applies a code and receives a preview quote from current authoritative cart data.
2. The customer clicks Pay With Stripe.
3. `CheckoutService.StartCheckout` receives the code in addition to existing checkout fields.
4. Inside the existing order transaction, the repository locks the customer checkout, cart rows, stock rows, and matching voucher row.
5. It reloads authoritative items, validates stock, recalculates voucher eligibility, and checks dates and limits.
6. It inserts the pending order with subtotal, discount, final total, and voucher snapshots.
7. It inserts order items at their original unit prices, stock reservations, and one pending voucher redemption.
8. It removes the checked-out cart quantities and commits.
9. Stripe receives original line items plus a one-time fixed-amount order coupon equal to the stored discount. Coupon and Session creation use order-based idempotency keys.
10. Payment success marks the order paid, completes stock reservations, and marks the voucher redemption redeemed.
11. Cancellation, expiry, asynchronous failure, or definitive Session-creation failure restores the cart, releases stock, and marks the voucher redemption released.

The Stripe coupon is a payment representation only. ONYX remains the authority for voucher validity and discount calculation. Any unused Stripe coupon from an uncertain network failure is harmless because it is order-specific, has one redemption, and is not exposed as a customer promotion code.

## Idempotency and Concurrency

- Lock the voucher row before counting pending/redeemed rows and inserting a redemption.
- A unique `order_id` in `voucher_redemptions` prevents duplicate reservations.
- Reusing an existing checkout-attempt token returns its existing pending order and voucher state.
- A different voucher cannot replace the voucher on an existing pending attempt.
- Limit checks and redemption insertion occur in the same transaction.
- Payment completion and cancellation remain idempotent; repeated events leave the redemption in its terminal state.

## Error Handling and Security

- Validate all admin fields server-side even when client validation exists.
- Parameterize every SQL statement.
- Require admin authentication through `admin.Master` for every management action.
- Normalize codes with `Trim()` and uppercase invariant handling.
- Do not reveal internal database, Stripe, or stack-trace details to customers.
- Do not trust client totals, selected categories, voucher status, or discount values.
- Prevent archival or rule mutation from invalidating pending redemptions.
- Render T&C and voucher names with output encoding.
- Log voucher validation and payment-state failures without logging secrets.

## Reporting and Order Views

Admin order details, customer order history, invoices, and payment confirmation should show subtotal, voucher code/name, discount, and final total when a voucher exists. Existing non-voucher orders continue to display normally.

Loyalty metrics use redeemed rows only:

- Active vouchers: vouchers currently usable by date, state, and remaining total limit.
- Total redemptions: count of redeemed rows.
- Total savings: sum of redeemed `discount_amount`.

## Testing Strategy

### Rule tests

- Percentage, fixed, cap, and rounding behavior.
- Discount limited to eligible categories and subtotal.
- All-category and multiple-category eligibility.
- Minimum purchase based on full pre-discount subtotal.
- Date boundaries, active state, archive state, and usage limits.
- Invalid configurations and zero/negative values.

### Repository and transaction tests

- Unique code and order-redemption constraints.
- Concurrent final redemption attempts do not exceed limits.
- Pending rows count toward limits; released rows do not.
- Order snapshots and final totals match calculated values.
- Cancellation restores cart/stock and releases redemption.
- Successful payment marks redemption redeemed exactly once.

### UI and source-contract tests

- Loyalty navigation and active state.
- Admin create/edit controls, required fields, light theme, and responsive action bar.
- Checkout apply/remove behavior and error messages.
- T&C modal opens, closes, traps focus appropriately, and encodes content.
- Totals display subtotal, discount, and final amount.
- Existing checkout without a voucher remains unchanged.

### Verification

- Run focused PowerShell source-contract tests.
- Run the full `Tests` and `tests` PowerShell sweep.
- Build `ONYX_DDAC.sln` in Visual Studio 2022 Debug configuration.
- If a PostgreSQL test environment is available, execute the migration and transactional redemption scenarios against it.
- Use Stripe test mode to verify successful, cancelled, expired, and repeated webhook flows.

## Acceptance Criteria

- An admin can create, view, edit, pause, resume, and archive a voucher from Loyalty Management.
- The admin interface visually matches the other ONYX admin sections in dark and light modes.
- A customer can apply one valid public voucher at checkout and inspect its T&C in a modal.
- Only eligible-category items receive the discount.
- Minimum purchase, dates, status, per-user limit, and total limit are enforced server-side.
- The displayed checkout total, stored order total, Stripe total, invoice total, and payment confirmation total agree.
- Successful payments consume one redemption; cancelled or failed checkouts release it.
- Concurrent customers cannot exceed the configured voucher limit.
- Existing non-voucher checkout and payment flows continue to work.
