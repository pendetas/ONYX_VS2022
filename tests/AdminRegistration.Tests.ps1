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
    'Admin registration requires an existing admin session' =
        $adminRegisterCode -match 'AuthHelper\.RequireAdmin\s*\(\s*this\s*\)'

    'Admin login does not expose unrestricted admin registration' =
        $adminLoginMarkup -notmatch 'onyx_admin_register\.aspx'

    'Admin registration still creates admin role accounts' =
        $adminRegisterCode -match 'Role\s*=\s*"admin"' -and
        $adminRegisterCode -match 'CreateUser\s*\(' -and
        $adminRegisterCode -match 'CheckDuplicate\s*\('

    'Admin registration form posts to register handler' =
        $adminRegisterMarkup -match 'OnClick="btnRegister_Click"' -and
        $adminRegisterMarkup -match 'Create Account'

    'Gitignore preserves repository docs and tests while ignoring local output' =
        $gitIgnore -match '(?m)^\.agents/$' -and
        $gitIgnore -match '(?m)^\.codex/$' -and
        $gitIgnore -notmatch '(?m)^docs/$' -and
        $gitIgnore -notmatch '(?m)^tests/$' -and
        $gitIgnore -match '(?m)^tmp/$' -and
        $gitIgnore -match '(?m)^outputs/$' -and
        $gitIgnore -match '(?m)^\.env\.\*$'
}

$failures = @($checks.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) {
    throw ('Missing admin registration requirements: ' + (($failures | ForEach-Object Key) -join ', '))
}

Write-Output 'Admin registration source contract passes.'
