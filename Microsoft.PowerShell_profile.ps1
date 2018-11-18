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
            $ColorToolScheme = "$PSScriptRoot\solarized_light.itermcolors"
        }
        Else {
            $ColorToolScheme = "$PSScriptRoot\solarized_dark.itermcolors"
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

        # Set-PSReadlineOption -ResetTokenColors
        # Correct default tokens that don't change correctly for white background.
        # if ($Light) {
        #     $Colors = @{
        #         ContinuationPrompt = 'Black'
        #         Default = 'Black'
        #         Type = 'DarkGray'
        #         Member = 'Black'
        #         Number = 'Black'
        #     }
        #     Set-PSReadlineOption -Colors $Colors
        # }
    }
}

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# PSReadline Settings
Set-PSReadlineOption -EditMode vi -BellStyle None `
    -ViModeIndicator Cursor `
    -ShowToolTips
# History
Set-PSReadLineOption -HistoryNoDuplicates `
    -HistorySearchCursorMovesToEnd `
    -HistorySaveStyle SaveIncrementally `
    -MaximumHistoryCount 4000

# Import-Module posh-git and configure prompt.
. $PSScriptRoot\posh-gitrc.ps1
if ($env:USERDOMAIN -eq 'DOMAIN1') {
    # Set these in $PROFILE to overide ~/.gitconfig:
    # GIT_AUTHOR_NAME is the human-readable name in the “author” field.
    $env:GIT_AUTHOR_NAME='John D. Fisher'
    # GIT_AUTHOR_EMAIL is the email for the “author” field.
    $env:GIT_AUTHOR_EMAIL='jdfisher@energy-northwest.com'
    # GIT_AUTHOR_DATE is the timestamp used for the “author” field.
    # GIT_COMMITTER_NAME sets the human name for the “committer” field.
    $env:GIT_COMMITTER_NAME=$env:GIT_AUTHOR_NAME
    # GIT_COMMITTER_EMAIL is the email address for the “committer” field.
    $env:GIT_COMMITTER_EMAIL=$env:GIT_AUTHOR_EMAIL
    # GIT_COMMITTER_DATE is used for the timestamp in the “committer” field.
    # EMAIL is the fallback email address in case the user.email configuration
    # value isn’t set. If this isn’t set, Git falls back to the system user and
    # host names.
    $env:EMAIL=$env:GIT_AUTHOR_EMAIL
}


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

Function Defender {
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

Function Set-Dotfile {
    <#
    .SYNOPSIS
    Hide dotfiles (.*) similar to *nix shells.

    .DESCRIPTION
    Set the file attribute to Hidden for files beginning with a period (.*).

    .PARAMETER Path
    Full or relative Path to a directory or comma separated list of directories
    containing dotfiles.

    .PARAMETER Recurse
    Recurse through sub-directories.

    .PARAMETER Force
    The name of a file to write failed computer names to. Defaults to errors.txt.
      #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]

    Param(
        [Parameter()]
        [SupportsWildcards()]
        [string[]] $Path = '.',
        [Parameter()]
        [switch] $Recurse,
        [Parameter()]
        [switch] $Force
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

    Process {
        <# Pre-impact code #>

        # -Confirm --> $ConfirmPreference = 'Low'
        # ShouldProcess intercepts WhatIf* --> no need to pass it on
        if ($Force -or $PSCmdlet.ShouldProcess("ShouldProcess?")) {
            Write-Verbose ('[{0}] Reached command' -f $MyInvocation.MyCommand)
            # Variable scope ensures that parent session remains unchanged
            $ConfirmPreference = 'None'
        }

        Get-ChildItem -Path $Path -Recurse:$Recurse -Force:$Force | `
            Where-Object {$_.name -like ".*" -and $_.attributes -match 'Hidden' `
                -eq $false} | `
            Set-ItemProperty -name Attributes `
                -value ([System.IO.FileAttributes]::Hidden)

        <# Post-impact code #>
    }
}
