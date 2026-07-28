$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$statuses = Get-Content -Raw -Path (Join-Path $repoRoot 'Models\OrderStatuses.cs')
$historyCode = Get-Content -Raw -Path (Join-Path $repoRoot 'customer_page\onyx_order_history.aspx.cs')
$historyMarkup = Get-Content -Raw -Path (Join-Path $repoRoot 'customer_page\onyx_order_history.aspx')
$historyCss = Get-Content -Raw -Path (Join-Path $repoRoot 'Content\onyx-account.css')
$orderService = Get-Content -Raw -Path (Join-Path $repoRoot 'Services\OrderService.cs')
$orderRepository = Get-Content -Raw -Path (Join-Path $repoRoot 'DAL\OrderRepository.cs')

$checks = [ordered]@{
    'Shared statuses include the admin fulfillment values' =
        $statuses -match 'Pending\s*=\s*"pending"' -and
        $statuses -match 'Shipped\s*=\s*"shipped"' -and
        $statuses -match 'Delivered\s*=\s*"delivered"'
    'Order History renders fulfillment statuses instead of Unknown' =
        $historyCode -match 'OrderStatuses\.Shipped' -and
        $historyCode -match 'OrderStatuses\.Delivered' -and
        $historyCode -match 'return "Shipped";' -and
        $historyCode -match 'return "Delivered";'
    'Order History exposes receipt access for fulfilled paid orders' =
        $historyMarkup -match 'CanViewReceipt\(Eval\("Status"\)\)' -and
        $historyCode -match 'protected bool CanViewReceipt' -and
        $historyCode -match 'OrderStatuses\.Paid' -and
        $historyCode -match 'OrderStatuses\.Pending' -and
        $historyCode -match 'OrderStatuses\.Shipped' -and
        $historyCode -match 'OrderStatuses\.Delivered'
    'Customer status filters accept fulfillment statuses' =
        $historyCode -match 'value == OrderStatuses\.Shipped' -and
        $historyCode -match 'value == OrderStatuses\.Delivered' -and
        $orderService -match 'value == OrderStatuses\.Shipped' -and
        $orderService -match 'value == OrderStatuses\.Delivered'
    'Customer status badges style fulfillment statuses' =
        $historyCss -match '\.onyx-order-status\.status-shipped' -and
        $historyCss -match '\.onyx-order-status\.status-delivered'
    'Invoice lookup accepts fulfilled paid orders' =
        $orderRepository -match 'o\.status IN \(@PaidStatus, @PendingStatus, @ShippedStatus, @DeliveredStatus\)' -and
        $orderRepository -match '"@ShippedStatus"' -and
        $orderRepository -match '"@DeliveredStatus"'
}

$failures = @($checks.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) {
    throw ('Missing order fulfillment behavior: ' + (($failures | ForEach-Object Key) -join ', '))
}

Write-Host 'Order fulfillment status checks passed.'
