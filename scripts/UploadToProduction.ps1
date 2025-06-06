# Upload to Production environment

$siteFolder = "datatables---site-ucxnn"
$environmentId = "YOUR-PRODUCTION-ENV-ID"  # Replace with your Production environment ID
$cloud = "Public"
$modelType = "Enhanced"
$deploymentProfile = "production"

& "$PSScriptRoot/utilities/Upload.ps1" -SiteFolder $siteFolder -EnvironmentId $environmentId -Cloud $cloud -ModelType $modelType -DeploymentProfile $deploymentProfile
