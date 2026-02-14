
<#PSScriptInfo

.VERSION 2.2

.GUID b998381b-af98-49e9-ac84-098576bb90a4

.AUTHOR jdfenw@gmail.com

.COMPANYNAME John D. Fisher

.COPYRIGHT 2025 John D. Fisher

.TAGS
    alias
    eza
    history
    which

.LICENSEURI https://github.com/jfishe/PowerShell/blob/main/LICENSE

.PROJECTURI https://github.com/jfishe/PowerShell
#>

<#
.DESCRIPTION
 Alias File

.EXAMPLE
 PS> Get-FormatData -TypeName 'System.Management.Automation.AliasInfo' |
     Export-FormatData -LiteralPath .\Formats\AliasInfo_sys.ps1xml
 On PS 6+, Copy AliasInfo to add Description field.
#>


if ($PSVersionTable.PSVersion.Major -lt 6) {
    # Enable git-scm Linux ports
    Remove-Item -Force  -ErrorAction SilentlyContinue -Path alias:\* `
        -Include less, ls, grep, tree, diff, history
} else {
    Remove-Alias -Name history
    $null = Register-EngineEvent -SourceIdentifier 'PowerShell.OnIdle' `
        -MaxTriggerCount 1 -Action {
        # Update-FormatData -PrependPath "$env:OneDrive\ScriptData\Powershell\Formats\MergedFormats\formats.ps1xml"
        Update-FormatData -PrependPath "$env:PROFILEDIR\Formats\AliasInfo.ps1xml"
    }

}
Set-Alias -Name:"lD" -Value:"Invoke-Eza" -Description:"List only directories (excluding dotdirs) as a long list"
Set-Alias -Name:"la" -Value:"Invoke-Eza" -Description:"List all files (except . and ..) as a long list"
Set-Alias -Name:"ll" -Value:"Invoke-Eza" -Description:"List files as a long list"
Set-Alias -Name:"ls" -Value:"Invoke-Eza" -Description:"Plain eza call"

Function history {
    <#
    .SYNOPSIS
        Show PSReadline command history file
    .NOTES
        Depends on `bat`.
    .LINK
        https://github.com/sharkdp/bat
    #>
    bat --language powershell (Get-PSReadLineOption).HistorySavePath
}

Function which {
    <#
    .SYNOPSIS
        Get-Command -All <command>
    #>
    Get-Command -All $Args[0] -ErrorAction SilentlyContinue |
    Format-List -Property Name, Path, CommandType
}

Function Invoke-Eza {
    <#
        .SYNOPSIS
            eza a modern alternative to ls with selected configuration and aliases.
        .DESCRIPTION
            eza is a modern alternative for the venerable file-listing
            command-line program ls that ships with Unix and Linux operating
            systems, giving it more features and better defaults. It uses
            colours to distinguish file types and metadata. It knows about
            symlinks, extended attributes, and Git. And it’s small, fast, and
            just one single binary.
        .LINK
            https://eza.rocks/
        .LINK
            https://github.com/eza-community/eza
        .LINK
            Case-insenstive aliases based on the Oh-My-Zsh plugin, eza,
            https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/eza
        #>
    $Config = @(
        '--group-directories-first', # list directories before other files
        '--git', # list each file's Git status, if tracked or ignored
        '--header', # add a header row to each column
        '--icons=auto', # when to display icons (always, auto, never)
        '--hyperlink', # display entries as hyperlinks
        # how to format timestamps (default, iso, long-iso,
        # full-iso, relative, or a custom style '+<FORMAT>'
        # like '+%Y-%m-%d %H:%M')
        '--time-style=iso'
    )
    $Parameters = @{
        lD = @('-laD')
        la = @('-la')
        ll = @('-l')
        ls = @()
    }

    $Name = $MyInvocation.InvocationName
    $Options = $Parameters[$Name]
    & $(Get-Command -Name eza -CommandType Application) @Config @Options @Args
}
