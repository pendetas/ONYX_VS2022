$root = Split-Path $PSScriptRoot -Parent
$checkoutRepository = Get-Content "$root\DAL\CheckoutRepository.cs" -Raw
$paymentRepository = Get-Content "$root\DAL\PaymentRepository.cs" -Raw
$cartRepository = Get-Content "$root\DAL\CartRepository.cs" -Raw
$checkoutPage = Get-Content "$root\customer_page\onyx_checkout.aspx.cs" -Raw
$orderHistoryPage = Get-Content "$root\customer_page\onyx_order_history.aspx.cs" -Raw
$paymentCancelPage = Get-Content "$root\customer_page\onyx_payment_cancel.aspx.cs" -Raw

$requirements = [ordered]@{
    'Pending checkout removes purchased cart quantities' =
        $checkoutRepository -match 'RemoveCheckedOutCartItems\s*\('
    'Definite checkout failure restores cart quantities' =
        $checkoutRepository -match 'CartRepository\.RestoreCartItems\s*\('
    'Stripe cancellation restores cart quantities' =
        $paymentRepository -match 'CartRepository\.RestoreCartItems\s*\('
    'Paid reconciliation does not decrement the cart again' =
        $paymentRepository -notmatch 'DecrementPurchasedCartQuantities\s*\('
    'Cart restoration merges order items transactionally' =
        $cartRepository -match 'internal static void RestoreCartItems' -and
        $cartRepository -match 'ON CONFLICT \(user_id, product_id, variant_key\)'
    'Checkout refreshes session cart before Stripe redirect' =
        $checkoutPage -match 'RefreshCurrentUserCartFromDatabase\s*\(\)'
    'Expired cancellation refreshes the session cart' =
        $orderHistoryPage -match 'result\.OrderStatus[\s\S]*OrderStatuses\.Cancelled[\s\S]*cartChanged\s*=\s*true'
    'Stripe cancel return refreshes the session cart' =
        $paymentCancelPage -match 'RefreshCurrentUserCartFromDatabase\s*\(\)'
}

$failures = @($requirements.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) {
    throw ('Missing cart-transfer requirements: ' + (($failures | ForEach-Object Key) -join ', '))
}

Write-Output 'Pending checkout cart-transfer source contract passes.'
