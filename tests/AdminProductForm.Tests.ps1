$root = Split-Path $PSScriptRoot -Parent
$markupPath = "$root\admin_page\onyx_admin_products_form.aspx"
$codePath = "$root\admin_page\onyx_admin_products_form.aspx.cs"
$designerPath = "$root\admin_page\onyx_admin_products_form.aspx.designer.cs"

$markup = Get-Content $markupPath -Raw
$code = Get-Content $codePath -Raw
$designer = Get-Content $designerPath -Raw

$checks = [ordered]@{
    'Admin product form offers restricted image upload' =
        $markup -match 'ProductImageUpload' -and
        $markup -match 'accept="\.jpg,\.jpeg,\.png,image/jpeg,image/png"' -and
        $designer -match 'FileUpload\s+ProductImageUpload' -and
        $code -match 'SaveUploadedProductImage' -and
        $code -match '\.jpg' -and
        $code -match '\.jpeg' -and
        $code -match '\.png'

    'Admin product form locks brand to ONYX' =
        $markup -match 'Text="ONYX"' -and
        $markup -match 'ReadOnly="true"' -and
        $code -match 'const string LockedBrand = "ONYX"' -and
        $code -match 'string brand\s*=\s*LockedBrand'

    'Admin product form exposes expanded ONYX categories' =
        $markup -match 'Value="Mic"' -and
        $markup -match 'Value="Monitor Extension"' -and
        $markup -match 'Value="Accessory"' -and
        $markup -match 'Value="Mousepad"' -and
        $markup -match 'Value="Cable"'

    'Admin product form supports color choices while creating products' =
        $markup -match 'CreateColorChoices' -and
        $designer -match 'CheckBoxList\s+CreateColorChoices' -and
        $code -match 'BindCreateColorChoices' -and
        $code -match 'CreateColorVariantsForNewProduct' -and
        $code -match 'GetSelectedCreateColors'

    'New product save appends color variants after product creation' =
        $code -match 'long newId = _svc\.CreateProduct' -and
        $code -match 'CreateColorVariantsForNewProduct\s*\(\s*newId\s*,\s*price\s*,\s*stock\s*\)' -and
        $code -match '_svc\.AddVariant\s*\(\s*productId\s*,\s*"Color"'
}

$failures = @($checks.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) {
    throw ('Missing admin product form requirements: ' + (($failures | ForEach-Object Key) -join ', '))
}

Write-Output 'Admin product form source contract passes.'
