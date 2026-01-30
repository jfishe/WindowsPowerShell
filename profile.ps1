if (Test-Path Env:\PYTHONHOME) {
    $pythonhome = $Env:PYTHONHOME
    Remove-Item -Path Env:\PYTHONHOME
}

#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
If (Test-Path "C:\Users\jdfen\miniforge3\Scripts\conda.exe") {
    (& "C:\Users\jdfen\miniforge3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ? { $_ } | Invoke-Expression
}
#endregion

if (Test-Path Variable:pythonhome) {
    $env:PYTHONHOME = "$pythonhome"
    Remove-Variable -Name pythonhome
} else {
    $env:PYTHONHOME = "$env:APPDATA\uv\python\cpython-3.14.2-windows-x86_64-none"
}

