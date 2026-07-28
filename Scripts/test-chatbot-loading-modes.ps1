$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$master = Get-Content -Raw -Path (Join-Path $repoRoot 'customer_page\onyx_user.Master')
$handler = Get-Content -Raw -Path (Join-Path $repoRoot 'customer_page\onyx_ai_chat.ashx.cs')
$service = Get-Content -Raw -Path (Join-Path $repoRoot 'Services\OpenAiAssistantService.cs')

if ($master -notmatch 'function isDirectAiRequest\(text\)') {
    throw 'Chat UI must identify direct order requests before showing an AI-thinking state.'
}

if ($master -notmatch 'var directRequest = isDirectAiRequest\(text\);') {
    throw 'Chat UI must use the direct-request classification when sending a message.'
}

if ($master -notmatch "var pendingMessage = directRequest \? null : addAiMessage\('ONYX AI is thinking\.\.\.', 'bot'\);") {
    throw 'Only AI-capable requests may show the ONYX AI thinking message.'
}

if ($handler -notmatch '\[JsonProperty\("aiGenerated"\)\]' -or $handler -notmatch 'AiGenerated = result\.IsAiGenerated') {
    throw 'Chat responses must carry whether the model generated the reply.'
}

if ($service -notmatch 'public bool IsAiGenerated' -or $service -notmatch 'AssistantResult\.AiSuccess\(SanitizeAssistantReply\(reply\), productActions\)') {
    throw 'Only a successful model response may be marked as AI-generated.'
}

Write-Host 'Chatbot loading-mode checks passed.'
