#	2014-10-09	IBL	This script is working as expected.
#					Generates list of collection members into a TXT, with each line containing a pc name name like the next two lines:
#					Server1
#					Server2


D:
CD 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:
CD SS1:

$File = "E:\Packages\Powershell_Scripts\Collection_Members.txt"

Remove-Item $File

	$Mems = Get-CMDevice -CollectionName "New Windows 7 Machines"
	foreach($Mem in $Mems)
	{
		$Output = $Mem.Name
		$Output | Add-Content $File
	}
CD E: