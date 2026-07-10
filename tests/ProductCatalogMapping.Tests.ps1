$root = Split-Path $PSScriptRoot -Parent
$catalogCodePath = "$root\customer_page\onyx_catalog.aspx.cs"

$catalogCode = Get-Content $catalogCodePath -Raw

$checks = [ordered]@{
    'Catalog has a dedicated mousepad fallback image' =
        $catalogCode -match 'case\s+"Mousepad"\s*:\s*return\s+"/Content/uploads/products/product-21cdf7a0ce6341ba93ffd20ed2b0f7b4\.png"'

    'Catalog normalizes mousepad filter aliases' =
        $catalogCode -match 'case\s+"mousepad"\s*:' -and
        $catalogCode -match 'case\s+"mouse pad"\s*:' -and
        $catalogCode -match 'return\s+"Mousepad"'
}

$failures = @($checks.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) {
    throw ('Missing product catalog mapping requirements: ' + (($failures | ForEach-Object Key) -join ', '))
}

Write-Output 'Product catalog mapping source contract passes.'
