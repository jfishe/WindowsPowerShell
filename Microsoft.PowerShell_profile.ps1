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


    Function _history {
        Get-Content (Get-PSReadLineOption).HistorySavePath | less -N
    }
    Remove-Item -Path Alias:\history -ErrorAction SilentlyContinue
    Set-Alias -Name history -Value _history `
        -Description "Show PSReadline command history file with pager by less"

    # Default Yellow/Cyan is low contrast
    $Host.PrivateData.ProgressForegroundColor = [ConsoleColor]::Red
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

Function _which {
    Get-Command -All $Args[0] -ErrorAction SilentlyContinue | Format-List
}
Set-Alias -Name which -Value _which

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
