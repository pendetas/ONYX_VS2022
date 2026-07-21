$root = Split-Path $PSScriptRoot -Parent
$adminRegisterCodePath = "$root\auth_page\onyx_admin_register.aspx.cs"
$adminRegisterMarkupPath = "$root\auth_page\onyx_admin_register.aspx"
$adminLoginMarkupPath = "$root\auth_page\onyx_Admin_Login.aspx"
$gitIgnorePath = "$root\.gitignore"

$adminRegisterCode = Get-Content $adminRegisterCodePath -Raw
$adminRegisterMarkup = Get-Content $adminRegisterMarkupPath -Raw
$adminLoginMarkup = Get-Content $adminLoginMarkupPath -Raw
$gitIgnore = (Get-Content $gitIgnorePath -Raw) -replace "`r`n", "`n"

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

    'Admin login links to admin registration' =
        $adminLoginMarkup -match 'Don''t have an admin account\?' -and
        $adminLoginMarkup -match 'Register as an admin' -and
        $adminLoginMarkup -match 'ResolveUrl\s*\(\s*"~/auth_page/onyx_admin_register\.aspx"\s*\)'

    'Gitignore excludes local agent state and generated output' =
        $gitIgnore -match '(?m)^\.agents/$' -and
        $gitIgnore -match '(?m)^\.codex/$' -and
        $gitIgnore -match '(?m)^docs/$' -and
        $gitIgnore -match '(?m)^tests/$' -and
        $gitIgnore -match '(?m)^outputs/$' -and
        $gitIgnore -match '(?m)^\.env\.\*$'
}

$failures = @($checks.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) {
    throw ('Missing admin registration requirements: ' + (($failures | ForEach-Object Key) -join ', '))
}

Write-Output 'Admin registration source contract passes.'
