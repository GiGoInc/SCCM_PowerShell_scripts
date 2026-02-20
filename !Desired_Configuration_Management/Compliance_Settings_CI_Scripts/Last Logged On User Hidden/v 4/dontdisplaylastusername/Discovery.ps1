$Path1 = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
If($val1."dontdisplaylastusername" -eq '1'){'Compliant'}Else{'Not-Compliant'}
$val1 = Get-ItemProperty -Path $Path1 -Name 'dontdisplaylastusername'
$Path1 = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
$val1 = Get-ItemProperty -Path $Path1 -Name 'dontdisplaylastusername'
If($val1."dontdisplaylastusername" -eq '1'){'Compliant'}Else{'Not-Compliant'}
