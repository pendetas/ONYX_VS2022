$root = Split-Path $PSScriptRoot -Parent
$confirmation = Get-Content "$root\customer_page\onyx_payment_confirmation.aspx.cs" -Raw
$emailService = Get-Content "$root\Services\EmailService.cs" -Raw
$orderService = Get-Content "$root\Services\OrderService.cs" -Raw
$orderRepository = Get-Content "$root\DAL\OrderRepository.cs" -Raw
$schema = Get-Content "$root\App_Data\onyx_schema.sql" -Raw
$stripeMigration = Get-Content "$root\App_Data\stripe_checkout_migration.sql" -Raw

$requirements = [ordered]@{
    'Payment confirmation still redirects to website invoice page' =
        $confirmation -match 'onyx_invoice\.aspx\?orderId='

    'Paid payment confirmation sends checkout success email' =
        $confirmation -match 'SendCheckoutSuccessEmailOnce\s*\('

    'Order service gates checkout success email once' =
        $orderService -match 'SendCheckoutSuccessEmailOnce\s*\(' -and
        $orderService -match 'TryMarkCheckoutSuccessEmailSent\s*\(' -and
        $orderService -match 'ClearCheckoutSuccessEmailSent\s*\('

    'Email service has checkout success invoice email' =
        $emailService -match 'SendCheckoutSuccessAsync\s*\(' -and
        $emailService -match 'BuildCheckoutSuccessHtmlBody\s*\(' -and
        $emailService -match 'Official Digital Receipt'

    'Order repository stores checkout success email sent marker' =
        $orderRepository -match 'TryMarkCheckoutSuccessEmailSent\s*\(' -and
        $orderRepository -match 'ClearCheckoutSuccessEmailSent\s*\(' -and
        $orderRepository -match 'checkout_success_email_sent_at'

    'Schema includes checkout success email sent marker' =
        $schema -match 'checkout_success_email_sent_at TIMESTAMPTZ' -and
        $stripeMigration -match 'checkout_success_email_sent_at TIMESTAMPTZ'
}

$failures = @($requirements.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) {
    throw ('Missing checkout success email requirements: ' + (($failures | ForEach-Object Key) -join ', '))
}

Write-Output 'Checkout success email source contract passes.'
