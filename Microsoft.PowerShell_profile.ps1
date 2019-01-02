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
Function cddash {
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

Function whichall {
    Get-Command -All $Args[0] | Format-List
}
Set-Alias -Name which -Value whichall

# Powershell completion
# Install-Module -Name "PSBashCompletions"
# https://github.com/tillig/ps-bash-completions
# ((pandoc --bash-completion) -join "`n") | Set-Content -Encoding Ascii -NoNewline -Path "$((Get-Item $PROFILE).Directory)\pandoc_bash_completion.sh"
Register-BashArgumentCompleter -Command pandoc -BashCompletions "$PSScriptRoot\pandoc_bash_completion.sh"

#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
(& C:\Users\fishe\Anaconda3\Scripts\conda.exe shell.powershell hook) | Out-String | Invoke-Expression
#endregion
