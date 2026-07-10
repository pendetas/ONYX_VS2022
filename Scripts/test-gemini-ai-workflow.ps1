$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$projectPath = Join-Path $repoRoot 'ONYX_DDAC.csproj'
$packagesPath = Join-Path $repoRoot 'packages.config'
$webConfigPath = Join-Path $repoRoot 'Web.config'
$handlerPath = Join-Path $repoRoot 'customer_page/onyx_ai_chat.ashx.cs'
$servicesPath = Join-Path $repoRoot 'Services'

$project = Get-Content -Raw -Path $projectPath
$packages = if (Test-Path $packagesPath) { Get-Content -Raw -Path $packagesPath } else { '' }
$webConfig = Get-Content -Raw -Path $webConfigPath
$handler = Get-Content -Raw -Path $handlerPath
$serviceText = (Get-ChildItem -Path $servicesPath -Filter '*.cs' | ForEach-Object { Get-Content -Raw -Path $_.FullName }) -join "`n"
$assistantService = Get-Content -Raw -Path (Join-Path $servicesPath 'GeminiAssistantService.cs')
$knowledgeService = Get-Content -Raw -Path (Join-Path $servicesPath 'OnyxKnowledgeService.cs')

if ($packages -notmatch 'Google\.GenAI' -and $project -notmatch 'Google\.GenAI') {
    throw 'Gemini workflow must use the official Google.GenAI SDK package.'
}

if ($serviceText -notmatch 'using\s+Google\.GenAI' -or $serviceText -notmatch 'using\s+Google\.GenAI\.Types') {
    throw 'Gemini assistant service must import Google.GenAI and Google.GenAI.Types.'
}

if ($serviceText -notmatch 'gemini-2\.5-flash' -or $webConfig -notmatch 'gemini-2\.5-flash') {
    throw 'Gemini workflow must default to model gemini-2.5-flash.'
}

if ($serviceText -notmatch 'GEMINI_API_KEY' -or $assistantService -notmatch 'ConfigurationManager\.AppSettings\["GeminiApiKey"\]') {
    throw 'Gemini workflow must read the Google AI Studio key from GEMINI_API_KEY or GeminiApiKey.'
}

if ($webConfig -notmatch 'appSettings\s+file="AppSettings\.Local\.config"') {
    throw 'Web.config must load ignored AppSettings.Local.config overrides for local secrets.'
}

if ($handler -match 'OpenRouterAssistantService') {
    throw 'Chat handler must use the Gemini assistant service, not OpenRouterAssistantService.'
}

if ($handler -notmatch 'HttpTaskAsyncHandler' -or $handler -match 'GetAwaiter\(\)\s*\.\s*GetResult\(\)') {
    throw 'Chat handler must await Gemini asynchronously instead of blocking the ASP.NET request thread.'
}

if ($serviceText -match 'OpenRouter' -or $webConfig -match 'OpenRouter') {
    throw 'Gemini workflow must remove OpenRouter provider names from active service and appSettings.'
}

if ($serviceText -notmatch 'GetRelevantContext' -or $assistantService -notmatch 'Approved ONYX context:') {
    throw 'Gemini workflow must inject retrieved ONYX knowledge into the model prompt.'
}

if ($assistantService -match 'Current page path"\s*\+|Useful pages:|Use page paths') {
    throw 'Gemini assistant must not expose internal page paths or page-path instructions to customers.'
}

if ($assistantService -match 'return\s+"[^"]*/customer_page/|return\s+"[^"]*\\.aspx') {
    throw 'Gemini fallback replies must not expose internal page paths to customers.'
}

if ($knowledgeService -match '"Source:\s*"') {
    throw 'ONYX knowledge context sent to Gemini must not include internal source file labels.'
}

if ($assistantService -notmatch 'SanitizeAssistantReply') {
    throw 'Gemini assistant must sanitize generated replies before returning them to the chat UI.'
}

if ($assistantService -notmatch 'knowledge base.*ONYX information') {
    throw 'Gemini assistant must sanitize internal knowledge-base phrasing before returning replies.'
}

if ($assistantService -notmatch 'MaxOutputTokens\s*=\s*(2[0-9]{2}|3[0-9]{2})') {
    throw 'Gemini assistant must keep a small output cap for concise chat replies.'
}

if ($assistantService -match 'ThinkingBudget\s*=\s*0') {
    throw 'Gemini assistant must not disable model thinking with ThinkingBudget = 0.'
}

if ($assistantService -match 'BuildKnowledgeFallbackReply') {
    throw 'Gemini assistant must not answer with hard-coded knowledge fallbacks instead of calling the model.'
}

if ($assistantService -notmatch 'AssistantResult\.ConfigurationMissing') {
    throw 'Gemini assistant must report missing Gemini configuration instead of pretending the canned fallback is an AI answer.'
}

if ($assistantService -notmatch '1-2 short sentences' -or $assistantService -notmatch 'at most 3 short sentences') {
    throw 'Gemini assistant prompt must enforce short, direct answers.'
}

if ($assistantService -notmatch 'LimitSentences') {
    throw 'Gemini assistant must enforce a final sentence limit before returning replies.'
}

if (($serviceText -match 'FunctionCallingConfig|FunctionDeclaration|Tools\s*=') -and $serviceText -notmatch 'FunctionResponse') {
    throw 'Gemini workflow must not enable function calling unless it sends FunctionResponse messages back to Gemini.'
}

Write-Host 'Gemini AI workflow checks passed.'
