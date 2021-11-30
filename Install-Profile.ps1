<#PSScriptInfo

.VERSION 1.1

.GUID 88708b51-21f2-4ff8-8b9c-9df11578d0a9

.AUTHOR jdfenw@gmail.com

.COMPANYNAME John D. Fisher

.COPYRIGHT John D. Fisher, MIT License

.TAGS

.LICENSEURI https://github.com/jfishe/PowerShell/blob/master/LICENSE

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

 profile.Depend.psd1

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#>

<#
.SYNOPSIS
 Use PSDepend to install modules listed in profile.Depend.psd1.

.DESCRIPTION
 Install required modules for PowerShell Core environment.

 This only need execution once but may be repeated if you add new modules to
 profile.Depend.psd1.


.EXAMPLE
 Get-Content .\profile.Depend.psd1

 @{
     PSDependOptions  = @{
         AddToPath = $false
     }
     'posh-git'       = 'latest'
     'oh-my-posh'     = 'latest'
     Plaster          = 'latest'
     PSScriptAnalyzer = 'latest'
     WslInterop       = 'latest'
     PSReadLine       = 'latest'
 }

.EXAMPLE
 .\Install-Profile.ps1

 Starting build of PowerShell Profile
 Install/Import Profile-Dependent Modules
 Starting build of PowerShell Profile
 Install/Import Profile-Dependent Modules

 Processing dependency
 Process the dependency 'Plaster'?
 [Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help
 (default is "Y"):A

.LINK
 https://github.com/RamblingCookieMonster/PSDepend

#>
[CmdletBinding()]
Param ()

Write-Output "Starting build of PowerShell Profile"

if (!(Get-PackageProvider -Name 'NuGet')) {
    Write-Output "Installing Nuget package provider..."
    Install-PackageProvider -Name 'NuGet' -Force -Confirm:$false | Out-Null
}

Write-Output "Install/Import Profile-Dependent Modules"
$PSDependVersion = '0.3.2'
if (!(Get-InstalledModule -Name 'PSDepend' -RequiredVersion $PSDependVersion `
            -ErrorAction 'SilentlyContinue')) {
    Install-Module -Name 'PSDepend' -RequiredVersion $PSDependVersion -Force `
        -Scope 'CurrentUser'
}
Import-Module -Name 'PSDepend' -RequiredVersion $PSDependVersion
Invoke-PSDepend -Path "$PSScriptRoot\profile.Depend.psd1" -Install
