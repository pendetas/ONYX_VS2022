$root = Split-Path $PSScriptRoot -Parent
$markup = Get-Content "$root\customer_page\onyx_checkout.aspx" -Raw
$page = Get-Content "$root\customer_page\onyx_checkout.aspx.cs" -Raw
$checkoutRepo = Get-Content "$root\DAL\CheckoutRepository.cs" -Raw
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
    'Checkout preview stops before Task 7 StartCheckout handoff' =
        -not [string]::IsNullOrWhiteSpace($startCheckoutCall) -and
        $startCheckoutCall -notmatch 'AppliedVoucherCode'
}

$failures = @($checks.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) { throw ('Missing voucher checkout requirements: ' + (($failures | ForEach-Object Key) -join ', ')) }
Write-Output 'Voucher checkout source contract passes.'
