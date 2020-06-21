[CmdLetBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$azureDeployJsonPath,
    
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$masterPackagePath
)

$azureDeployJson = Get-Content $azureDeployJsonPath | ConvertFrom-Json -Depth 100
$masterPackageJson = Get-Content $masterPackagePath | ConvertFrom-Json -Depth 100

if ($masterPackageJson.firewallRules.value.applicationRules) {
    $mergeApplicationRules = $true
}
if ($masterPackageJson.firewallRules.value.natRules) {
    $mergeNatRules = $true
}
if ($masterPackageJson.firewallRules.value.networkRules) {
    $mergeNetRules = $true
}


if($mergeApplicationRules -eq $true){
    ($azureDeployJson.resources | Where-Object Type -Like "Microsoft.Network/azureFirewalls").properties.applicationRuleCollections += $masterPackageJson.firewallRules.value.applicationRules
}

if($mergeNatRules -eq $true){
    ($azureDeployJson.resources | Where-Object Type -Like "Microsoft.Network/azureFirewalls").properties.natRulesCollections += $masterPackageJson.firewallRules.value.natRules
}

if($mergeNetRules -eq $true){
    ($azureDeployJson.resources | Where-Object Type -Like "Microsoft.Network/azureFirewalls").properties.networkRuleCollections += $masterPackageJson.firewallRules.value.networkRules
}