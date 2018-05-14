#set-alias vim "C:/Program Files/Vim/vim80/vim.exe"

# To edit the Powershell Profile
# (Not that I'll remember this)
Function Edit-Profile
{
    vim $profile
}

# To edit Vim settings
Function Edit-Vimrc
{
    vim $HOME\_vimrc
}

# Set colorscheme
Function Set-ColorScheme
{
<#
.Synopsis
Set the console color scheme to dark or light and save color scheme to defaults
if desired.

.Description
The default is dark without updating the console color scheme defaults.

If -d is selected, the color scheme is written to the console defaults. To
save the defaults for future sessions, select Properties and OK and select
Defaults and OK from the console menu.
#>
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$false)]
        [switch] $Dark,

        [Parameter(Mandatory=$false)]
        [switch] $Light,

        [Parameter(Mandatory=$false)]
        [switch] $d
    )

    Process
    {
        If ($Dark) {
            $ColorToolScheme = "$PSScriptRoot\Solarized Dark Higher Contrast.itermcolors"
        }
        ElseIf ($Light) {
            $ColorToolScheme = "$PSScriptRoot\Solarized Light.itermcolors"
        }
        Else {
            $ColorToolScheme = "$PSScriptRoot\Solarized Dark Higher Contrast.itermcolors"
        }
        Write-Host $ColorToolScheme
        # $ColorTool = "C:\Users\fishe\Documents\GitHub\console\tools\ColorTool"
        $ColorTool = "$PSScriptRoot"
        # $ColorToolScheme = "$ColorTool\schemes\Solarized Dark Higher Contrast.itermcolors"
        # $ColorToolScheme = "C:\Users\fishe\Documents\GitHub\iTerm2-Color-Schemes\schemes\Solarized Dark Higher Contrast.itermcolors"

        $ColorToolExe = "$ColorTool\ColorTool.exe"
        & $ColorToolExe  $ColorToolScheme
        If ($d) {
            & $ColorToolExe  -d $ColorToolScheme
        }

        Set-PSReadlineOption -ResetTokenColors
        # Correct default tokens that don't change correctly for white background.
        if ($Light) {
            Set-PSReadlineOption -TokenKind Number -ForegroundColor Black
            Set-PSReadlineOption -TokenKind Member -ForegroundColor Black
        }
    }
}

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

