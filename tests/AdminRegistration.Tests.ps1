$root = Split-Path $PSScriptRoot -Parent
$adminRegisterCodePath = "$root\auth_page\onyx_admin_register.aspx.cs"
$adminRegisterMarkupPath = "$root\auth_page\onyx_admin_register.aspx"

$adminRegisterCode = Get-Content $adminRegisterCodePath -Raw
$adminRegisterMarkup = Get-Content $adminRegisterMarkupPath -Raw

$checks = [ordered]@{
    'Admin registration page does not require an existing admin session' =
        $adminRegisterCode -notmatch 'RequireAdmin\s*\(' -and
        $adminRegisterCode -notmatch 'Response\.Redirect\s*\(\s*"~/auth_page/onyx_Admin_Login\.aspx"'

    'Admin registration redirects already authenticated admins to dashboard' =
        $adminRegisterCode -match 'Session\["Role"\]' -and
        $adminRegisterCode -match '"admin"' -and
        $adminRegisterCode -match 'onyx_admin_dashboard\.aspx'

    'Admin registration still creates admin role accounts' =
        $adminRegisterCode -match 'Role\s*=\s*"admin"' -and
        $adminRegisterCode -match 'CreateUser\s*\(' -and
        $adminRegisterCode -match 'CheckDuplicate\s*\('

    'Admin registration form posts to register handler' =
        $adminRegisterMarkup -match 'OnClick="btnRegister_Click"' -and
        $adminRegisterMarkup -match 'Create Account'
}

$failures = @($checks.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) {
    throw ('Missing admin registration requirements: ' + (($failures | ForEach-Object Key) -join ', '))
}

Write-Output 'Admin registration source contract passes.'
