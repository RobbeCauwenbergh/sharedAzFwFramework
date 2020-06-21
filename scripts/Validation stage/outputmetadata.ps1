[CmdLetBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$networkingPackagePath
)

#Read template file
$networkingPackage = Get-Content $networkingPackagePath -Raw -ErrorAction SilentlyContinue
$TemplateJson = ConvertFrom-Json -InputObject $networkingPackage -ErrorAction SilentlyContinue

$applicationName = $TemplateJson.metaData.value.applicationName
$applicationEnvironment = $TemplateJson.metaData.value.applicationEnvironment
$applicationPackageVersion = $TemplateJson.metaData.value.version

Write-Host "##vso[task.setvariable variable=applicationName]$($applicationName)"
Write-Host "##vso[task.setvariable variable=applicationEnvironment]$($applicationEnvironment)"
Write-Host "##vso[task.setvariable variable=applicationPackageVersion]$($applicationPackageVersion)"