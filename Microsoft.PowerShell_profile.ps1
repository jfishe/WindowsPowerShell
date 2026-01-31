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

If ($host.Name -eq 'ConsoleHost') { . "$PSScriptRoot/Alias" }

If ($host.Name -eq 'ConsoleHost') {
    $env:PROFILEDIR = Split-Path $PROFILE

    . "$PSScriptRoot/Completions/Profile.Completions"

    if (Get-Command 'starship' -ErrorAction SilentlyContinue) {

        function Invoke-Starship-PreCommand {
            if ($global:profile_initialized -ne $true) {
                $global:profile_initialized = $true

                # Update-DirColors ~\.dircolors
                # Copy $Env:LS_COLORS to User Environment.
                Import-Module -Name DirColors -Global -DisableNameChecking

                Import-Module -Global -DisableNameChecking -Name posh-git, git-aliases
            }
            # # https://learn.microsoft.com/en-us/windows/terminal/tutorials/new-tab-same-directory#powershell-with-starship
            $loc = $executionContext.SessionState.Path.CurrentLocation;
            $prompt = "$([char]27)]9;12$([char]7)"
            if ($loc.Provider.Name -eq "FileSystem") {
                $prompt += "$([char]27)]9;9;`"$($loc.ProviderPath)`"$([char]27)\"
            }
            $host.ui.Write($prompt)
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
