cls
#>

cls
##############################
$SiteCode = "XX1"
$SiteServer = "SERVER.DOMAIN.COM"

$SCCMPaths = 'C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin\ConfigurationManager.psd1', "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"            
$SCCMPaths | % { If (Test-Path "$_") { Import-Module "$_"  -Force }}

if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
New-PSDrive -name $SiteCode -psprovider CMSite  -Root $SiteServer 
}
Set-Location "$($SiteCode):\"


######################################################################################################
######################################################################################################

$ADate = Get-Date -Format "yyyy-MM-dd__hh.mm.ss.tt"
$DestFile = "D:\Powershell\!SCCM_PS_scripts\!Collections\Maintenance_Windows\SCCM_Get_Maintenance_Windows-$ADate.csv"
If (Test-Path -Path $DestFile ){Remove-Item -Path $DestFile -Force}
"Name,CollectionID,MemberCount,LimitToCollectionName,LimitToCollectionID,ServiceWindowsCount,Comment" -join "," | Add-Content $DestFile
##############################################
$SDate = (GET-DATE)
Write-Host "$(Get-Date)`t--`tGetting Collection information...estimated runtime is five minutes"

$a = Get-CMCollection -Name * | Select-Object Name,CollectionID,MemberCount,LimitToCollectionName,LimitToCollectionID,ServiceWindowsCount,Comment

$EDate = (GET-DATE)
$Span = NEW-TIMESPAN –Start $SDate –End $EDate
$Min = $Span.minutes
$Sec = $Span.Seconds
Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
##############################################

ForEach ($B in $A)
{
      $CollName = $B.Name
        $CollID = $B.CollectionID
      $MemCount = $B.MemberCount
    $ToCollName = $B.LimitToCollectionName
      $ToCollID = $B.LimitToCollectionID
           $SwC = $B.ServiceWindowsCount
       $Comment = $B.Comment
 
    #Write-Host $CollName $MemCount $CollID $ToCollName $ToCollID $SwC $Comment
    "$CollName,$CollID,$MemCount,$ToCollName,$ToCollID,$SwC,$Comment" -join "," | Add-Content $DestFile
}

######################################################################################################
######################################################################################################

$Lines = Get-Content $DestFile
ForEach ($Line in $Lines)
{ 
    If ($line -match "MW - Windows Servers")
    {
        $CollName = $Line.split(',')[0]
          $CollID = $Line.split(',')[1]
        "$CollID -- $CollName"

	    Get-CMMaintenanceWindow -CollectionId $CollID
    }
}



<#

Window Name	Coll ID
Alabama Call Center Workstations - 3rd Sunday	XX1000A0
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
Louisiana Call Center Workstations - 3rd Friday	XX1000A1
RemoteLocale Workstation Test - 2nd Friday	XX1000E1
RemoteLocale Workstation Test - 2nd Saturday	XX1000E2
RemoteLocale Workstation Test - 2nd Thursday	XX1000E0
RemoteLocale Workstation Test - 2nd Wednesday	XX1000E3
Reporting - RemoteLocale Workstation Test	XX1000E4
RemoteLocale Workstations Maint. Window	XX10007B
RemoteLocale Workstations Maintenance Windows	XX10007A
Default APP2 Workstation Maint. Window	XX100084
	
	
	
	
	
East Ocean Springs RemoteLocale	
Tchoupitoulas Street RemoteLocale	


#>
