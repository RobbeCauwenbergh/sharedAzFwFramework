<#
    This sample script will check install the pester powershell module and invokes the associated pester powershell script.
#>


[CmdLetBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$networkingPackagePath,
    
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$engineeringNetworkingPackagePath,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$pesterTestScriptPath
)

"current location: $(Get-Location)"
"script root: $PSScriptRoot"
$modules = Get-Module -list
if ($modules.Name -notcontains 'pester') {
    Install-Module -Name Pester -Force -SkipPublisherCheck
}
Invoke-Pester -Script @{ Path = $pesterTestScriptPath; Parameters = @{networkingPackagePath = $networkingPackagePath; engineeringNetworkingPackagePath = $engineeringNetworkingPackagePath } } -OutputFile "./Test-Pester.XML" -OutputFormat 'NUnitXML'
