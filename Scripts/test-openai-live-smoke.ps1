$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$webConfigPath = Join-Path $repoRoot 'Web.config'
$localConfigPath = Join-Path $repoRoot 'AppSettings.Local.config'

[xml]$webConfig = Get-Content -Raw -Path $webConfigPath
$apiKey = [Environment]::GetEnvironmentVariable('OPENAI_API_KEY')
if ([string]::IsNullOrWhiteSpace($apiKey)) {
    $apiKeyNode = $webConfig.configuration.appSettings.add | Where-Object { $_.key -eq 'OpenAIApiKey' } | Select-Object -First 1
    if ($apiKeyNode) {
        $apiKey = $apiKeyNode.value
    }
}
if ([string]::IsNullOrWhiteSpace($apiKey) -and (Test-Path $localConfigPath)) {
    [xml]$localConfig = Get-Content -Raw -Path $localConfigPath
    $apiKeyNode = $localConfig.appSettings.add | Where-Object { $_.key -eq 'OpenAIApiKey' } | Select-Object -First 1
    if ($apiKeyNode) {
        $apiKey = $apiKeyNode.value
    }
}

if ([string]::IsNullOrWhiteSpace($apiKey)) {
    throw 'OpenAI live smoke test needs OPENAI_API_KEY or OpenAIApiKey.'
}

$model = [Environment]::GetEnvironmentVariable('OPENAI_MODEL')
if ([string]::IsNullOrWhiteSpace($model)) {
    $modelNode = $webConfig.configuration.appSettings.add | Where-Object { $_.key -eq 'OpenAIModel' } | Select-Object -First 1
    $model = if ($modelNode -and -not [string]::IsNullOrWhiteSpace($modelNode.value)) { $modelNode.value } else { 'gpt-5.6-luna' }
}
if (([string]::IsNullOrWhiteSpace($model) -or $model -eq 'gpt-5.6-luna') -and (Test-Path $localConfigPath)) {
    [xml]$localConfig = Get-Content -Raw -Path $localConfigPath
    $modelNode = $localConfig.appSettings.add | Where-Object { $_.key -eq 'OpenAIModel' } | Select-Object -First 1
    if ($modelNode -and -not [string]::IsNullOrWhiteSpace($modelNode.value)) {
        $model = $modelNode.value
    }
}

$body = @{
    model = $model
    input = 'Reply with exactly ONYX_SMOKE_OK.'
    max_output_tokens = 128
    reasoning = @{ effort = 'low' }
    text = @{ verbosity = 'low' }
} | ConvertTo-Json -Depth 8

$uri = 'https://api.openai.com/v1/responses'
$response = $null
for ($attempt = 1; $attempt -le 3; $attempt++) {
    try {
        $response = Invoke-RestMethod -Method Post -Uri $uri -Headers @{ Authorization = "Bearer $apiKey" } -ContentType 'application/json' -Body $body -TimeoutSec 30
        break
    } catch {
        if ($attempt -eq 3) {
            throw
        }

        Start-Sleep -Seconds (2 * $attempt)
    }
}
$text = $response.output |
    ForEach-Object { $_.content } |
    Where-Object { $_.type -eq 'output_text' } |
    Select-Object -ExpandProperty text -First 1
$text = if ($text) { $text.Trim() } else { '' }

if ($text -notmatch 'ONYX_SMOKE_OK') {
    throw "OpenAI live smoke test returned unexpected text: $text"
}

Write-Host "OpenAI live smoke test passed on $model."
