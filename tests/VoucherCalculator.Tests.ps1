$root = Split-Path $PSScriptRoot -Parent
$sources = @(
    "$root\Models\Voucher.cs",
    "$root\Models\VoucherQuote.cs",
    "$root\Services\VoucherCalculator.cs"
)

foreach ($source in $sources) {
    if (-not (Test-Path $source)) { throw "Missing calculator source: $source" }
}

Add-Type -Path $sources

function Assert-Decimal([decimal]$actual, [decimal]$expected, [string]$name) {
    if ($actual -ne $expected) { throw "$name expected $expected but got $actual" }
}

function Assert-True([bool]$condition, [string]$name) {
    if (-not $condition) { throw $name }
}

function Assert-Throws([scriptblock]$action, [string]$expectedMessage, [string]$name) {
    $thrown = $false
    try {
        & $action
    }
    catch {
        $thrown = $_.Exception.Message -match $expectedMessage
    }

    if (-not $thrown) {
        throw $name
    }
}

function New-Voucher([string]$type, [decimal]$value) {
    $voucher = [ONYX_DDAC.Models.Voucher]::new()
    $voucher.Id = 7
    $voucher.Name = 'Mouse Launch'
    $voucher.Code = 'MOUSE20'
    $voucher.DiscountType = $type
    $voucher.DiscountValue = $value
    $voucher.MinimumPurchaseAmount = 100
    $voucher.AppliesToAllCategories = $false
    $voucher.Categories.Add('Mouse')
    $voucher.ValidFrom = [DateTimeOffset]::Parse('2026-07-01T00:00:00Z')
    $voucher.ExpiresAt = [DateTimeOffset]::Parse('2026-08-01T00:00:00Z')
    $voucher.PerUserUsageLimit = 1
    $voucher.IsActive = $true
    $voucher.TermsAndConditions = 'Mouse products only.'
    return $voucher
}

$defaults = [ONYX_DDAC.Models.Voucher]::new()
Assert-True ($defaults.PerUserUsageLimit -eq 1) 'Voucher default per-user usage limit'
Assert-True ($defaults.IsActive) 'Voucher default active flag'
Assert-True ($defaults.AppliesToAllCategories) 'Voucher default category scope'

$lines = [System.Collections.Generic.List[ONYX_DDAC.Models.VoucherCartLine]]::new()
$lines.Add([ONYX_DDAC.Models.VoucherCartLine]@{ Category='Mouse'; UnitPrice=200; Quantity=1 })
$lines.Add([ONYX_DDAC.Models.VoucherCartLine]@{ Category='Keyboard'; UnitPrice=300; Quantity=1 })
$now = [DateTimeOffset]::Parse('2026-07-17T00:00:00Z')

$percentage = New-Voucher 'percentage' 20
$quote = [ONYX_DDAC.Services.VoucherCalculator]::Calculate($percentage, $lines, $now, 0, 0)
Assert-Decimal $quote.Subtotal 500 'Subtotal'
Assert-Decimal $quote.EligibleSubtotal 200 'Eligible subtotal'
Assert-Decimal $quote.DiscountAmount 40 'Category percentage discount'
Assert-Decimal $quote.TotalAmount 460 'Final total'

$roundLines = [System.Collections.Generic.List[ONYX_DDAC.Models.VoucherCartLine]]::new()
$roundLines.Add([ONYX_DDAC.Models.VoucherCartLine]@{ Category='mouse'; UnitPrice=0.10; Quantity=1 })
$roundVoucher = New-Voucher 'percentage' 5
$roundVoucher.MinimumPurchaseAmount = 0
$roundQuote = [ONYX_DDAC.Services.VoucherCalculator]::Calculate($roundVoucher, $roundLines, $now, 0, 0)
Assert-Decimal $roundQuote.DiscountAmount 0.01 'Away-from-zero rounding'

$percentage.MaximumDiscountAmount = 25
$capped = [ONYX_DDAC.Services.VoucherCalculator]::Calculate($percentage, $lines, $now, 0, 0)
Assert-Decimal $capped.DiscountAmount 25 'Percentage cap'

$fixed = New-Voucher 'fixed' 250
$fixedQuote = [ONYX_DDAC.Services.VoucherCalculator]::Calculate($fixed, $lines, $now, 0, 0)
Assert-Decimal $fixedQuote.DiscountAmount 200 'Fixed discount eligible-subtotal cap'

$negativePercentage = New-Voucher 'percentage' -1
Assert-Throws { [ONYX_DDAC.Services.VoucherCalculator]::Calculate($negativePercentage, $lines, $now, 0, 0) } 'invalid discount value' 'Negative percentage discount should fail closed'

$tooLargePercentage = New-Voucher 'percentage' 101
Assert-Throws { [ONYX_DDAC.Services.VoucherCalculator]::Calculate($tooLargePercentage, $lines, $now, 0, 0) } 'invalid discount value' 'Percentage above 100 should fail closed'

$invalidFixed = New-Voucher 'fixed' 0
Assert-Throws { [ONYX_DDAC.Services.VoucherCalculator]::Calculate($invalidFixed, $lines, $now, 0, 0) } 'invalid discount value' 'Zero fixed discount should fail closed'

$invalidCap = New-Voucher 'percentage' 10
$invalidCap.MaximumDiscountAmount = 0
Assert-Throws { [ONYX_DDAC.Services.VoucherCalculator]::Calculate($invalidCap, $lines, $now, 0, 0) } 'invalid maximum discount amount' 'Non-positive cap should fail closed'

$failed = $false
try { [ONYX_DDAC.Services.VoucherCalculator]::Calculate($percentage, $lines, $now, 0, 1) } catch { $failed = $_.Exception.Message -match 'already used' }
if (-not $failed) { throw 'Per-user usage limit was not enforced.' }

Write-Output 'Voucher calculator behavior passes.'
