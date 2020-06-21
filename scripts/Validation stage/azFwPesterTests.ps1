<#
        This sample powershell pester test script contains the Azure Firewall network package pester tests.
        As part of the pester tests it will do a first validation with the master network package to check for configuration issues.
#>

[CmdLetBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$networkingPackagePath,
    
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$engineeringNetworkingPackagePath
)

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

# Initiating elements to check
$requiredElements = New-Object System.Collections.ArrayList
[void]$requiredElements.Add('metadata')
[void]$requiredElements.Add('firewallrules')

if ($TemplateJson.firewallRules.value.applicationRules) {
    $checkApplicationRules = $true
}
if ($TemplateJson.firewallRules.value.natRules) {
    $checkNatRules = $true
}
if ($TemplateJson.firewallRules.value.networkRules) {
    $checkNetworkRules = $true
}


#Pester tests
Describe 'Network package Validation' {
    Context 'Template File Validation' {
        It 'Template File Exists' {
            Test-Path $networkingPackagePath -PathType Leaf -Include '*.json' | Should Be $true
        }

        It 'Network package is a valid JSON file' {
            $networkingPackage | ConvertFrom-Json -ErrorAction SilentlyContinue | Should Not Be $Null
        }
    }

    Context 'Network package Content Validation' {
        It "Contains all required elements" {
            $bValidRequiredElements = $true
            Foreach ($item in $requiredElements) {
                if (-not $TemplateElements.Contains($item)) {
                    $bValidRequiredElements = $false
                    Write-Output "template does not contain '$item'"
                }
            }
            $bValidRequiredElements | Should be $true
        }

        It "Has valid metadata content" {
            If (($TemplateJson.metaData.value.applicationName) -and ($TemplateJson.metaData.value.applicationEnvironment) -and ($TemplateJson.metaData.value.version)) {
                $bvalidmetadatacontent = $true
            }
            else {
                $bvalidmetadatacontent = $false
            }
            $bvalidmetadatacontent | Should be $true
        }
    }

    Context 'Network package Application rules validation' {
        If ($checkApplicationRules -eq $true) {
            It "Has valid application rules names configured" {
                $appNameCheck = $true
                $appicationRules = $TemplateJson.firewallRules.value.applicationRules
                foreach ($applicationrule in $appicationRules) {
                    $appruleproperties = $applicationrule.properties
                    if (-not(($appruleproperties.priority -match '[0-9]+'))) {
                        $appNameCheck = $false
                    }
                }
                $appNameCheck | Should be $true
            }
            
            It "Has valid application rules priorities configured: prio is unique in application package" {
                $appPrioCheck = $true
                $appicationRules = $TemplateJson.firewallRules.value.applicationRules
                foreach ($applicationrule in $appicationRules) {
                    $appruleproperties = $applicationrule.properties
                    if (-not($appruleproperties.priority -notin ($appicationRules | Where-Object name -ne $applicationrule.name | Select-Object -ExpandProperty properties | Select-Object -ExpandProperty Priority))) {
                        $appPrioCheck = $false
                    }
                }
                $appPrioCheck | Should be $true
            }

            It "Has valid application rules priorities configured: prio is unique in master package" {
                $appPrioCheck2 = $true
                $appicationRules = $TemplateJson.firewallRules.value.applicationRules
                foreach ($applicationrule in $appicationRules) {
                    $appruleproperties = $applicationrule.properties
                    if (-not($appruleproperties.priority -notin ($engineeringTemplateJson.firewallRules.value.applicationRules | Where-Object name -ne $applicationrule.name| Select-Object -ExpandProperty properties | Select-Object -ExpandProperty priority))) {
                        $appPrioCheck2 = $false
                    }
                }
                $appPrioCheck2 | Should be $true
            }
        }
    }
    
    Context 'Network package nat rules validation' {
        If ($checkNatRules -eq $true) {
            It "Has valid nat rules names configured" {
                $natNameCheck = $true
                $natRules = $TemplateJson.firewallRules.value.natRules
                foreach ($natRule in $natRules) {
                    $natruleproperties = $natRule.properties
                    if (-not(($natruleproperties.priority -match '[0-9]+'))) {
                        $natNameCheck = $false
                    }
                }
                $natNameCheck | Should be $true
            }
            
            It "Has valid nat priorities configured: prio is unique in application package" {
                $natpriocheck = $true
                $natrules = $TemplateJson.firewallRules.value.natRules
                foreach ($natrule in $natrules) {
                    $natruleproperties = $natrule.properties
                    if (-not($natruleproperties.priority -notin ($natrules | Where-Object name -ne $natrule.name | Select-Object -ExpandProperty properties | Select-Object -ExpandProperty Priority))) {
                        $natpriocheck = $false
                    }
                }
                $natpriocheck | Should be $true
            }

            It "Has valid nat rules priorities configured: prio is unique in master package" {
                $natpriocheck2 = $true
                $natrules = $TemplateJson.firewallRules.value.natRules
                foreach ($natrule in $natrules) {
                    $natruleproperties = $natrule.properties
                    if (-not($natruleproperties.priority -notin ($engineeringTemplateJson.firewallRules.value.natRules | Where-Object name -ne $natrule.name| Select-Object -ExpandProperty properties | Select-Object -ExpandProperty priority))) {
                        $natpriocheck2 = $false
                    }
                }
                $natpriocheck2 | Should be $true
            }
        }
    }

    Context 'Network package net rules validation' {
        If ($checkNetworkRules -eq $true) {
            It "Has valid net rules names configured" {
                $netnamecheck = $true
                $netrules = $TemplateJson.firewallRules.value.networkRules
                foreach ($netrule in $netrules) {
                    $netruleproperties = $netrule.properties
                    if (-not(($netruleproperties.priority -match '[0-9]+'))) {
                        $netnamecheck = $false
                    }
                }
                $netnamecheck | Should be $true
            }
            
            It "Has valid net rules priorities configured: prio is unique in application package" {
                $netpriocheck = $true
                $netrules = $TemplateJson.firewallRules.value.networkRules
                foreach ($netrule in $netrules) {
                    $netruleproperties = $netrule.properties
                    if (-not($netruleproperties.priority -notin ($netrules | Where-Object name -ne $netrule.name | Select-Object -ExpandProperty properties | Select-Object -ExpandProperty Priority))) {
                        $netpriocheck = $false
                    }
                }
                $netpriocheck | Should be $true
            }

            It "Has valid net rules priorities configured: prio is unique in master package" {
                $netpriocheck2 = $true
                $netrules = $TemplateJson.firewallRules.value.networkRules
                foreach ($netrule in $netrules) {
                    $netruleproperties = $netrule.properties
                    if (-not($netruleproperties.priority -notin ($engineeringTemplateJson.firewallRules.value.networkRules | Where-Object name -ne $netrule.name | Select-Object -ExpandProperty properties | Select-Object -ExpandProperty priority))) {
                        $netpriocheck2 = $false
                    }
                }
                $netpriocheck2 | Should be $true
            }
        }
    }
}