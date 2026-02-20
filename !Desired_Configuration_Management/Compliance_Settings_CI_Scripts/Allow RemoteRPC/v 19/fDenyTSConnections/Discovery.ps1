$Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server'
If($Val."fDenyTSConnections" -eq '0'){'Compliant'}Else{'Not-Compliant'}
$Val = Get-ItemProperty -Path $Path -Name 'fDenyTSConnections'
$Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server'
$Val = Get-ItemProperty -Path $Path -Name 'fDenyTSConnections'
If($Val."fDenyTSConnections" -eq '0'){'Compliant'}Else{'Not-Compliant'}
