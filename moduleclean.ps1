
<#PSScriptInfo

.VERSION 2.0

.GUID 91913fa6-8643-40e9-8310-44fe7c2c42ca

.AUTHOR jdfenw@gmail.com

.COMPANYNAME John D. Fisher

.COPYRIGHT 2018-2026 John D. Fisher

.TAGS
    module
    cleanup

.LICENSEURI https://github.com/jfishe/PowerShell/blob/main/LICENSE

.PROJECTURI https://github.com/jfishe/PowerShell

.ICONURI

.EXTERNALMODULEDEPENDENCIES PowerShellGet

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
 2.0: Rewritten. Supports -WhatIf and -Confirm.

#>

<#
.SYNOPSIS
 Uninstall superseded versions of modules installed in the profile directory.

.DESCRIPTION
 For each module that PowerShellGet installed under the $PROFILE directory,
 keep the newest version and uninstall all others.

.EXAMPLE
 .\moduleclean.ps1 -WhatIf

 List the module versions that would be uninstalled.
#>
[CmdletBinding(SupportsShouldProcess)]
Param ()

$ProfileDir = Split-Path $PROFILE

$Installed = Get-InstalledModule |
Where-Object { $_.InstalledLocation -like "$ProfileDir*" }

foreach ($Newest in $Installed) {
    $Old = Get-InstalledModule -Name $Newest.Name -AllVersions |
    Where-Object { $_.Version -ne $Newest.Version }

    foreach ($Module in $Old) {
        $Target = "$($Module.Name) $($Module.Version)"
        if ($PSCmdlet.ShouldProcess($Target, "Uninstall (keeping $($Newest.Version))")) {
            $Module | Uninstall-Module -Force
        }
    }
}
