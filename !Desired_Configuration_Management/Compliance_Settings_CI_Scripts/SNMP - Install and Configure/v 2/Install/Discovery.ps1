$RegPath1 = "HKLM:\SYSTEM\CurrentControlSet\services\SNMP"
Else{Write-Host 'Non-Compliant'}
{Write-Host 'Compliant'}
$RegPath1 = "HKLM:\SYSTEM\CurrentControlSet\services\SNMP"
$Values = Get-Item $RegPath1
$VP = $Values.Property
If ($VP.Length -ne '0')
{$SNMPInstalled = 'Compliant'}
Else{$SNMPInstalled = 'Non-Compliant'}
####################################################################################################
$RegPath1 = "HKLM:\SYSTEM\CurrentControlSet\services\SNMP\Parameters\PermittedManagers"
$Values = Get-Item $RegPath1
$VP = $Values.Property
If ($VP.Length -eq '0')
{$PermittedManagers = 'Compliant'}
Else{$PermittedManagers = 'Non-Compliant'}
####################################################################################################
$RegPath1 = "HKLM:\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities"
$Values = Get-Item $RegPath1
$VP = $Values.Property
If ($VP -eq 'hbnet1' -and $VP.Length -eq '1')
{$ValidCommunities = 'Compliant'}
Else{$ValidCommunities = 'Non-Compliant'}
####################################################################################################
If ($ValidCommunities -eq "Compliant")
{
    $val = Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities
    $SecurityRight =  $val.hbnet1
    Switch ($securityRight)
    {
        "1"  { $securityRight = 'NONE' }
        "2"  { $securityRight = 'NOTIFY' }
        "4"  { $securityRight = 'READ-ONLY' }
        "8"  { $securityRight = 'READ-WRITE' }
        "16" { $securityRight = 'READ-CREATE' }
    }
}
#################################################################################################
$RegPath1 = "HKLM:\SYSTEM\CurrentControlSet\services\SNMP\Parameters\TrapConfiguration"
$Values = Get-Item "$RegPath1\*"
If ($Values.Count -eq '1' -and $Values -eq 'hbnet1')
{$TrapConfiguration = 'Compliant'}
Else{$TrapConfiguration = 'Non-Compliant'}
#################################################################################################
$RegPath1 = "HKLM:\SYSTEM\CurrentControlSet\services\SNMP\Parameters"
$Values = Get-ItemProperty -Path $RegPath1 -Name EnableAuthenticationTraps
If ($values.EnableAuthenticationTraps -eq '0')
{
    $EnableAuthenticationTraps = "Disabled"
}
ElseIf ($values.EnableAuthenticationTraps -eq '1')
{
    $EnableAuthenticationTraps = "Enabled"
}
#################################################################################################
If (($SNMPInstalled -eq 'Compliant') -and `
   ($PermittedManagers -eq 'Compliant') -and `
   ($ValidCommunities -eq 'Compliant') -and `
   ($SecurityRight -eq 'READ-ONLY') -and `
   ($TrapConfiguration -eq 'Compliant') -and `
   ($EnableAuthenticationTraps -eq 'Enabled'))
{Write-Host 'Compliant'}
Else{Write-Host 'Non-Compliant'}
