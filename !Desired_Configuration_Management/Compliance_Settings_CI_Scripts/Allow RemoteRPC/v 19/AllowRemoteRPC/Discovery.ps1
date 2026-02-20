$Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server'
If($Val."AllowRemoteRPC" -eq '1'){'Compliant'}Else{'Not-Compliant'}
$Val = Get-ItemProperty -Path $Path -Name 'AllowRemoteRPC'
$Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server'
$Val = Get-ItemProperty -Path $Path -Name 'AllowRemoteRPC'
If($Val."AllowRemoteRPC" -eq '1'){'Compliant'}Else{'Not-Compliant'}
