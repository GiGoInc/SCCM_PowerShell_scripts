<#
$output | Sort-Object | Add-Content '.\CCMCACHE_ContentID_to_FolderName---Results.txt'
$output | Sort-Object
<#
    Add verbiage for modified date
    Add Software updates
    Add color code for non-matches


/* SQL Queries to build the CONTENTIDs.txt file */
SELECT LP.DisplayName
      ,CP.CI_ID
      ,CPS.PkgID
      ,CPS.ContentSubFolder
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

$CIDs = '.\ContentIDs.txt'

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
# $CM_CacheItems = Get-WmiObject -Namespace root\ccm\SoftMgmtAgent -Query 'SELECT ContentID,Location,ContentType FROM CacheInfoEx'
 
$CM_CacheItems = get-childitem

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
$output | Sort-Object | Add-Content '.\CCMCACHE_ContentID_to_FolderName---Results.txt'
