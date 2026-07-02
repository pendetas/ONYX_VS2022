$root = Split-Path $PSScriptRoot -Parent
$markup = Get-Content "$root\customer_page\onyx_order_history.aspx" -Raw
$page = Get-Content "$root\customer_page\onyx_order_history.aspx.cs" -Raw
$service = Get-Content "$root\Services\CheckoutService.cs" -Raw

$requirements = [ordered]@{
    'Repeater dispatches server-side commands' = $markup -match 'OnItemCommand="rptRecentOrders_ItemCommand"'
    'Pending order has a cancel command' = $markup -match 'CommandName="CancelPayment"'
    'Cancellation requires confirmation' = $markup -match 'return confirm\('
    'Page handles cancellation postback' = $page -match 'rptRecentOrders_ItemCommand'
    'Service owns cancellation orchestration' = $service -match 'CancelPendingPayment\s*\('
    'Service verifies order ownership' = $service -match 'GetPendingOrderForCancellation\s*\(orderId, userId\)'
    'Service confirms Stripe expiration' = $service -match 'TryExpireCheckoutSessionConfirmed'
    'Service reconciles final state' = $service -match 'ReconcileForUser'
}

$failures = @($requirements.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) {
    throw ('Missing cancellation requirements: ' + (($failures | ForEach-Object Key) -join ', '))
}

Write-Output 'Pending payment cancellation source contract passes.'
