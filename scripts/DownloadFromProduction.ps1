# Download from Production environment

$siteFolder = "datatables---site-ucxnn"
$environmentId = "YOUR-PRODUCTION-ENV-ID"  # Replace with your Production environment ID
$cloud = "Public"
$modelType = "Enhanced"

& "$PSScriptRoot/utilities/Download.ps1" -SiteFolder $siteFolder -EnvironmentId $environmentId -Cloud $cloud -ModelType $modelType
