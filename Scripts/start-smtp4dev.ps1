# Docker can write harmless engine capability warnings to stderr even when the
# command succeeds. Check native exit codes explicitly instead of treating all
# stderr output as a terminating PowerShell error.
$ErrorActionPreference = "Continue"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw "Docker was not found. Install or start Docker Desktop, then try again."
}

docker info *> $null
if ($LASTEXITCODE -ne 0) {
    throw "Docker is installed, but the Docker engine is not available."
}

$containerName = "smtp4dev-onyx"
$existingContainer = docker ps -a `
    --filter "name=^/$containerName$" `
    --format "{{.Names}}"

if ($LASTEXITCODE -ne 0) {
    throw "Unable to inspect Docker containers."
}

if ($existingContainer -eq $containerName) {
    docker start $containerName
} else {
    docker run -d `
        --name $containerName `
        -p 127.0.0.1:3000:80 `
        -p 127.0.0.1:2525:25 `
        rnwood/smtp4dev
}

if ($LASTEXITCODE -ne 0) {
    throw "Unable to start smtp4dev."
}

Write-Host ""
Write-Host "smtp4dev web inbox: http://localhost:3000"
Write-Host "SMTP host: localhost"
Write-Host "SMTP port: 2525"
