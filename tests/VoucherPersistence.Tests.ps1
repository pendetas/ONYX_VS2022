$root = Split-Path $PSScriptRoot -Parent
$repoPath = "$root\DAL\VoucherRepository.cs"
$cartRepoPath = "$root\DAL\CartRepository.cs"
$checkoutRepoPath = "$root\DAL\CheckoutRepository.cs"
$servicePath = "$root\Services\VoucherService.cs"
$cartPath = "$root\Models\CartItem.cs"
$repo = if (Test-Path $repoPath) { Get-Content $repoPath -Raw } else { '' }
$cartRepo = Get-Content $cartRepoPath -Raw
$checkoutRepo = Get-Content $checkoutRepoPath -Raw
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
    'Cart and checkout hydrate authoritative category' =
        $cartRepo -match 'p\.category' -and
        $cartRepo -match 'Category\s*=\s*reader\.GetString\(reader\.GetOrdinal\("category"\)\)' -and
        $checkoutRepo -match 'p\.category\s+AS\s+product_category' -and
        $checkoutRepo -notmatch 'p\.category\s*,\s*p\.category\s+AS\s+product_category' -and
        $checkoutRepo -match 'Category\s*=\s*reader\.GetString\(reader\.GetOrdinal\("product_category"\)\)' -and
        $checkoutRepo -notmatch 'Category\s*=\s*reader\.GetString\(reader\.GetOrdinal\("category"\)\)' -and
        $checkoutRepo -match 'Category\s*=\s*item\.Category'
    'Checkout locks voucher before reservation' =
        $checkoutRepo -match 'VoucherRepository\.LockByCode' -and
        $checkoutRepo -match 'VoucherRepository\.ReserveRedemption'
    'Checkout stores subtotal discount and voucher snapshots' =
        $checkoutRepo -match 'subtotal_amount' -and
        $checkoutRepo -match 'discount_amount' -and
        $checkoutRepo -match 'voucher_code' -and
        $checkoutRepo -match 'voucher_name'
    'Checkout recalculates inside transaction' =
        $checkoutRepo -match 'VoucherCalculator\.Calculate'
    'Repository filters category hydration to requested vouchers' =
        $repo -match 'WHERE voucher_id = ANY\s*\(@VoucherIds\)' -and
        $repo -match '@VoucherIds'
    'Repository validates selected categories against authoritative product categories inside the save transaction' =
        $repo -match 'ValidateCategoriesForSave' -and
        $repo -match 'SELECT DISTINCT category' -and
        $repo -match 'FROM products' -and
        $repo -match 'tx' -and
        $repo -match 'Unknown voucher category selected'
    'All-categories vouchers skip category persistence safely' =
        $repo -match 'if \(voucher == null \|\| voucher\.AppliesToAllCategories\)' -and
        $repo -match 'return;'
    'SQL remains parameterized' = $repo -notmatch 'CommandText\s*=.*\+.*(code|Code|voucher|Voucher)'
}

$failures = @($checks.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) { throw ('Missing voucher persistence requirements: ' + (($failures | ForEach-Object Key) -join ', ')) }
Write-Output 'Voucher persistence source contract passes.'
