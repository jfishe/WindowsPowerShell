# Session-scoped, not $env:, so pwsh and powershell child processes don't
# inherit each other's profile directory.
$global:PROFILEDIR = $PSScriptRoot

$UserInteractive = -not ([Environment]::GetCommandLineArgs() -Contains '-NonInteractive') -and ($host.Name -eq 'ConsoleHost')

If ($UserInteractive) {
    # PSReadline Settings
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

    # Colors are written by tinty hooks in WSL: ~\.config\tinted-theming\Profile.Tinty.ps1
    # (tinted-psreadline) and ~\.dircolors (tinted-dircolors). Reloaded from
    # the prompt when they change, so `tinty apply` recolors open sessions.
    $global:__TintyFiles = @{
        PSReadLine = Join-Path $HOME '.config/tinted-theming/Profile.Tinty.ps1'
        DirColors  = Join-Path $HOME '.dircolors'
    }
    $global:__TintyStamps = @{}
    function Get-TintyChanged([string]$Name) {
        $item = Get-Item -LiteralPath $global:__TintyFiles[$Name] -ErrorAction Ignore
        if ($item -and $item.LastWriteTimeUtc -ne $global:__TintyStamps[$Name]) {
            $global:__TintyStamps[$Name] = $item.LastWriteTimeUtc
            $item
        }
    }
    function Update-TintyColors {
        if ($item = Get-TintyChanged PSReadLine) { . $item.FullName }
        # DirColors is imported on the first prompt; wait for it.
        if ((Get-Module DirColors) -and ($item = Get-TintyChanged DirColors)) {
            Update-DirColors $item.FullName
        }
    }
    Update-TintyColors
    # Disabled by default in vi mode
    Set-PSReadLineKeyHandler -Key 'Ctrl+w' -Function BackwardDeleteWord
    Set-PSReadLineKeyHandler -Key 'Ctrl+Spacebar' -Function MenuComplete
    # Default Yellow/Cyan is low contrast
    # $Host.PrivateData.ProgressForegroundColor = [ConsoleColor]::Red

    Remove-Variable PSReadlineOptions
}

If ($UserInteractive) { . "$PSScriptRoot/Alias" }

If ($UserInteractive) {
    . "$PSScriptRoot/Completions/Profile.Completions"

    if (Get-Command 'starship' -ErrorAction SilentlyContinue) {

        # Deferred until PSReadLine is idle so the first prompt is not blocked.
        $null = Register-EngineEvent -SourceIdentifier 'PowerShell.OnIdle' `
            -MaxTriggerCount 1 -Action {
            # LS_COLORS comes from ~\.dircolors via Update-TintyColors.
            Import-Module -Name DirColors -Global -DisableNameChecking
            # DirColors colors any non-link reparse point as a block device
            # (BLK 33;44, unreadable). OneDrive items are reparse points, so
            # drop that fallback and classify them as normal files/dirs.
            & (Get-Module DirColors) {
                $src = ${function:Get-ColorCode}.ToString()
                $patched = $src -replace '(?m)^\s*Return \$script:DirColors\.BlockDevice\s*$', ''
                if ($patched -ne $src) {
                    Set-Item function:script:Get-ColorCode ([scriptblock]::Create($patched))
                }
            }
            Update-TintyColors

            Import-Module -Global -DisableNameChecking -Name git-aliases
        }

        function Invoke-Starship-PreCommand {
            Update-TintyColors
            # # https://learn.microsoft.com/en-us/windows/terminal/tutorials/new-tab-same-directory#powershell-with-starship
            # Prompt marks (OSC 133) are emitted by the prompt wrapper below.
            $loc = $executionContext.SessionState.Path.CurrentLocation;
            if ($loc.Provider.Name -eq "FileSystem") {
                $host.ui.Write("$([char]27)]9;9;`"$($loc.ProviderPath)`"$([char]27)\")
            }
        }
        # Invoke-Expression (&starship init powershell)
        try {
            . "$PSScriptRoot/Profile.Starship.ps1"
        } catch [System.Management.Automation.CommandNotFoundException] {
            if ($PSVersionTable.PSVersion.Major -lt 6) {
                & starship init powershell --print-full-init |
                Out-File -Encoding utf8 -FilePath "$PSScriptRoot/Profile.Starship.ps1"
            } else {
                & starship init powershell --print-full-init |
                Out-File -Encoding utf8 -Path "$PSScriptRoot/Profile.Starship.ps1"
            }
            . "$PSScriptRoot/Profile.Starship.ps1"
        }
    }
}

Remove-Variable UserInteractive
