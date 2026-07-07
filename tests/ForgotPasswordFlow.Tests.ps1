$root = Split-Path $PSScriptRoot -Parent
$forgotMarkup = Get-Content "$root\auth_page\onyx_forgotpassword.aspx" -Raw
$forgotCodeBehind = Get-Content "$root\auth_page\onyx_forgotpassword.aspx.cs" -Raw
$authService = Get-Content "$root\Services\AuthService.cs" -Raw
$emailService = Get-Content "$root\Services\EmailService.cs" -Raw
$userRepository = Get-Content "$root\DAL\UserRepository.cs" -Raw
$resetSqlPath = "$root\App_Data\20260704_password_reset_tokens.sql"

$requirements = [ordered]@{
    'Forgot password page enables async postbacks' =
        $forgotMarkup -match '<%@\s+Page[\s\S]*\sAsync="true"'

    'Forgot password postback uses PageAsyncTask' =
        $forgotCodeBehind -match 'protected\s+void\s+ResetButton_Click\s*\([^)]*\)' -and
        $forgotCodeBehind -match 'RegisterAsyncTask\s*\(\s*new\s+PageAsyncTask\s*\(\s*RequestResetAsync\s*\)\s*\)' -and
        $forgotCodeBehind -match 'private\s+async\s+Task\s+RequestResetAsync\s*\('

    'Forgot password page requests a manual account password reset' =
        $forgotCodeBehind -match 'RequestPasswordResetAsync\s*\(' -and
        $forgotCodeBehind -match 'BuildResetPasswordUrl\s*\('

    'Auth service looks up the account and sends reset instructions' =
        $authService -match 'Task\s+RequestPasswordResetAsync\s*\(' -and
        $authService -match 'GetUserByEmail\s*\(' -and
        $authService -match 'CreatePasswordResetToken\s*\(' -and
        $authService -match 'SendPasswordResetAsync\s*\(' -and
        $authService -match 'password_reset_failed'

    'Reset requests skip OAuth-only accounts without a local password hash' =
        $authService -match 'string\.IsNullOrWhiteSpace\s*\(\s*user\.PasswordHash\s*\)'

    'Repository persists reset token hashes, not raw tokens' =
        $userRepository -match 'CreatePasswordResetToken\s*\(' -and
        $userRepository -match 'token_hash' -and
        $userRepository -notmatch 'raw_token'

    'Repository uses database time for reset token expiry checks' =
        $userRepository -match "NOW\(\)\s*\+\s*\(@ExpiryMinutes\s*\*\s*INTERVAL\s+'1 minute'\)" -and
        $userRepository -match 'expires_at\s*>\s*NOW\(\)'

    'Email service has a password reset email method' =
        $emailService -match 'SendPasswordResetAsync\s*\('

    'Password reset token schema migration exists' =
        (Test-Path $resetSqlPath) -and
        ((Get-Content $resetSqlPath -Raw) -match 'password_reset_tokens') -and
        ((Get-Content $resetSqlPath -Raw) -match 'token_hash')
}

$failures = @($requirements.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) {
    throw ('Missing forgot password flow requirements: ' + (($failures | ForEach-Object Key) -join ', '))
}

Write-Output 'Forgot password flow source contract passes.'
