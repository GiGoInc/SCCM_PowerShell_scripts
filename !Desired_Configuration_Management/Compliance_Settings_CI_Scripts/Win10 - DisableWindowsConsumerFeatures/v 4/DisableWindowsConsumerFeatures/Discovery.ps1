$Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'
If($Val."DisableWindowsConsumerFeatures" -eq '1'){'Compliant'}Else{'Not-Compliant'}
$Val = Get-ItemProperty -Path $Path -Name 'DisableWindowsConsumerFeatures'
$Path = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'
$Val = Get-ItemProperty -Path $Path -Name 'DisableWindowsConsumerFeatures'
If($Val."DisableWindowsConsumerFeatures" -eq '1'){'Compliant'}Else{'Not-Compliant'}
