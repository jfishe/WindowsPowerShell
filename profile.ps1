
#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
If (Test-Path "$env:USERPROFILE\miniforge3\Scripts\conda.exe") {
    (& "$env:USERPROFILE\miniforge3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
}
Enter-CondaEnvironment -Name vim-python
#endregion
