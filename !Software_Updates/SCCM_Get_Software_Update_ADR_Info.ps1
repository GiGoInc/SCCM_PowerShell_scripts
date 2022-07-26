#	2015-05-28	IBL	This script is working as expected.
#					SCCM_Get_Software_Update_ADR_list.txt needs to be formatted with each line containing ADR name like the next two lines:
#					ADR: Server Reporting - Critical patches
#					ADR: Workstations - 3rd Party Updates - Weekly
#					SCCM_Get_Software_Update_ADR_list.txt can be generated from the highlighting and 
#                       exporting list from the SCCM console > Software Updates > Automatic Deployment Rules

C:
CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:
CD SS1:

$File = "D:\Powershell\!SCCM_PS_scripts\!Software_Updates\SCCM_Get_Software_Update_ADR_list.txt"
$ADate = Get-Date -Format "yyyy_MM-dd_hh-mm-ss"
"Name,AutoDeploymentEnabled,CollectionID,Schedule" | Add-Content "D:\Powershell\!SCCM_PS_scripts\!Software_Updates\SCCM_Get_Software_Update_ADR_Results_$ADate.csv"

function RunFunc ($Lines)
{
    $ADR = Get-CMSoftwareUpdateAutoDeploymentRule -name $Lines
	
	$ADRName = $ADR.Name
	$ADREnabled = $ADR.AutoDeploymentEnabled
	$ADRCOllID = $ADR.CollectionID
	$ADRSched = $ADR.Schedule
	
	Write-Output $ADRName $ADREnabled	$ADRCOllID $ADRSched
	#"$Name,$Model,$User,$OSName,$Type,$User,$OSName,$Type" -join "," | Add-Content ".\Workstation_Check_v1_RESULTS_$ADate.csv"
	"$ADRName,$ADREnabled,$ADRCOllID,$ADRSched" -join "," | Add-Content "D:\Powershell\!SCCM_PS_scripts\!Software_Updates\SCCM_Get_Software_Update_ADR_Results_$ADate.csv"
}
(Get-Content $File) | foreach-Object {invoke-command -ScriptBlock ${function:RunFunc} -ArgumentList $_}
CD C: