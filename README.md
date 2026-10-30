# PowerShell Core Profile

## PowerShell Core Profile Installation

`Install-Profile` installs module `PSDepend` and
uses `Invoke-PSDepend` to install the modules
in [`profile.Depend.psd1`](profile.Depend.psd1).
Argument completers live in the `Completions` submodule
([jfishe/powershell-completions](https://github.com/jfishe/powershell-completions)).

```powershell
# Assume Documents\PowerShell does not exist.
$ProfileDir = Split-Path "$PROFILE"
git clone https://github.com/jfishe/PowerShell.git "$ProfileDir"

if ($?) {
    pushd $ProfileDir
    git submodule update --init
    .\Install-Profile.ps1
} else {
    Write-Error -Message "Failed to install $ProfileDir"
}
```

## Profile Overview

The profile only configures interactive `ConsoleHost` sessions;
`-NonInteractive` sessions skip it.

- PSReadLine:
  - vi edit mode with cursor-shape mode indicator,
  - incremental history without duplicates,
  - `ListView` predictions from history,
  - `Ctrl+w` (`BackwardDeleteWord`), and
  - `Ctrl+Spacebar` (`MenuComplete`).
- [`Alias.ps1`](Alias.ps1): aliases and alias-like functions.
- `DirColors` and `git-aliases` are imported once PSReadLine is idle
  (`PowerShell.OnIdle`); `posh-git` is imported on the first `git <Tab>`.

## Starship Prompt

[Starship: Cross-Shell Prompt](https://starship.rs/) works well in Z-Shell,
PowerShell and PowerShell Core.
The prompt setup is skipped when `starship` is not on `PATH`.

`starship init powershell --print-full-init` is cached to
`Profile.Starship.ps1` (gitignored) on first run. After upgrading Starship,
delete the cache to regenerate it:

```powershell
Remove-Item "$env:PROFILEDIR\Profile.Starship.ps1"
```

## Colors (tinty)

[tinty](https://github.com/tinted-theming/tinty) hooks in WSL write
`Profile.Tinty.ps1` (tinted-psreadline, gitignored) and
`~\.dircolors` (tinted-dircolors).
`Update-TintyColors` reloads either file at each prompt
when its time stamp changes,
so `tinty apply` recolors open sessions.

`DirColors` colors any non-link reparse point as a block device (`BLK`).
OneDrive items are reparse points,
so the profile patches out that fallback and
colors them as normal files and directories.

## Windows Terminal Shell Integration

The profile wraps the Starship `prompt` and `PSConsoleHostReadLine`
to emit escape sequences that Windows Terminal understands.

### OSC 9;9: Current Directory

`Invoke-Starship-PreCommand` emits `OSC 9;9;"<path>"`
with the current FileSystem location at each prompt,
so `duplicateTab` and `splitPane` open in the same directory.
See
[Tutorial: Opening a tab or pane in the same directory in Windows Terminal](https://learn.microsoft.com/en-us/windows/terminal/tutorials/new-tab-same-directory#powershell-with-starship).

WindowsTerminal default `commandline` for `wsl` includes `--cd ~`,
which overrides the current directory.
Setting `"startingDirectory": "~"` opens in `$HOME`,
when `OSC9;9;` is not set to current directory.

### OSC 133: Semantic Prompt Marks

See
[Shell integration in Windows Terminal](https://learn.microsoft.com/en-us/windows/terminal/tutorials/shell-integration).

| Mark          | Emitted by              | Meaning                          |
| ------------- | ----------------------- | -------------------------------- |
| `133;A`       | `prompt`                | Prompt start                     |
| `133;B`       | `prompt`                | Command start (end of prompt)    |
| `133;C`       | `PSConsoleHostReadLine` | Command output start             |
| `133;D;<rc>`  | next `prompt`           | Command finished with exit code  |

- `D` is only emitted after a non-blank command line;
  its exit code is `0` on success,
  else `$LASTEXITCODE`, else `1`.
- PSReadLine redraws the prompt on vi mode changes; `A`/`D` are emitted once
  per new prompt, not on redraws.
- `$?` and `$LASTEXITCODE` are preserved so Starship reports the correct
  status.

The marks enable scrolling between prompts,
selecting command output and exit-code marks on the scrollbar.
Windows Terminal settings live outside this repository;
enable `"autoMarkPrompts": true` and `"showMarksOnScrollbar": true`
in the profile defaults to use them.

## PowerShell Core Installation and Update

[Installing PowerShell on Windows](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows)
describes the Microsoft recommended method.

```powershell
winget install --id Microsoft.PowerShell
```

## License

[MIT](LICENSE). Third-party material is credited in
[`THIRD-PARTY-NOTICES.md`](THIRD-PARTY-NOTICES.md).
