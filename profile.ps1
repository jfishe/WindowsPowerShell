[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
# $OutputEncoding = [System.Text.UTF8Encoding]::new()
# [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$Global:PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$Global:PSDefaultParameterValues['Set-Content:Encoding'] = 'utf8'
$Global:PSDefaultParameterValues['Export-Csv:Encoding'] = 'utf8'

#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
If (Test-Path "$env:USERPROFILE\miniforge3\Scripts\conda.exe") {
    (& "$env:USERPROFILE\miniforge3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
}
Enter-CondaEnvironment -Name vim-python
#endregion
