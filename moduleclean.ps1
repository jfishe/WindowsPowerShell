
<#PSScriptInfo

.VERSION 1.0

.GUID 91913fa6-8643-40e9-8310-44fe7c2c42ca

.AUTHOR jdfenw@gmail.com

.COMPANYNAME John D. Fisher

.COPYRIGHT Copyright (C) 2018  John D. Fisher

.TAGS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES PSGet

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
 Modified from Jack Fruh's "Powershell script to remove duplicate, old modules"
 at
 http://sharepointjack.com/2017/powershell-script-to-remove-duplicate-old-modules/

#>

<#

.DESCRIPTION
 Remove all old versions of installed modules in $PROFILE's directory.

#>
param()

Write-Host "this will remove all old versions of installed modules"
# write-host "be sure to run this as an admin" -foregroundcolor yellow
Write-Host "(You can update all your Azure RM modules with update-module Azurerm -force)"

$PROFILEDIR = (Get-Item $PROFILE).Directory
$mods = Get-InstalledModule |
Where-Object { $_.InstalledLocation -like "$PROFILEDIR*" }

foreach ($Mod in $mods)
{
  Write-Host "Checking $($mod.name)"
  $latest = Get-InstalledModule $mod.Name
  $specificmods = Get-InstalledModule $mod.Name -AllVersions
  Write-Host "$($specificmods.count) versions of this module found [ $($mod.name) ]"

  foreach ($sm in $specificmods)
  {
    if ($sm.version -ne $latest.version)
    {
      Write-Host "uninstalling $($sm.name) - $($sm.version) [latest is $($latest.version)]"
      $sm | Uninstall-Module -Force
      Write-Host "done uninstalling $($sm.name) - $($sm.version)"
      Write-Host "    --------"
    }

  }
  Write-Host "------------------------"
}
Write-Host "done"
