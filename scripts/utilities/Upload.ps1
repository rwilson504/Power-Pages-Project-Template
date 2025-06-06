param(
    [string]$EnvironmentId = "YOUR-ENVIRONMENT-ID",  # Replace with your actual Environment ID
    [ValidateSet("Public", "UsGov", "UsGovHigh", "UsGovDod", "China")]
    [string]$Cloud = "Public",
    [ValidateSet("Standard", "Enhanced")]
    [string]$ModelType = "Enhanced",
    [string]$DeploymentProfile = "dev",
    [string]$SiteFolder = "datatables---site-ucxnn"
)

# Set path to the website folder in Sites
$SitesRoot = Join-Path -Path (Split-Path -Path (Get-Location) -Parent) -ChildPath "Sites"
$Path = Join-Path $SitesRoot $SiteFolder
Write-Host "Upload path: $Path"

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

# Convert ModelType to ModelVersion
switch ($ModelType) {
    "Standard" { $ModelVersion = 1 }
    "Enhanced" { $ModelVersion = 2 }
    default { $ModelVersion = 2 }
}

Write-Host "Authenticating to environment $EnvironmentId (Cloud: $Cloud)"
pac auth create --environment $EnvironmentId --cloud $Cloud

Write-Host "Uploading portal content (ModelVersion: $ModelVersion, DeploymentProfile: $DeploymentProfile)"
pac pages upload --path $Path --modelVersion $ModelVersion --environment $EnvironmentId --deploymentProfile $DeploymentProfile