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
    }
    Set-PSReadLineOption @PSReadlineOptions
    # Disabled by default in vi mode
    Set-PSReadLineKeyHandler -Key 'Ctrl+w' -Function BackwardDeleteWord
    Set-PSReadLineKeyHandler -Key 'Ctrl+Spacebar' -Function MenuComplete
    # Default Yellow/Cyan is low contrast
    $Host.PrivateData.ProgressForegroundColor = [ConsoleColor]::Red

    Remove-Variable PSReadlineOptions
}

if ("$env:USERDOMAIN" -ne "$(hostname)") {
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

If ($host.Name -eq 'ConsoleHost') {
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

    Function _history {
        Get-Content (Get-PSReadLineOption).HistorySavePath | less -N
    }

    # Enable git-scm Linux ports
    Remove-Item -Force  -ErrorAction SilentlyContinue -Path alias:\* `
        -Include less, ls, grep, tree, diff, history

    Set-Alias -Name history -Value _history `
        -Description "Show PSReadline command history file with pager by less"

    Function _which {
        Get-Command -All $Args[0] -ErrorAction SilentlyContinue | Format-List
    }
    Set-Alias -Name which -Value _which `
        -Description "Get-Command -All <command>"

    Function _gitbash {
        $Parameters = @{
            # less = @('--RAW-CONTROL-CHARS', '--ignore-case')
            # See $env:LESS
            ls = @('-AFh', '--color=auto', '--group-directories-first')
            grep = @('--color=auto')
        }
        $Name = $MyInvocation.InvocationName
        $Options = $Parameters[$Name]
        & $(Get-Command -Name $Name -CommandType Application) @Options @Args
    }
    Set-Alias -Name ls -Value _gitbash -Description "GNU ls"
    Set-Alias -Name grep -Value _gitbash -Description "GNU grep"
}

If ($host.Name -eq 'ConsoleHost') {
    $env:PROFILEDIR = Split-Path $PROFILE
    $completionPath = "$env:PROFILEDIR\Completions"
    . "$completionPath/Profile.Completions"

    # & starship init powershell --print-full-init |
    #   Out-File -Encoding utf8 -Path $env:PROFILEDIR\completion\starship-profile.ps1
    if (Get-Command 'starship' -ErrorAction SilentlyContinue) {
        # Update-DirColors ~\.dircolors
        # Copy $Env:LS_COLORS to User Environment.

        Function Invoke-Starship-PreCommand {
            if ($global:profile_initialized -ne $true) {
                $global:profile_initialized = $true

                Import-Module -Name DirColors -Global -DisableNameChecking
                Import-Module -Global -DisableNameChecking -Name posh-git, git-aliases

                Initialize-Profile
            }
        }
        # Invoke-Expression (&starship init powershell)
        . "$completionPath/starship-profile"
    }

    Remove-Variable completionPath
}
