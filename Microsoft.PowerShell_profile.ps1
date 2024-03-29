[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression",
    "", Justification = "Required by starship")]
Param()

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

# PSReadline Settings
If ($host.Name -eq 'ConsoleHost') {
    $PSReadlineOptions = @{
        EditMode                      = "vi"
        BellStyle                     = "None"
        ViModeIndicator               = "Cursor"
        ShowToolTips                  = $true

        # History
        HistoryNoDuplicates           = $true
        HistorySearchCursorMovesToEnd = $true
        HistorySaveStyle              = "SaveIncrementally"
        MaximumHistoryCount           = 4000

        # Prediction
        PredictionSource              = "History"
        PredictionViewStyle           = "ListView"

        # Oh-My-Posh prompt
        ExtraPromptLineCount          = 1
        PromptText                    = "$([char]::ConvertFromUtf32(0x279C)) " # ➜

        # Colors = @{
        #     "InlinePredictionColor" = "`e[95m"
        #     "ListPredictionColor" = "`e[95m"
        #     "ListPredictionSelectedColor" = "`e[48;95m"
        # }
    }
    Set-PSReadLineOption @PSReadlineOptions
    # Disabled by default in vi mode
    Set-PSReadLineKeyHandler -Key 'Ctrl+w' -Function BackwardDeleteWord
    Set-PSReadLineKeyHandler -Key 'Ctrl+Spacebar' -Function MenuComplete


    Function _history {
        Get-Content (Get-PSReadLineOption).HistorySavePath | less -N
    }
    Remove-Item -Path Alias:\history -ErrorAction SilentlyContinue
    Set-Alias -Name history -Value _history `
        -Description "Show PSReadline command history file with pager by less"

    # Default Yellow/Cyan is low contrast
    $Host.PrivateData.ProgressForegroundColor = [ConsoleColor]::Red
}

if ($env:USERDOMAIN -eq 'DOMAIN1') {
    # Set these in $PROFILE to overide ~/.gitconfig:
    # GIT_AUTHOR_NAME is the human-readable name in the “author” field.
    $env:GIT_AUTHOR_NAME = 'John D. Fisher'
    # GIT_AUTHOR_EMAIL is the email for the “author” field.
    $env:GIT_AUTHOR_EMAIL = 'jdfisher@energy-northwest.com'
    # GIT_AUTHOR_DATE is the timestamp used for the “author” field.
    # GIT_COMMITTER_NAME sets the human name for the “committer” field.
    $env:GIT_COMMITTER_NAME = $env:GIT_AUTHOR_NAME
    # GIT_COMMITTER_EMAIL is the email address for the “committer” field.
    $env:GIT_COMMITTER_EMAIL = $env:GIT_AUTHOR_EMAIL
    # GIT_COMMITTER_DATE is used for the timestamp in the “committer” field.
    # EMAIL is the fallback email address in case the user.email configuration
    # value isn’t set. If this isn’t set, Git falls back to the system user and
    # host names.
    $env:EMAIL = $env:GIT_AUTHOR_EMAIL
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
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]

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
            Where-Object { $_.name -like ".*" -and $_.attributes -match 'Hidden' `
                -eq $false } | `
            Set-ItemProperty -name Attributes `
            -value ([System.IO.FileAttributes]::Hidden)

        <# Post-impact code #>
    }
}

Function _which {
    Get-Command -All $Args[0] -ErrorAction SilentlyContinue | Format-List
}
Set-Alias -Name which -Value _which

Function Set-ColorScheme {

    <#
.SYNOPSIS

Toggle the console color scheme between solarized dark and light.

.DESCRIPTION

Windows Console ColorTool should be in $env:PATH.

The schemes\ folder should be in the same directory as ColorTool.exe.

The color schemes, based on vim-solarized8, were created using terminal.sexy.

.OUTPUTS

ColorTool.exe --quiet [[solarized.dark.itermcolors]|[solarized.light.itermcolors]]

.LINK

https://github.com/Microsoft/console/tree/master/tools/ColorTool

.LINK

https://terminal.sexy/

.LINK

https://github.com/lifepillar/vim-solarized8

#>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param()
    begin {
        $colortool = Get-Command -Name "colortool"
        $ColorSchemes = $colortool.Path |
        ForEach-Object -Process { (Get-Item $_).Directory } |
        ForEach-Object -Process { Get-ChildItem $_ -Name "schemes/solarized.*" }
        $colorscheme = [int]$(($env:COLORSCHEME -eq 0))
        $ConfirmMessage = @("Change console color scheme to",
            $ColorSchemes[$colorscheme]
        )
    }
    process {
        if ($PSCmdlet.ShouldProcess($ConfirmMessage)) {
            $env:COLORSCHEME = $colorscheme
            & $colortool --quiet $ColorSchemes[$env:COLORSCHEME]
        }
    }
}
Set-Alias -Name yob -Value Set-ColorScheme

$env:PROFILEDIR = (Get-Item $PROFILE).Directory

# Powershell completion
# Install-Module -Name "PSBashCompletions"
# https://github.com/tillig/ps-bash-completions
# ((pandoc --bash-completion) -join "`n") | Set-Content -Encoding Ascii -NoNewline -Path "$((Get-Item $PROFILE).Directory)\pandoc_bash_completion.sh"
If ($host.Name -eq 'ConsoleHost') {
    Register-BashArgumentCompleter -Command pandoc `
        -BashCompletions "$PSScriptRoot\pandoc_bash_completion.sh" `
        -ErrorAction SilentlyContinue
}

# Import-Module posh-git and configure prompt.
# 400 msec
If ($host.Name -eq 'ConsoleHost') {
    Import-Module VimTabCompletion
    Import-Module DirColors
    Update-DirColors ~\.dircolors
    Import-Module posh-git
    Invoke-Expression (&starship init powershell)
}
