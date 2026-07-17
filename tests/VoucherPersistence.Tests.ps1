$root = Split-Path $PSScriptRoot -Parent
$repoPath = "$root\DAL\VoucherRepository.cs"
$servicePath = "$root\Services\VoucherService.cs"
$cartPath = "$root\Models\CartItem.cs"
$repo = if (Test-Path $repoPath) { Get-Content $repoPath -Raw } else { '' }
$service = if (Test-Path $servicePath) { Get-Content $servicePath -Raw } else { '' }
$cart = Get-Content $cartPath -Raw

$checks = [ordered]@{
    'Repository exposes admin CRUD' =
        $repo -match 'IList<Voucher>\s+GetAll\(' -and
        $repo -match 'Voucher\s+GetById\(' -and
        $repo -match 'long\s+Create\(' -and
        $repo -match 'void\s+Update\(' -and
        $repo -match 'void\s+SetActive\(' -and
        $repo -match 'void\s+Archive\('
    'Repository locks vouchers and counts active usage' =
        $repo -match 'LockByCode' -and $repo -match 'FOR UPDATE' -and
        $repo -match "status IN \(@PendingStatus, @RedeemedStatus\)"
    'Repository owns redemption lifecycle' =
        $repo -match 'ReserveRedemption' -and
        $repo -match 'RedeemForOrder' -and
        $repo -match 'ReleaseForOrder'
    'Service validates admin input and quotes checkout' =
        $service -match 'ValidateForSave' -and
        $service -match 'GetCheckoutQuote' -and
        $service -match 'VoucherCalculator\.Calculate'
    'Cart items carry authoritative category' = $cart -match 'string\s+Category'
    'SQL remains parameterized' = $repo -notmatch 'CommandText\s*=.*\+.*(code|Code|voucher|Voucher)'
}

$failures = @($checks.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) { throw ('Missing voucher persistence requirements: ' + (($failures | ForEach-Object Key) -join ', ')) }
Write-Output 'Voucher persistence source contract passes.'
