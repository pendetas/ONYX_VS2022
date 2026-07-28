$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$servicePath = Join-Path $repoRoot 'Services/OpenAiAssistantService.cs'
$handlerPath = Join-Path $repoRoot 'customer_page/onyx_ai_chat.ashx.cs'
$webConfigPath = Join-Path $repoRoot 'Web.config'
$openAiSmokePath = Join-Path $repoRoot 'Scripts/test-openai-live-smoke.ps1'
$legacyGeminiSmokePath = Join-Path $repoRoot 'Scripts/test-gemini-live-smoke.ps1'

if (-not (Test-Path $servicePath)) {
    throw 'OpenAI assistant service is missing.'
}

if (-not (Test-Path $openAiSmokePath) -or (Test-Path $legacyGeminiSmokePath)) {
    throw 'The live smoke test must be migrated from Gemini to OpenAI.'
}

$service = Get-Content -Raw -Path $servicePath
$handler = Get-Content -Raw -Path $handlerPath
$webConfig = Get-Content -Raw -Path $webConfigPath

if ($handler -notmatch 'OpenAiAssistantService') {
    throw 'Chat handler must use the OpenAI assistant service.'
}

if ($service -match 'Google\.GenAI|GenerateContentAsync|GEMINI_API_KEY|GeminiApiKey') {
    throw 'OpenAI assistant service must not retain Gemini provider calls or configuration.'
}

if ($service -notmatch 'OPENAI_API_KEY' -or $service -notmatch 'OpenAIApiKey') {
    throw 'OpenAI assistant service must read OPENAI_API_KEY with an OpenAIApiKey local fallback.'
}

if ($service -notmatch 'OPENAI_MODEL' -or $service -notmatch 'OpenAIModel') {
    throw 'OpenAI assistant service must allow OPENAI_MODEL to override the configured model.'
}

if ($service -notmatch 'https://api\.openai\.com/v1/responses' -or $service -notmatch 'AuthenticationHeaderValue\("Bearer"') {
    throw 'OpenAI assistant service must call the authenticated Responses API endpoint.'
}

if ($service -notmatch 'BuildOrderTrackingResult' -or $service -notmatch 'IsOrderTrackingIntent') {
    throw 'Order history must remain a direct server-side route.'
}

if ($service -notmatch 'GetRelevantContext' -or $service -notmatch 'BuildSystemInstruction') {
    throw 'OpenAI requests must retain ONYX knowledge context and guardrails.'
}

if ($webConfig -notmatch 'key="OpenAIModel"' -or $webConfig -notmatch 'key="OpenAIApiKey"') {
    throw 'Web.config must contain OpenAI model and local-key placeholders.'
}

Write-Host 'OpenAI AI workflow checks passed.'
