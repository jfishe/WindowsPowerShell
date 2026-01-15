
<#PSScriptInfo

.VERSION 1.0

.GUID 73e1ddaa-1083-4e57-aaf3-51ef6186a93d

.AUTHOR jdfenw@gmail.com

.COMPANYNAME John D. Fisher

.COPYRIGHT (c) 2026 John D. Fisher. All rights reserved.

.TAGS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Install or Update completions listed in Profile.Completions. 

#> 
Param()

$completionPath = Split-Path $PROFILE | Join-Path -ChildPath "Completions"

$Parameters = @{
  Encoding = "utf8"
  Path = "$completionPath\starship-profile.ps1"
}
if ($PSVersionTable.PSVersion.Major -lt 6) {
  $Parameters.FilePath = $Parameters.Path
  $Parameters.Remove("Path")
}
& starship init powershell --print-full-init | Out-File @Parameters

((pandoc --bash-completion) -join "`n") |
  Set-Content -Encoding Ascii -NoNewline `
    -Path "$completionPath\pandoc-completion.sh"
