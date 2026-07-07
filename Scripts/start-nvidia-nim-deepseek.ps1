$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$localConfigPath = Join-Path $repoRoot 'AppSettings.Local.config'

if (-not (Test-Path $localConfigPath)) {
    throw 'AppSettings.Local.config was not found. Add NvidiaApiKey before starting local NIM.'
}

$settings = [xml](Get-Content -Raw -Path $localConfigPath)
$apiKeyNode = $settings.appSettings.add | Where-Object { $_.key -eq 'NvidiaApiKey' } | Select-Object -First 1

if (-not $apiKeyNode -or [string]::IsNullOrWhiteSpace($apiKeyNode.value)) {
    throw 'NvidiaApiKey is missing from AppSettings.Local.config.'
}

$env:NGC_API_KEY = $apiKeyNode.value
$localNimCache = Join-Path $env:USERPROFILE '.cache\nim'

New-Item -ItemType Directory -Force -Path $localNimCache | Out-Null

Write-Host 'Logging in to nvcr.io with $oauthtoken...'
$env:NGC_API_KEY | docker login nvcr.io --username '$oauthtoken' --password-stdin

Write-Host 'Starting NVIDIA NIM DeepSeek on http://localhost:8000 ...'
docker run -it --rm `
    --gpus all `
    --shm-size=16GB `
    -e NGC_API_KEY `
    -v "${localNimCache}:/opt/nim/.cache" `
    -p 8000:8000 `
    nvcr.io/nim/deepseek-ai/deepseek-v4-pro:latest
