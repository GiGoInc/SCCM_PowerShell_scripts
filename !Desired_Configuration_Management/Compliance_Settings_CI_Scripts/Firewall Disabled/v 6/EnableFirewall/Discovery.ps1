$Path1 = 'HKLM:\SYSTEM\CurrentControlSet\services\SharedAccess\Parameters\FirewallPolicy\StandardProfile'
If($val1."EnableFirewall" -eq '0'){'Compliant'}Else{'Not-Compliant'}
$val1 = Get-ItemProperty -Path $Path1 -Name 'EnableFirewall'
$Path1 = 'HKLM:\SYSTEM\CurrentControlSet\services\SharedAccess\Parameters\FirewallPolicy\StandardProfile'
$val1 = Get-ItemProperty -Path $Path1 -Name 'EnableFirewall'
If($val1."EnableFirewall" -eq '0'){'Compliant'}Else{'Not-Compliant'}
