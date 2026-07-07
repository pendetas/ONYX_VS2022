$root = Split-Path $PSScriptRoot -Parent
$callback = Get-Content "$root\auth_page\oauth_callback.aspx.cs" -Raw

$isExpectedStateStart = $callback.IndexOf('private bool IsExpectedState')
$getCodeVerifierStart = $callback.IndexOf('private string GetCodeVerifier')
if ($isExpectedStateStart -lt 0 -or $getCodeVerifierStart -lt 0 -or $getCodeVerifierStart -le $isExpectedStateStart) {
    throw 'Could not locate OAuth callback state and PKCE helper methods.'
}

$isExpectedStateBody = $callback.Substring($isExpectedStateStart, $getCodeVerifierStart - $isExpectedStateStart)

$requirements = [ordered]@{
    'State validation does not remove PKCE verifier before token exchange' =
        $isExpectedStateBody -notmatch 'GetCodeVerifierSessionKey'
    'Callback removes PKCE verifier after reading it' =
        $callback -match 'string\s+codeVerifier\s*=\s*GetCodeVerifier\(provider,\s*actualState\);[\s\S]*RemoveCodeVerifier\(provider,\s*actualState\);'
}

$failures = @($requirements.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) {
    throw ('Missing OAuth PKCE callback requirements: ' + (($failures | ForEach-Object Key) -join ', '))
}

Write-Output 'OAuth callback PKCE source contract passes.'
