C:
CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:
CD SS1:

$ADate = Get-Date -Format "yyyy-MM-dd__hh.mm.ss.tt"

$CollNames  = 'Workstations - Branch', `
			  'Workstation - Branch - Group 1', `
			  'Workstation - Branch - Group 2', `
              'Workstations - Non-Branch - Group 01', `
			  'Workstations - Non-Branch - Group 02', `
			  'Workstations - Non-Branch - Group 03', `
			  'Workstations - Non-Branch - Group 04', `
			  'Workstations - Non-Branch - Group 05', `
			  'Workstations - Non-Branch - Group 06', `
			  'Workstations - Non-Branch - Group 07', `
			  'Workstations - Non-Branch - Group 08', `
			  'Workstations - Non-Branch - Group 09', `
			  'Workstations - Non-Branch - Group 10', `
			  'Workstations - Non-Branch - Group 11', `
			  'Workstations - Non-Branch - Group 12', `
			  'Workstations - Non-Branch - Group 13', `
			  'Workstations - Non-Branch - Group 14', `
			  'Workstations - Non-Branch - Group 15', `
			  'Workstations - Non-Branch - Group 16', `
			  'Workstations - Non-Branch - Group 17', `
			  'Workstations - Non-Branch - Group 18', `
			  'Workstations - Non-Branch - Group 19', `
			  'Workstations - Non-Branch - Group 20', `
			  'Workstations - Non-Branch - Group 21', `
			  'Workstations - Non-Branch - Group 22', `
			  'Workstations - Non-Branch - Group 23', `
			  'Workstations - Non-Branch - Group 24', `
			  'Workstations - Non-Branch - Group 25', `
			  'Workstations - Non-Branch - Group 26', `
			  'Workstations - Non-Branch - Group 27', `
			  'Workstations - Non-Branch - Group 28', `
              'Workstations - Non-Branch - Not in a Group'

$CollCount = $CollNames.length
$Log = "D:\Powershell\!SCCM_PS_scripts\!Collections\SCCM_Get_Collection_MemberNames_and_ResourceID--Results__$ADate.csv"
"Collection,Computer,RID" | Set-Content $Log

$i = 1
ForEach ($CollName in $CollNames)
{
    $Coll = $CollName.replace(' - ','_')
    Write-Host "Checking Collection: $i of $CollCount`t|`t$coll" -foregroundcolor yellow
    $A = Get-CMCollectionMember -CollectionName $CollName | select Name, ResourceID
    ForEach ($Item in $A)
    {
        [string]$Computer = $Item.Name
        [string]$RID = $Item.ResourceID
        "$CollName,$Computer,$RID" | Add-Content $Log
    }
    $i++
}

CD D:
CD D:\