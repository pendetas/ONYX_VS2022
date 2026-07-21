$root = Split-Path $PSScriptRoot -Parent
$master = Get-Content "$root\admin_page\admin.Master" -Raw
$masterCode = Get-Content "$root\admin_page\admin.Master.cs" -Raw
$list = Get-Content "$root\admin_page\onyx_admin_promos.aspx" -Raw
$listCode = Get-Content "$root\admin_page\onyx_admin_promos.aspx.cs" -Raw
$form = if (Test-Path "$root\admin_page\onyx_admin_voucher_form.aspx") { Get-Content "$root\admin_page\onyx_admin_voucher_form.aspx" -Raw } else { '' }
$formCode = if (Test-Path "$root\admin_page\onyx_admin_voucher_form.aspx.cs") { Get-Content "$root\admin_page\onyx_admin_voucher_form.aspx.cs" -Raw } else { '' }
$voucherListRedirects = [regex]::Matches($formCode, 'Response\.Redirect\(\s*"onyx_admin_promos\.aspx",\s*false\s*\)').Count
$voucherListCompleteRequests = [regex]::Matches($formCode, 'Context\.ApplicationInstance\.CompleteRequest\(\s*\)').Count

$checks = [ordered]@{
    'Sidebar exposes Loyalty' = $master -match '>\s*Loyalty\s*</a>'
    'Voucher form keeps Loyalty active' = $masterCode -match 'onyx_admin_voucher_form\.aspx'
    'List is database-backed' = $listCode -match 'VoucherService' -and $listCode -notmatch 'mockPromos'
    'List supports server actions' = $list -match 'OnItemCommand="rptVouchers_ItemCommand"' -and $listCode -match 'rptVouchers_ItemCommand'
    'List uses ONYX monochrome theme' = $list -notmatch 'bootstrap' -and $list -notmatch '#00ff87|#a78bfa'
    'List has keyboard focus styles' = $list -match '\.primary-action:focus-visible' -and $list -match '\.actions (a|\.link-button):focus-visible'
    'List supports server-side search and status filtering' =
        $list -match 'ID="txtSearch"' -and
        $list -match 'ID="ddlStatusFilter"' -and
        $listCode -match 'GetAll\(\s*txtSearch\.Text\s*,\s*ddlStatusFilter\.SelectedValue\s*\)'
    'List renders empty-state and safe database-error states' =
        $list -match 'ID="pnlEmptyState"' -and
        $listCode -match 'pnlEmptyState\.Visible' -and
        $listCode -match 'The loyalty list is temporarily unavailable\.'
    'List hides unexpected action exceptions behind a safe message' =
        $listCode -match 'catch\s*\(InvalidOperationException\s+\w+\)' -and
        $listCode -match 'ShowError\(ex\.Message\)' -and
        $listCode -match 'Trace\.TraceError\("Voucher loyalty action failed: \{0\}"' -and
        $listCode -match 'The voucher action could not be completed\. Please refresh and try again\.'
    'Dedicated voucher form exists' = $form -match 'Voucher Details'
    'Voucher form has identity fields' = $form -match 'ID="txtName"' -and $form -match 'ID="txtCode"'
    'Voucher form has discount fields' = $form -match 'ID="ddlDiscountType"' -and $form -match 'ID="txtDiscountValue"' -and $form -match 'ID="txtMaximumDiscount"' -and $form -match 'ID="txtMinimumPurchase"'
    'Voucher form has category selection' = $form -match 'ID="chkAllCategories"' -and $form -match 'ID="cblCategories"'
    'Voucher form has validity and limits' = $form -match 'ID="txtValidFrom"' -and $form -match 'ID="txtExpiresAt"' -and $form -match 'ID="txtTotalLimit"' -and $form -match 'ID="txtPerUserLimit"'
    'Voucher form stores plain text terms' = $form -match 'ID="txtTerms"' -and $form -notmatch 'contenteditable|innerHTML'
    'Voucher form previews terms with textContent only' =
        $form -match 'data-terms-preview' -and
        $form -match 'textContent' -and
        $form -notmatch 'innerHTML'
    'Voucher form uses sticky action bar' = $form -match 'data-voucher-actions' -and $form -match 'position:\s*sticky'
    'Voucher form uses associated labels for key controls' = $form -match 'AssociatedControlID="txtName"' -and $form -match 'AssociatedControlID="txtCode"' -and $form -match 'AssociatedControlID="ddlDiscountType"' -and $form -match 'AssociatedControlID="chkIsActive"' -and $form -match 'AssociatedControlID="chkAllCategories"' -and $form -match 'AssociatedControlID="txtTerms"'
    'Voucher form has focus-visible treatment for fields and categories' = $form -match '\.field-input:focus-visible' -and $form -match '\.field-select:focus-visible' -and $form -match '\.field-textarea:focus-visible' -and $form -match '\.category-grid input:focus-visible'
    'Voucher form uses deterministic numeric parsing' = $formCode -match 'TryParseInvariantDecimal' -and $formCode -match 'MixedInvariantNumberPattern' -and $formCode -match 'InvariantThousandsPattern' -and $formCode -match 'InvariantCommaDecimalPattern'
    'Voucher redirects do not log successful saves as failures' =
        $formCode -notmatch 'Response\.Redirect\(\s*"onyx_admin_promos\.aspx",\s*true\s*\)' -and
        $voucherListRedirects -eq 3 -and
        $voucherListCompleteRequests -eq 3
    'Voucher subtitle avoids a redundant mode ternary' =
        $formCode -notmatch 'litPageSubtitle\.Text\s*=\s*IsEditMode\s*\?'
}

$failures = @($checks.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) { throw ('Missing voucher admin requirements: ' + (($failures | ForEach-Object Key) -join ', ')) }
Write-Output 'Voucher admin source contract passes.'
