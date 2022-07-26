D:
CD 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:
CD SS1:


$File = "E:\Packages\Powershell_Scripts\MainWindowCollectionIDs.txt"
function RunFunc ($Lines)
{
	Write-Output $Lines
	Get-CMMaintenanceWindow -CollectionId $Lines
}

(Get-Content $File) | foreach-Object {invoke-command -ScriptBlock ${function:RunFunc} -ArgumentList $_}
CD E:




Window Name	Coll ID
Alabama Call Center Workstations - 3rd Sunday	SS1000A0
Branch Workstations - 3rd Friday	SS100083
Branch Workstations - 3rd Monday	SS10007E
Branch Workstations - 3rd Saturday	SS10007C
Branch Workstations - 3rd Sunday	SS10007D
Branch Workstations - 3rd Thursday	SS100082
Branch Workstations - 3rd Tuesday	SS100080
Branch Workstations - 3rd Wednesday	SS100081
Branch Workstations - 4th Friday	SS100088
Branch Workstations - 4th Monday	SS10007F
Branch Workstations - 4th Thursday	SS100087
Branch Workstations - 4th Tuesday	SS100085
Branch Workstations - 4th Wednesday	SS100086
Branch Workstations - physical desktops	SS100174
Central Underwriting Workstations - 3rd Saturday	SS10010D
Louisiana Call Center Workstations - 3rd Friday	SS1000A1
Branch Workstation Test - 2nd Friday	SS1000E1
Branch Workstation Test - 2nd Saturday	SS1000E2
Branch Workstation Test - 2nd Thursday	SS1000E0
Branch Workstation Test - 2nd Wednesday	SS1000E3
Reporting - Branch Workstation Test	SS1000E4
Branch Workstations Maint. Window	SS10007B
Branch Workstations Maintenance Windows	SS10007A
Default Teller Workstation Maint. Window	SS100084
	
	
	
	
	
East Ocean Springs Branch	
Tchoupitoulas Street Branch	
