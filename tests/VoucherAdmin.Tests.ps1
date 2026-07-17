$root = Split-Path $PSScriptRoot -Parent
$master = Get-Content "$root\admin_page\admin.Master" -Raw
$masterCode = Get-Content "$root\admin_page\admin.Master.cs" -Raw
$list = Get-Content "$root\admin_page\onyx_admin_promos.aspx" -Raw
$listCode = Get-Content "$root\admin_page\onyx_admin_promos.aspx.cs" -Raw

$checks = [ordered]@{
    'Sidebar exposes Loyalty' = $master -match '>\s*Loyalty\s*</a>'
    'Voucher form keeps Loyalty active' = $masterCode -match 'onyx_admin_voucher_form\.aspx'
    'List is database-backed' = $listCode -match 'VoucherService' -and $listCode -notmatch 'mockPromos'
    'List supports server actions' = $list -match 'OnItemCommand="rptVouchers_ItemCommand"' -and $listCode -match 'rptVouchers_ItemCommand'
    'List uses ONYX monochrome theme' = $list -notmatch 'bootstrap' -and $list -notmatch '#00ff87|#a78bfa'
}

$failures = @($checks.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) { throw ('Missing voucher admin requirements: ' + (($failures | ForEach-Object Key) -join ', ')) }
Write-Output 'Voucher admin source contract passes.'
