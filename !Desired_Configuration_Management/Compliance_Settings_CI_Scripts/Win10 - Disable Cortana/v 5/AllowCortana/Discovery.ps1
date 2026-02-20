$Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'
If($Val."AllowCortana" -eq '0'){'Compliant'}Else{'Not-Compliant'}
$Val = Get-ItemProperty -Path $Path -Name 'AllowCortana'
$Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search'
$Val = Get-ItemProperty -Path $Path -Name 'AllowCortana'
If($Val."AllowCortana" -eq '0'){'Compliant'}Else{'Not-Compliant'}
