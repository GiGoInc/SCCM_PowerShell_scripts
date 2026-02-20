$Path1 = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\NameSpace\{025A5937-A6BE-4686-A844-36FE4BEC8B6D}'
If($val1.PreferredPlan -eq '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'){'Compliant'}Else{'Not-Compliant'}
$val1 = Get-ItemProperty -Path $Path1 -Name 'PreferredPlan'
$Path1 = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\NameSpace\{025A5937-A6BE-4686-A844-36FE4BEC8B6D}'
$val1 = Get-ItemProperty -Path $Path1 -Name 'PreferredPlan'
If($val1.PreferredPlan -eq '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'){'Compliant'}Else{'Not-Compliant'}
