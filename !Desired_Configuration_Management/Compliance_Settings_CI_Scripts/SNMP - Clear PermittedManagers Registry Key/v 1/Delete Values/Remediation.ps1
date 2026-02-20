$RegPath1 = "HKLM:\SYSTEM\CurrentControlSet\services\SNMP\Parameters\PermittedManagers"
Else{REG DELETE "HKLM\SYSTEM\CurrentControlSet\services\SNMP\Parameters\PermittedManagers" /va /f}
{Write-Host 'Compliant'}
$RegPath1 = "HKLM:\SYSTEM\CurrentControlSet\services\SNMP\Parameters\PermittedManagers"
$Values = Get-Item $RegPath1
$VP = $Values.Property
If ($VP.Length -eq '0')
{Write-Host 'Compliant'}
Else{REG DELETE "HKLM\SYSTEM\CurrentControlSet\services\SNMP\Parameters\PermittedManagers" /va /f}
