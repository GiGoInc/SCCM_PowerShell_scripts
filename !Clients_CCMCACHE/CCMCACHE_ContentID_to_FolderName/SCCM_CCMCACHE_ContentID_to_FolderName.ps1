<#
$output | Sort-Object | Add-Content 'D:\Powershell\!SCCM_PS_scripts\!Clients_CCMCACHE\CCMCACHE_ContentID_to_FolderName\CCMCACHE_ContentID_to_FolderName---Results.txt'
$output | Sort-Object
<#
    Add verbiage for modified date
    Add Software updates
    Add color code for non-matches


/* SQL Queries to build the CONTENTIDs.txt file */
SELECT LP.DisplayName,CP.CI_ID,CPS.PkgID,CPS.ContentSubFolder
FROM CI_ContentPackages CPS
INNER JOIN CIContentPackage CP ON CPS.PkgID = CP.PkgID
LEFT OUTER JOIN CI_LocalizedProperties LP ON CP.CI_ID = LP.CI_ID
ORDER BY LP.LocaleID DESC



/* 
                      SCCM Console Title: Adobe Acrobat XI (11.0.19)
           SCCM Console Unique Update ID: d9bb425e-d523-4da5-aadc-e9c64fd681a2
          v_CIToContent.Content_UniqueID: d9bb425e-d523-4da5-aadc-e9c64fd681a2
     CI_ContentPackages.Content_UniqueID: d9bb425e-d523-4da5-aadc-e9c64fd681a2
*/
SELECT Distinct UI.Title
	  ,UI.CI_ID
      ,CIC.CI_UniqueID
FROM v_CIToContent CIC
Join v_UpdateInfo UI On CIC.CI_ID = UI.CI_ID
ORDER BY UI.CI_ID Asc


#>


$CIDs = 'D:\Powershell\!SCCM_PS_scripts\!Clients_CCMCACHE\CCMCACHE_ContentID_to_FolderName\ContentIDs.txt'

# Match the VLAN to the SubnetChoice in the IPAM 'sections'
$GetRowInfo_Server = "SERVER"
$GetRowInfo_Instance = "SERVER"
$GetRowInfo_DB  = 'CM_XX1'
$GetRowInfo_Table = 'CI_ContentPackages'
$GetRowInfo_Query = "SELECT LP.DisplayName,CP.CI_ID,CPS.PkgID,CPS.ContentSubFolder FROM CI_ContentPackages CPS INNER JOIN CIContentPackage CP ON CPS.PkgID = CP.PkgID LEFT OUTER JOIN CI_LocalizedProperties LP ON CP.CI_ID = LP.CI_ID ORDER BY LP.LocaleID DESC"

# Run SQl
    $GetRowInfo_QueryInvoke = Invoke-Sqlcmd -AbortOnError `
        -ConnectionTimeout 60 `
        -Database $GetRowInfo_DB  `
        -HostName $GetRowInfo_Server  `
        -Query $GetRowInfo_Query `
        -QueryTimeout 600 `
        -ServerInstance $GetRowInfo_Instance

"DisplayName;CI_ID;PkgID;ContentSubFolder" | Set-Content $CIDs
ForEach ($Item in $GetRowInfo_QueryInvoke)
{
    $DN = $Item.DisplayName
    $CI = $Item.CI_ID
    $PI = $Item.PkgID
    $CF = $Item.ContentSubFolder

    "$DN;$CI;$PI;$CF" | Add-Content $CIDs
}



# Check for ContentIDs File
    If (!(Test-Path $CIDs))
    {
        Write-Host ""
        Write-Host "Hey, dum dum it doesn't look like the file " -NoNewline -ForegroundColor Cyan  
        Write-host "$CIDs " -ForegroundColor Green -NoNewline
        Write-Host "exists..." -ForegroundColor Cyan  
        Write-Host ""
        Write-Host "You need to create the ContentIDs file from that other script....you know the one..." -ForegroundColor Green
        Write-Host ""
        Write-Host "Action cancelled." -ForegroundColor Red
        Read-Host -Prompt 'Press Enter to exit...'
        Exit
    }

#Get list of all non persisted content in CCMcache, only this content will be removed 
$CM_CacheItems = Get-WmiObject -Namespace root\ccm\SoftMgmtAgent -Query 'SELECT ContentID,Location,ContentType FROM CacheInfoEx'
 
# #Get list of updates 
# $CM_Updates = Get-WmiObject -Namespace root\ccm\SoftwareUpdates\UpdatesStore -Query 'SELECT UniqueID,Title,Status FROM CCM_UpdateStatus' 
#  
# #Get list of applications 
# $CM_Applications = Get-WmiObject -Namespace root\ccm\ClientSDK -Query 'SELECT * FROM CCM_Application' 
#  
# #Get list of packages 
# $CM_Packages = Get-WmiObject -Namespace root\ccm\ClientSDK -Query 'SELECT PackageID,PackageName,LastRunStatus,RepeatRunBehavior FROM CCM_Program' 
 

$output = @()
# Check for installed applications (adapted) 
    ForEach ($CM_CacheItem in $CM_CacheItems)
    {
        If ($CM_CacheItems.Count -ne $null)
        {
            [string]$F = $CM_CacheItem.Location
            [string]$ID = $CM_CacheItem.ContentId
            $Type = $CM_CacheItem.ContentType
            $Folder = $F.Replace('C:\WINDOWS\ccmcache\','')
            $line = Get-Content $CIDs | Where-Object { $_ -match $ID }  |  Select-Object -Last 1
            If ($line -ne $null)
            {
                     $DisplayName = $line.split(';')[0]
                           $CI_ID = $line.split(';')[1]
                           $PkgID = $line.split(';')[2]
                $ContentSubFolder = $line.split(';')[3]
                              $LW = Get-ItemPropertyValue -Name LastWriteTime -Path $F
                # $output += ("$Folder - $DisplayName - $Type - $ID")
                $output += ("$Folder - $LW - $DisplayName")

            }
            Else
            {
                $output += ("$Folder - COULDN'T MATCH NAME")
            }
        } 
    }

$output | Sort-Object
$output | Sort-Object | Add-Content 'D:\Powershell\!SCCM_PS_scripts\!Clients_CCMCACHE\CCMCACHE_ContentID_to_FolderName\CCMCACHE_ContentID_to_FolderName---Results.txt'
