[CmdLetBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$networkingPackagePath,
    
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$engineeringNetworkingPackagePath
)

"current location: $(Get-Location)"
"script root: $PSScriptRoot"

#Read template file
$networkingPackage = Get-Content $networkingPackagePath -Raw -ErrorAction SilentlyContinue
$TemplateJson = ConvertFrom-Json -InputObject $networkingPackage -ErrorAction SilentlyContinue
If ($TemplateJson) {
    $TemplateElements = $TemplateJson.psobject.Properties.name.tolower()
}
else {
    $TemplateElements = $null
}

# Read network engineering template file
$engineeringNetworkingPackage = Get-Content $engineeringNetworkingPackagePath -Raw -ErrorAction SilentlyContinue
$engineeringTemplateJson = ConvertFrom-Json -InputObject $engineeringNetworkingPackage -ErrorAction SilentlyContinue


if ($TemplateJson.firewallRules.value.applicationRules) {
    $importApplicationRules = $true
}
if ($TemplateJson.firewallRules.value.natRules) {
    $importNatRules = $true
}
if ($TemplateJson.firewallRules.value.networkRules) {
    $importNetRules = $true
}


if($importApplicationRules -eq $true){
    $appRules = $TemplateJson.firewallRules.value.applicationRules
    foreach($appRule in $appRules){
        $engineeringTemplateJson.firewallRules.value.applicationRules += $appRule
    }
}

if($importNatRules = $true){
    $natRules = $TemplateJson.firewallRules.value.natRules
    foreach($natRule in $natRules){
        $engineeringTemplateJson.firewallRules.value.natRules += $natRule
    }
}

if($importNetRules -eq $true){
    $netRules = $TemplateJson.firewallRules.value.networkRules
    foreach($netRule in $netRules){
        $engineeringTemplateJson.firewallRules.value.networkRules += $netRule
    }
}

$engineeringTemplateJson | ConvertTo-Json -Depth 10 | Out-File ((get-location | select -ExpandProperty Path) + '/_BuildAzureFirewallTemplates/azFwArm/masterNetworkpackage.json')