$root = Split-Path $PSScriptRoot -Parent
$markup = Get-Content "$root\customer_page\onyx_checkout.aspx" -Raw
$page = Get-Content "$root\customer_page\onyx_checkout.aspx.cs" -Raw
$checkoutRepo = Get-Content "$root\DAL\CheckoutRepository.cs" -Raw
$paymentRepo = Get-Content "$root\DAL\PaymentRepository.cs" -Raw
$stripeService = Get-Content "$root\Services\StripePaymentService.cs" -Raw
$orderRepo = Get-Content "$root\DAL\OrderRepository.cs" -Raw
$adminDetails = Get-Content "$root\admin_page\onyx_admin_order_details.aspx" -Raw
$adminDetailsCode = Get-Content "$root\admin_page\onyx_admin_order_details.aspx.cs" -Raw
$history = Get-Content "$root\customer_page\onyx_order_history.aspx" -Raw
$historyCode = Get-Content "$root\customer_page\onyx_order_history.aspx.cs" -Raw
$invoice = Get-Content "$root\customer_page\onyx_invoice.aspx" -Raw
$invoiceCode = Get-Content "$root\customer_page\onyx_invoice.aspx.cs" -Raw
$confirmation = Get-Content "$root\customer_page\onyx_payment_confirmation.aspx" -Raw
$confirmationCode = Get-Content "$root\customer_page\onyx_payment_confirmation.aspx.cs" -Raw
$startCheckoutCall = [regex]::Match($page, 'StartCheckout\s*\((?s:.*?)\);').Value

$checks = [ordered]@{
    'Checkout loads authoritative category from explicit alias' =
        $checkoutRepo -match 'p\.category\s+AS\s+product_category' -and
        $checkoutRepo -notmatch 'p\.category\s*,\s*p\.category\s+AS\s+product_category' -and
        $checkoutRepo -match 'Category\s*=\s*reader\.GetString\(reader\.GetOrdinal\("product_category"\)\)'
    'Checkout can apply and remove voucher' = $markup -match 'ID="txtVoucherCode"' -and $markup -match 'ID="btnApplyVoucher"' -and $markup -match 'ID="btnRemoveVoucher"' -and $page -match 'btnApplyVoucher_Click' -and $page -match 'btnRemoveVoucher_Click'
    'Checkout displays voucher totals' = $markup -match 'litCheckoutSubtotal' -and $markup -match 'litVoucherDiscount' -and $markup -match 'litCheckoutTotal'
    'Terms use an accessible modal' = $markup -match 'role="dialog"' -and $markup -match 'aria-modal="true"' -and $page -match 'HtmlEncode'
    'Checkout keeps voucher preview state' = $page -match 'AppliedVoucherCode'
    'Checkout apply handles unavailable cart safely' =
        $page -match 'catch\s*\(InvalidOperationException(?:\s+\w+)?\)' -and
        $page -match 'catch\s*\(Exception\s+\w+\)' -and
        $page -match 'Trace\.TraceError\("Voucher checkout preview apply failed for user \{0\}: \{1\}"' -and
        $page -match 'Checkout is currently unavailable\. Return to your cart and verify item quantities\.'
    'Checkout passes applied voucher into StartCheckout handoff' =
        -not [string]::IsNullOrWhiteSpace($startCheckoutCall) -and
        $startCheckoutCall -match 'AppliedVoucherCode'
    'Stripe checkout rounds authoritative MYR coupon amount from order discount' =
        $stripeService -match 'order\.DiscountAmount\s*>\s*0m' -and
        $stripeService -match 'checked\s*\(\s*\(long\)\s*Math\.Round\(\s*order\.DiscountAmount\s*\*\s*100m,\s*0,\s*MidpointRounding\.AwayFromZero\s*\)\s*\)' -and
        $stripeService -match 'new CouponCreateOptions' -and
        $stripeService -match 'AmountOff\s*=' -and
        $stripeService -match 'Currency\s*=\s*"myr"' -and
        $stripeService -match 'Duration\s*=\s*"once"' -and
        $stripeService -match 'MaxRedemptions\s*=\s*1' -and
        $stripeService -match 'Name\s*=\s*order\.VoucherCode'
    'Stripe coupon creation uses per-order idempotency and voucher metadata' =
        $stripeService -match 'onyx-voucher-coupon-' -and
        $stripeService -match 'IdempotencyKey\s*=\s*BuildCouponIdempotencyKey\(order\)' -and
        $stripeService -match '"onyx_order_id"' -and
        $stripeService -match '"onyx_voucher_id"' -and
        $stripeService -match 'order\.VoucherId\.Value\.ToString\(\)'
    'Stripe session attaches discount coupon when present' =
        $stripeService -match 'new SessionDiscountOptions' -and
        $stripeService -match 'Discounts\s*=' -and
        $stripeService -match 'Coupon\s*='
    'Paid orders redeem voucher atomically before commit' =
        $paymentRepo -match 'MarkOrderPaid[\s\S]*VoucherRepository\.RedeemForOrder[\s\S]*tx\.Commit'
    'Stripe payment cancellation releases voucher after order cancellation update' =
        $paymentRepo -match 'CancelPayment[\s\S]*UPDATE orders[\s\S]*VoucherRepository\.ReleaseForOrder[\s\S]*tx\.Commit'
    'Checkout cancellation releases voucher before commit' =
        $checkoutRepo -match 'CancelPendingOrderAndReleaseReservations[\s\S]*VoucherRepository\.ReleaseForOrder[\s\S]*tx\.Commit'
    'Order repository hydrates voucher snapshots' =
        $orderRepo -match 'subtotal_amount' -and
        $orderRepo -match 'discount_amount' -and
        $orderRepo -match 'voucher_code' -and
        $orderRepo -match 'voucher_name'
    'Admin order shows voucher breakdown and free shipping' =
        $adminDetails -match 'pnlVoucherSummary' -and
        $adminDetailsCode -match 'SubtotalAmount' -and
        $adminDetailsCode -match 'DiscountAmount' -and
        $adminDetails -match 'RM 0\.00' -and
        $adminDetails -notmatch 'RM 10\.00'
    'Order history shows voucher savings' =
        ($history + $historyCode) -match 'VoucherCode' -and
        ($history + $historyCode) -match 'DiscountAmount'
    'Invoice shows stored voucher totals' =
        ($invoice + $invoiceCode) -match 'SubtotalAmount' -and
        ($invoice + $invoiceCode) -match 'DiscountAmount' -and
        ($invoice + $invoiceCode) -match 'VoucherCode'
    'Payment confirmation shows stored voucher totals' =
        ($confirmation + $confirmationCode) -match 'SubtotalAmount' -and
        ($confirmation + $confirmationCode) -match 'DiscountAmount' -and
        ($confirmation + $confirmationCode) -match 'VoucherCode'
}

$failures = @($checks.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) { throw ('Missing voucher checkout requirements: ' + (($failures | ForEach-Object Key) -join ', ')) }
Write-Output 'Voucher checkout source contract passes.'
