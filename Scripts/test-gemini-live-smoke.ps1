$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$webConfigPath = Join-Path $repoRoot 'Web.config'

[xml]$webConfig = Get-Content -Raw -Path $webConfigPath
$apiKey = [Environment]::GetEnvironmentVariable('GEMINI_API_KEY')
if ([string]::IsNullOrWhiteSpace($apiKey)) {
    $apiKeyNode = $webConfig.configuration.appSettings.add | Where-Object { $_.key -eq 'GeminiApiKey' } | Select-Object -First 1
    if ($apiKeyNode) {
        $apiKey = $apiKeyNode.value
    }
}

if ([string]::IsNullOrWhiteSpace($apiKey)) {
    throw 'Gemini live smoke test needs GEMINI_API_KEY or GeminiApiKey.'
}

$modelNode = $webConfig.configuration.appSettings.add | Where-Object { $_.key -eq 'GeminiModel' } | Select-Object -First 1
$model = if ($modelNode -and -not [string]::IsNullOrWhiteSpace($modelNode.value)) { $modelNode.value } else { 'gemini-3.5-flash' }

$body = @{
    contents = @(
        @{
            parts = @(
                @{ text = 'Reply with exactly ONYX_SMOKE_OK.' }
            )
        }
    )
    generationConfig = @{
        temperature = 0
        maxOutputTokens = 128
    }
} | ConvertTo-Json -Depth 8

$uri = "https://generativelanguage.googleapis.com/v1beta/models/$model`:generateContent"
$response = Invoke-RestMethod -Method Post -Uri $uri -Headers @{ 'x-goog-api-key' = $apiKey } -ContentType 'application/json' -Body $body
$text = $response.candidates[0].content.parts[0].text.Trim()

if ($text -notmatch 'ONYX_SMOKE_OK') {
    throw "Gemini live smoke test returned unexpected text: $text"
}

Write-Host "Gemini live smoke test passed on $model."
