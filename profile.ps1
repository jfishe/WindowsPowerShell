[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
# $OutputEncoding = [System.Text.UTF8Encoding]::new()
# [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$Global:PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$Global:PSDefaultParameterValues['Set-Content:Encoding'] = 'utf8'
$Global:PSDefaultParameterValues['Export-Csv:Encoding'] = 'utf8'
