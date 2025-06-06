
param(
    [string]$EnvironmentId = "YOUR-ENVIRONMENT-ID",  # Replace with your actual Environment ID
    [string]$WebsiteId = "YOUR-WEBSITE-ID",  # Replace with your actual Website ID
    [ValidateSet("Public", "UsGov", "UsGovHigh", "UsGovDod", "China")]
    [string]$Cloud = "Public",
    [ValidateSet("Standard", "Enhanced")]
    [string]$ModelType = "Enhanced"
)

# Convert ModelType to ModelVersion
switch ($ModelType) {
    "Standard" { $ModelVersion = 1 }
    "Enhanced" { $ModelVersion = 2 }
    default { $ModelVersion = 2 }
}

# Set path to Sites folder
$path = Join-Path -Path (Split-Path -Path (Get-Location) -Parent) -ChildPath "Sites"
Write-Host "Download path: $path"

# Ensure Power Platform CLI is available
if (-not (Get-Command pac -ErrorAction SilentlyContinue)) {
    Write-Error "Power Platform CLI (pac) is not installed or not in PATH."
    exit 1
}

# Add PowerApps CLI to PATH if needed
$cliPath = "$($env:LOCALAPPDATA)\Microsoft\PowerAppsCli"
if (-not ($env:Path -like "*$cliPath*")) {
    $env:Path += ";$cliPath"
}

Write-Host "Authenticating to environment $EnvironmentId (Cloud: $Cloud)"
pac auth create --environment $EnvironmentId --cloud $Cloud

Write-Host "Downloading portal content (ModelVersion: $ModelVersion, WebsiteId: $WebsiteId)"
pac pages download --path $path --overwrite --modelVersion $ModelVersion --environment $EnvironmentId --webSiteId $WebsiteId