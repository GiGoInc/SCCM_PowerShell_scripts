D:
#>
Default APP2 Workstation Maint. Window	XX100084
D:
CD 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location XX1:
CD XX1:


$File = "E:\Packages\Powershell_Scripts\MainWindowCollectionIDs.txt"
function RunFunc ($Lines)
{
	Write-Output $Lines
	Get-CMMaintenanceWindow -CollectionId $Lines
}

(Get-Content $File) | foreach-Object {invoke-command -ScriptBlock ${function:RunFunc} -ArgumentList $_}
CD E:

<#


Window Name	Coll ID
State1 Call Center Workstations - 3rd Sunday	XX1000A0
RemoteLocale Workstations - 3rd Friday	XX100083
RemoteLocale Workstations - 3rd Monday	XX10007E
RemoteLocale Workstations - 3rd Saturday	XX10007C
RemoteLocale Workstations - 3rd Sunday	XX10007D
RemoteLocale Workstations - 3rd Thursday	XX100082
RemoteLocale Workstations - 3rd Tuesday	XX100080
RemoteLocale Workstations - 3rd Wednesday	XX100081
RemoteLocale Workstations - 4th Friday	XX100088
RemoteLocale Workstations - 4th Monday	XX10007F
RemoteLocale Workstations - 4th Thursday	XX100087
RemoteLocale Workstations - 4th Tuesday	XX100085
RemoteLocale Workstations - 4th Wednesday	XX100086
RemoteLocale Workstations - physical desktops	XX100174
Central Underwriting Workstations - 3rd Saturday	XX10010D
State2 Call Center Workstations - 3rd Friday	XX1000A1
RemoteLocale Workstation Test - 2nd Friday	XX1000E1
RemoteLocale Workstation Test - 2nd Saturday	XX1000E2
RemoteLocale Workstation Test - 2nd Thursday	XX1000E0
RemoteLocale Workstation Test - 2nd Wednesday	XX1000E3
Reporting - RemoteLocale Workstation Test	XX1000E4
RemoteLocale Workstations Maint. Window	XX10007B
RemoteLocale Workstations Maintenance Windows	XX10007A
Default APP2 Workstation Maint. Window	XX100084
#>
