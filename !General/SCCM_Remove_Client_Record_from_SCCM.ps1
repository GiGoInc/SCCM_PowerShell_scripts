D:
CD 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:
CD SS1:


$Systems = Get-Content "D:\Powershell\!SCCM_PS_scripts\!General\SCCM_Remove_Client_Record_from_SCCM--PClist.txt"
$i = 1
ForEach ($System in $Systems)
{
    Remove-CMDevice -Name $System -Force 
    Write-Host "$i --- $system --- deleted"
    $i++
}



<#
#	2014-10-17	IBL	This script doesn't work.
#					Should be rewritten with Remove-CMDevice cmdlet
#					Create list of records to delete and type each as a lint item like the next two lines:
#					Server1
#					Server2

$File = "D:\Powershell\!SCCM_PS_scripts\!General\SCCM_Remove_Client_Record_from_SCCM--PClist.txt"

function RunFunc ($computername)
{
#// required parameters
$sitename = "SS1"
#$computername = "delete-this"
Write-Output $computername

#// get resourceID of $computername
$resID = Get-WmiObject -query "select resourceID from sms_r_system where name like `'$computername`'" -Namespace "root\sms\site_$sitename"

#// get the specified computerobject based on found ID
$comp = [wmi]"\\.\root\sms\site_$sitename:sms_r_system.resourceID=$($resID.ResourceId)"

#// delete it
$comp.psbase.delete()

#// deletion successfull?
if($?) { "Successfully deleted $computer" }
else { "Could not delete $computer, error: $($error[0])"}  
}
				
(Get-Content $File) | foreach-Object {invoke-command -ScriptBlock ${function:RunFunc} -ArgumentList $_}

E:
#>