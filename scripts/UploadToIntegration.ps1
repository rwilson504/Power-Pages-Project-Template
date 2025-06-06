# Upload to Integration environment

$siteFolder = "datatables---site-ucxnn"
$environmentId = "YOUR-INTEGRATION-ENV-ID"  # Replace with your Integration environment ID
$cloud = "Public"
$modelType = "Enhanced"
$deploymentProfile = "integration"

& "$PSScriptRoot/utilities/Upload.ps1" -SiteFolder $siteFolder -EnvironmentId $environmentId -Cloud $cloud -ModelType $modelType -DeploymentProfile $deploymentProfile
