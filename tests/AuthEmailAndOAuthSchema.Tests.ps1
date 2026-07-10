$root = Split-Path $PSScriptRoot -Parent
$authService = Get-Content "$root\Services\AuthService.cs" -Raw
$emailService = Get-Content "$root\Services\EmailService.cs" -Raw
$userRepository = Get-Content "$root\DAL\UserRepository.cs" -Raw
$loginCodeBehind = Get-Content "$root\auth_page\onyx_login.aspx.cs" -Raw
$googleCallback = Get-Content "$root\auth_page\google_callback.aspx.cs" -Raw
$oauthCallback = Get-Content "$root\auth_page\oauth_callback.aspx.cs" -Raw
$schema = Get-Content "$root\App_Data\onyx_schema.sql" -Raw
$googleOAuthMigration = Get-Content "$root\App_Data\20260702_google_oauth.sql" -Raw
$rateLimitMigrationPath = "$root\App_Data\20260709_auth_rate_limits_schema.sql"
$rateLimitMigration = if (Test-Path $rateLimitMigrationPath) { Get-Content $rateLimitMigrationPath -Raw } else { '' }
$usersTable = [regex]::Match($schema, 'CREATE TABLE users \([\s\S]*?\);').Value
$rateLimitTable = [regex]::Match($schema, 'CREATE TABLE auth_rate_limits \([\s\S]*?\);').Value

$requirements = [ordered]@{
    'Login alerts use email service' =
        $emailService -match 'SendLoginDetectedAsync\s*\(' -and
        $authService -match 'QueueLoginDetectedNotice\s*\('

    'Customer password login queues login alert before redirect' =
        $loginCodeBehind -match 'QueueLoginDetectedNotice\s*\(' -and
        $loginCodeBehind -match 'BuildForgotPasswordUrl\s*\('

    'OAuth login queues login alert for existing and created users' =
        $googleCallback -match 'QueueLoginDetectedNotice\s*\(' -and
        $oauthCallback -match 'QueueLoginDetectedNotice\s*\('

    'Users schema does not keep duplicated OAuth columns' =
        $usersTable -notmatch 'auth_provider' -and
        $usersTable -notmatch 'google_sub' -and
        $usersTable -notmatch 'google_email_verified' -and
        $usersTable -notmatch 'avatar_url' -and
        $schema -notmatch 'ux_users_google_sub' -and
        $googleOAuthMigration -notmatch 'ADD COLUMN IF NOT EXISTS auth_provider' -and
        $googleOAuthMigration -notmatch 'ADD COLUMN IF NOT EXISTS google_sub' -and
        $googleOAuthMigration -notmatch 'ux_users_google_sub'

    'Repository uses user_oauth_accounts as OAuth source of truth' =
        $userRepository -notmatch 'GetUserByGoogleSub' -and
        $userRepository -notmatch 'UPDATE\s+users[\s\S]*auth_provider' -and
        $userRepository -match 'GetUserByOAuthAccount\s*\(' -and
        $userRepository -match 'UpsertOAuthAccount\s*\('

    'Auth rate limit schema matches AuthService upsert contract' =
        $authService -match 'INSERT INTO auth_rate_limits\s*\r?\n\s*\(action, identity_key, attempt_count, window_started_at, blocked_until, last_attempt_at\)' -and
        $authService -match 'ON CONFLICT \(action, identity_key\)' -and
        $rateLimitTable -match 'action VARCHAR\(50\) NOT NULL' -and
        $rateLimitTable -match 'identity_key VARCHAR\(320\) NOT NULL' -and
        $rateLimitTable -match 'attempt_count INTEGER NOT NULL DEFAULT 0 CHECK \(attempt_count >= 0\)' -and
        $rateLimitTable -match 'window_started_at TIMESTAMP NOT NULL' -and
        $rateLimitTable -match 'blocked_until TIMESTAMP' -and
        $rateLimitTable -match 'last_attempt_at TIMESTAMP NOT NULL' -and
        $rateLimitTable -match 'UNIQUE \(action, identity_key\)'

    'Local auth rate limit repair migration drops incompatible old columns' =
        $rateLimitMigration -match 'DROP TABLE IF EXISTS public\.auth_rate_limits' -and
        $rateLimitMigration -match 'CREATE TABLE public\.auth_rate_limits' -and
        $rateLimitMigration -match 'UNIQUE \(action, identity_key\)' -and
        $rateLimitMigration -match 'CREATE INDEX ix_auth_rate_limits_blocked_until' -and
        $rateLimitMigration -notmatch '\bscope\b' -and
        $rateLimitMigration -notmatch '\bidentifier\b' -and
        $rateLimitMigration -notmatch '\bwindow_start\b' -and
        $rateLimitMigration -notmatch '\blocked_until\b'
}

$failures = @($requirements.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) {
    throw ('Missing auth email/schema requirements: ' + (($failures | ForEach-Object Key) -join ', '))
}

Write-Output 'Auth email and OAuth schema source contract passes.'
