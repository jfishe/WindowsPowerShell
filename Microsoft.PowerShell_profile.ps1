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
    [cmdletbinding(SupportsShouldProcess, ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory=$false)]
        [switch] $Dark,

        [Parameter(Mandatory=$false)]
        [switch] $Light,

        [Parameter(Mandatory=$false)]
        [switch] $d
    )

     Begin {
            if (-not $PSBoundParameters.ContainsKey('Verbose')) {
                $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
            }
            if (-not $PSBoundParameters.ContainsKey('Confirm')) {
                $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
            }
            if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
                $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
            }
            Write-Verbose ('[{0}] Confirm={1} ConfirmPreference={2} WhatIf={3} WhatIfPreference={4}' -f $MyInvocation.MyCommand, $Confirm, $ConfirmPreference, $WhatIf, $WhatIfPreference)
        }

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
        Write-Verbose "You selected for the current session:`n         $ColorToolScheme"
        # $ColorTool = "C:\Users\fishe\Documents\GitHub\console\tools\ColorTool"
        $ColorTool = "$PSScriptRoot"
        # $ColorToolScheme = "$ColorTool\schemes\Solarized Dark Higher Contrast.itermcolors"
        # $ColorToolScheme = "C:\Users\fishe\Documents\GitHub\iTerm2-Color-Schemes\schemes\Solarized Dark Higher Contrast.itermcolors"

        $ColorToolExe = "$ColorTool\ColorTool.exe"


        & $ColorToolExe  $ColorToolScheme

        If ($d) {
            if ($PSCmdlet.ShouldProcess("Default Colorscheme")) {
                Write-Verbose "Default updated to $ColorToolScheme`n Don't forget to save Defaults"
                & $ColorToolExe  -d $ColorToolScheme
            }
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

# PSReadline Settings
Set-PSReadlineOption -EditMode vi -BellStyle None `
    -ViModeIndicator Cursor
# History
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -HistorySaveStyle SaveIncrementally
Set-PSReadLineOption -MaximumHistoryCount 4000
# Tab completion
Set-PSReadLineOption  -ShowToolTips
Set-PSReadLineKeyHandler -Chord 'Shift+Tab' -Function Complete
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

# Import-Module posh-git and configure prompt.
. $PSScriptRoot\posh-gitrc.ps1

# cddash
# Enable cd -
# http://goo.gl/xRbYbk
function cddash {
    if ($args[0] -eq '-') {
        $pwd = $OLDPWD;
    } else {
        $pwd = $args[0];
    }
    $tmp = Get-Location;

    if ($pwd) {
        Set-Location $pwd;
    }
    Set-Variable -Name OLDPWD -Value $tmp -Scope global;
}
Set-Alias -Name cd -value cddash -Option AllScope

Function Defender
{
<#
.Synopsis
Windows Defender Scan

.Description
Create a function to run MpCmdRun.exe with appropriate options to scan a file.

Defender -Scan -ScanType 3 -File <filename>
#>
    [cmdletbinding()]
    Param(
        [Parameter(Mandatory=$true,Position=1)]
        [string] $File
    )

    Begin
    {
        $Window_Defender = "$env:ProgramFiles\Windows Defender\MpCmdRun.exe"
        $ArgumentList = "-Scan -ScanType 3 -File ""$File"""
    }

    Process
    {
        Start-Process -FilePath "$Window_Defender" -ArgumentList "$ArgumentList" -NoNewWindow -Verbose
    }
}
