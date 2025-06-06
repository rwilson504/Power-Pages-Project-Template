# Upload to Development environment

$siteFolder = "datatables---site-ucxnn"
$environmentId = "YOUR-DEVELOPMENT-ENV-ID"  # Replace with your Dev environment ID
$cloud = "Public"
$modelType = "Enhanced"
$deploymentProfile = "dev"

& "$PSScriptRoot/utilities/Upload.ps1" -SiteFolder $siteFolder -EnvironmentId $environmentId -Cloud $cloud -ModelType $modelType -DeploymentProfile $deploymentProfile
