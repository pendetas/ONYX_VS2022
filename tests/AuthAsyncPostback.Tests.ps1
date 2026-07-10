$root = Split-Path $PSScriptRoot -Parent
$login = Get-Content "$root\auth_page\onyx_login.aspx.cs" -Raw
$register = Get-Content "$root\auth_page\onyx_register.aspx.cs" -Raw

$requirements = [ordered]@{
    'Login postback handler is registered through PageAsyncTask' =
        $login -match 'protected\s+void\s+LoginButton_Click\s*\([^)]*\)' -and
        $login -match 'RegisterAsyncTask\s*\(\s*new\s+PageAsyncTask\s*\(\s*LoginAsync\s*\)\s*\)' -and
        $login -match 'private\s+async\s+Task\s+LoginAsync\s*\(' -and
        $login -notmatch 'protected\s+async\s+void\s+LoginButton_Click'

    'Register postback handler is registered through PageAsyncTask' =
        $register -match 'protected\s+void\s+btnRegister_Click\s*\([^)]*\)' -and
        $register -match 'RegisterAsyncTask\s*\(\s*new\s+PageAsyncTask\s*\(\s*RegisterAsync\s*\)\s*\)' -and
        $register -match 'private\s+async\s+Task\s+RegisterAsync\s*\(' -and
        $register -notmatch 'protected\s+async\s+void\s+btnRegister_Click'
}

$failures = @($requirements.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) {
    throw ('Missing auth async postback requirements: ' + (($failures | ForEach-Object Key) -join ', '))
}

Write-Output 'Auth async postback source contract passes.'
