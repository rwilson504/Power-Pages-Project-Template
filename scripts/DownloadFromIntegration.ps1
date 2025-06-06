# Download from Integration environment

$siteFolder = "datatables---site-ucxnn"
$environmentId = "YOUR-INTEGRATION-ENV-ID"  # Replace with your Integration environment ID
$cloud = "Public"
$modelType = "Enhanced"

& "$PSScriptRoot/utilities/Download.ps1" -SiteFolder $siteFolder -EnvironmentId $environmentId -Cloud $cloud -ModelType $modelType
