param(
    [Parameter(Mandatory = $true)]
    [string]$SmtpUsername,

    [Parameter(Mandatory = $true)]
    [string]$SmtpPassword,

    [string]$EmailFromAddress = $SmtpUsername,

    [string]$EmailFromName = "ONYX Support",

    [string]$SmtpHost = "smtp.gmail.com",

    [int]$SmtpPort = 587,

    [bool]$SmtpEnableSsl = $true,

    [ValidateSet("User", "Process")]
    [string]$Target = "User"
)

$targetScope = if ($Target -eq "Process") {
    [EnvironmentVariableTarget]::Process
} else {
    [EnvironmentVariableTarget]::User
}

$settings = @{
    "SmtpHost" = $SmtpHost
    "SMTP_HOST" = $SmtpHost
    "SmtpPort" = $SmtpPort.ToString()
    "SMTP_PORT" = $SmtpPort.ToString()
    "SmtpEnableSsl" = $SmtpEnableSsl.ToString().ToLowerInvariant()
    "SMTP_ENABLE_SSL" = $SmtpEnableSsl.ToString().ToLowerInvariant()
    "SmtpUsername" = $SmtpUsername
    "SMTP_USERNAME" = $SmtpUsername
    "SmtpPassword" = $SmtpPassword
    "SMTP_PASSWORD" = $SmtpPassword
    "EmailFromAddress" = $EmailFromAddress
    "EMAIL_FROM_ADDRESS" = $EmailFromAddress
    "EmailFromName" = $EmailFromName
    "EMAIL_FROM_NAME" = $EmailFromName
}

foreach ($setting in $settings.GetEnumerator()) {
    [Environment]::SetEnvironmentVariable($setting.Key, $setting.Value, $targetScope)
}

Write-Host "ONYX email settings saved to $Target environment variables."
Write-Host "Restart Visual Studio/IIS Express before testing email."
