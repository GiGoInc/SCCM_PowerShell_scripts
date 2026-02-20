$SDate = $(Get-Date)
#>
$Output
$SDate = $(Get-Date)
$SSDate = $(Get-Date)
Write-Host "$SDate -- Script starting...runtime approx five minutes" -ForegroundColor Magenta
#######################################
. "C:\Scripts\!Modules\GoGoSCCM_Module_client.ps1"
$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-Location -Path "$($SiteCode.Name):\"
#######################################
    $Folder = 'D:\Powershell\!SCCM_PS_scripts\SCCM_Check_DP_Content_Status'
$ADateStart = $(Get-Date -format yyyy-MM-dd)+'__'+ $(Get-Date -UFormat %R).Replace(':','.')
       $Log = "$Folder\SCCM_Check_DP_Content_Status-Results--$ADateStart.csv"
     $TSLog = "$Folder\SCCM_Check_DP_Content_Status_TS_Results.csv"
 $FinalFile = "$Folder\SCCM_Check_DP_Content_Status-Results--$ADateStart.xlsx"
'ServerName,Name,PkgID,PackageType,StategroupName,StateGroup,State,SummaryDate,SourceSize (MB),SourceVersion' | Set-Content $Log
#########################################################################################
Write-Host "Getting DP list..." -ForegroundColor cyan	
$DPsInfo = Get-CMDistributionPoint -AllSite
$DPs = $($DPsInfo.NetworkOSPath).replace('\\','')
$DPs | Set-Content "$Folder\SCCM_Check_DP_Content_Status--DP_List.txt"
#########################################################################################
$i = 1
$Total = $DPs.count
Write-Host "Checking $total DPs...runtime approx a minute and a half" -ForegroundColor cyan	
$DPs | % {
    #write-host "$i of $total -- $_" -foregroundcolor cyan
	$SQL_Query = "select 
                   B.ServerName,
                   C.Name,
                   A.PkgID,
                   Case
                     when C.PackageType = 0 Then 'Package'
                     when C.PackageType = 3 Then 'Driver Package'
                     when C.PackageType = 4 Then 'Task Sequence Package'
                     when C.PackageType = 5 Then 'Software Update Package'
                     when C.PackageType = 6 Then 'Device Setting Package'
                     when C.PackageType = 7 Then 'Virtual Package'
                     when C.PackageType = 8 Then 'Application'
                     when C.PackageType = 257 Then 'Image'
                     when C.PackageType = 258 Then 'Boot Image'
                     when C.PackageType = 259 Then 'Operating System Install Package'
                     Else 'Unknown'
                     End as PackageType,
                   Case when A.StateGroup = 2 then 'In Progress'
                   when A.StateGroup = 1 then 'Installed' when A.StateGroup = 4 then 'Failed' end As StategroupName,
                   A.StateGroup,
                   A.State,
                   A.SummaryDate,
                   D.SourceSize/1024 AS 'SourceSize (MB)',
                   D.SourceVersion 
               from v_ContentDistribution A
               inner join v_DistributionPointInfo B on A.DPID = B.ID
               inner join v_Package C on A.PkgID = C.PackageID
               inner join v_PackageStatusRootSummarizer D on A.PkgID = D.PackageID
               where B.ServerName in ('$_')"
    
          $SQL_DB = 'CM_XX1'
      $SQL_Server = 'SERVER'
    $SQL_Instance = 'SERVER'
    $SQL_Check = Invoke-Sqlcmd -AbortOnError `
        -ConnectionTimeout 60 `
        -Database $SQL_DB  `
        -HostName $SQL_Server  `
        -Query $SQL_Query `
        -QueryTimeout 600 `
        -ServerInstance $SQL_Instance
    #########################################
    ForEach ($Item in $SQL_Check)
    {
        $Item.ServerName + ','+  `
        $Item.PkgID + ','+  `
        $Item.Name + ','+  `
        $Item.PackageType + ','+  `
        $Item.StategroupName + ','+  `
        $Item.StateGroup + ','+  `
        $Item.State + ','+  `
        $Item.SummaryDate + ','+  `
        $Item.'SourceSize (MB)' + ',' +  `
        $Item.SourceVersion | Add-Content $Log
    }
    $i++
}
######################################################################################	
######################################################################################
$EDate = (GET-DATE)
$Span = NEW-TIMESPAN –Start $SDate –End $EDate
$Min = $Span.minutes
$Sec = $Span.Seconds
Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`r`n" -ForegroundColor Cyan
$SDate = $(Get-Date)
######################################################################################	
######################################################################################
############################################################################
# List Task Sequences
$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-Location -Path "$($SiteCode.Name):\"
$TS1 = Get-CMTaskSequence
#Write-Host "Task Sequences" -ForegroundColor Yellow
# $TS1 | % {$_.PackageID + ' -- ' + $_.name}

<#
    XX100404 -- Windows 10 - MDT Newline
    XX1005EC -- HWC - Operating System Deployment v8.7.5.3
    XX10067C -- EpoTemporaryAutoboot Check
    XX100689 -- **DO NOT USE - TEST ONLY** - 1809 - UPGRADE
    XX1006A8 -- **DO NOT USE - TEST ONLY** - 1809 - NEW
    XX100724 -- **DO NOT USE - TEST ONLY** - 1809 - NEW OS ONLY
    XX100744 -- Windows 10 1909 - Upgrade OS.bak
    XX100745 -- Windows 10 1809 - PreCache-Upgrade Readiness-BAK
    XX10074A -- Windows 10 Enterprise x64 -USMT  PROD - RemoteLocale
    XX100759 -- Windows 10 (1809) - FULL INSTALL v4.9 PROD
    XX10075E -- Windows 10 (1809) - FULL INSTALL v4.7.2 PROD
    XX100766 -- Windows 10 Enterprise x64 - USMT Test - AppMapping
    XX10076C -- AOC DisplayLink USB Monitor
    XX100777 -- Windows 10 Enterprise x64 - USMT Dev
    XX10077F -- .Net 4.7.2 and IIS package for RemoteLocale Machines
    XX100785 -- IIS package(Dism) and .Net 4.7.2
    XX10078C -- Windows 10 Enterprise x64 - USMT Pilot- BackOffice
    XX100794 -- DDI TEST
    XX1007A2 -- Windows 10 1809 - PreCache-Readiness
    XX1007A3 -- Windows 10 1809 - Upgrade OS
    XX1007A9 -- Windows 10 Enterprise x64 - USMT Test - McAfeeDE
    XX1007AF -- App Mapping - No OS
    XX1007B0 -- Windows 10 1909 - PreCache-Readiness
    XX1007B1 -- Windows 10 1909 - OS Upgrade
    XX1007BA -- McAfee Testing
    XX1007BB -- Windows 10 Enterprise x64 - USMT Test - M-XX1007BB
    XX1007C5 -- * TEST - Windows 10 (1809) - FULL INSTALL v4.8 **
    XX1007CC -- Windows 10 (1809) - FULL INSTALL v4.8 PRO-XX1007CC
    XX1007CD -- Windows 10 (1809) - FULL INSTALL v4.8 Testing
    XX1007E0 -- Win10 Ent x64 - USMT - AppMapping
    XX1007E1 -- TESTING - USMT  PROD - RemoteLocale
    XX1007E4 -- TESTNG - FULL INSTALL
    XX1007F4 -- Windows 10 (1809) - FULL INSTALL v4.8 PROD - SAM
    XX1007FC -- Test Windows 10 (1809) - FULL INSTALL v4.9 PRODC
    XX1007FD -- Windows 10 (1909) - FULL INSTALL v1.7
    XX1007FF -- Windows 7 v8.7.53 - TESTCOPY
    XX100805 -- Windows 10 1909 - OS Upgrade-XX100805
    XX100825 -- 1e Test
    XX100828 -- Bitlocker Deployment
#>

# GET TS REFERENCES
$TSID = 'XX1007FD'
Write-Host "Using $TSID...runtime approx two minutes-- $_" -ForegroundColor Magenta
# Read-Host "Press any key to continue"
$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-Location -Path "$($SiteCode.Name):\"
$TS = Get-CMTaskSequence -TaskSequencePackageId $TSID
$TSRefs = $TS.references | select Package
############################################################################
Write-Host "Generating..." -ForegroundColor Green
Write-Host "$TSLog`r`n" -NoNewline -ForegroundColor Yellow
$TSOutout = @()
$TSOutout += $TSRefs.package
ForEach ($TSR in $TSRefs)
{
    If ($TSR.package -match 'ScopeId_')
    {
        $AppID = $TSR.package.split('/')[1]
        $AppName = $(. "C:\Scripts\!Modules\ConvertFrom-CMApplicationCIUniqueID.ps1" -SiteServer 'SERVER' -CIUniqueID "$AppID").DisplayName
        $TSOutout += $AppName
    }
}
$TSOutout | Set-Content $TSLog
######################################################################################	
######################################################################################
$EDate = (GET-DATE)
$Span = NEW-TIMESPAN –Start $SDate –End $EDate
$Min = $Span.minutes
$Sec = $Span.Seconds
Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`r`n" -ForegroundColor Cyan
$SDate = $(Get-Date)
######################################################################################	
######################################################################################
#####################################################################################################
Write-Host "$(get-date) ---- Generating...XLSX" -ForegroundColor Green
#####################################################################################################
# These two paths are required for Task Schedule-ing the Excel functions
    #If (!(Test-Path 'C:\Windows\System32\config\systemprofile\Desktop')){New-Item 'C:\Windows\System32\config\systemprofile\Desktop' -ItemType Directory -Force -ea SilentlyContinue}
    #If (!(Test-Path 'C:\Windows\SysWOW64\config\systemprofile\Desktop')){New-Item 'C:\Windows\SysWOW64\config\systemprofile\Desktop' -ItemType Directory -Force -ea SilentlyContinue}
#########################################################################
# Create an Excel File with a table and match code for loggedon username to Real Name
# Create XLSX
    $excel = New-Object -ComObject Excel.Application 
    $excel.Visible = $False
    $excel.DisplayAlerts = $False
#Write-Output "Create $AD_UsersXLS"
    $excel.Workbooks.Open($Log).SaveAs($FinalFile,51)
    $TSLogXlsx = $($TSLog.Replace('.csv','.xlsx'))
    $excel.Workbooks.Open($TSLog).SaveAs($TSLogXLSX,51)
#Write-Output "Open $AD_UsersXLS"
    $wb1 = $excel.Workbooks.Open($FinalFile)
    $wb2 = $excel.Workbooks.Open($TSLogXLSX)
    # $excel.quit()
# Get sheets
#Write-Output "Find sheet in $File2XLS"
    $wb1.Worksheets.Item(1).Move($wb2.Worksheets.Item(1))
    #$ws2 = $wb2.worksheets | where {$_.name -eq 'SCCM_Check_DP_Content_Status_TS'} #<------- Selects sheet 1
    #$ws2.activate()  # Activate sheet 1                                                     # close source workbook w/o saving
#Write-Output "Inserting Columns and headers"
    $ws1 = $wb2.worksheets | where {$_.name -eq 'SCCM_Check_DP_Content_Status-Re'}  #<------- Selects sheet 1
    $ws1.activate()  # Activate sheet 1
    $ColumnSelect = $ws1.Columns("E:E")
    $ColumnSelect.Insert()
    $ColumnSelect = $ws1.Columns("E:E")
    $ColumnSelect.Insert()
    $ws1.Cells.Item(1,5) ='TS IDs'
    $ws1.Cells.Item(1,6) ='TS AppNames'
# How do I select an entire row?
    $range = $ws1.Cells.Item(1,1).EntireRow
    $range.font.bold = $true # sets the top row to bold
#Write-Output "Freezing header row in $File2XLS"
# Freeze header row
    $range.application.activewindow.splitcolumn = 0
    $range.application.activewindow.splitrow = 1
    $range.application.activewindow.freezepanes = $true
#Write-Output "Making table in $File2XLS"
# Select area and make it a table
    $excel.ActiveSheet.ListObjects.add(1,$excel.ActiveSheet.UsedRange,0,1)
#Write-Output "Writing Queries"
    $ws1.cells.Item(2,5).Value() = '=INDEX(SCCM_Check_DP_Content_Status_TS!$A$2:$A$13000,MATCH(B2,SCCM_Check_DP_Content_Status_TS!$A$2:$A$13000,FALSE),1)'
    $ws1.cells.Item(2,6).Value() = '=INDEX(SCCM_Check_DP_Content_Status_TS!$A$2:$A$13000,MATCH(C2,SCCM_Check_DP_Content_Status_TS!$A$2:$A$13000,FALSE),1)'
    $excel.ActiveSheet.UsedRange.EntireColumn.AutoFit()
#################################################################################
######################################################################################	
######################################################################################
$EDate = (GET-DATE)
$Span = NEW-TIMESPAN –Start $SDate –End $EDate
$Min = $Span.minutes
$Sec = $Span.Seconds
Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`r`n" -ForegroundColor Cyan
$SDate = $(Get-Date)
######################################################################################	
######################################################################################
Write-Host "$(get-date) ---- Formatting cells" -ForegroundColor Green
    $used = $ws1.usedRange
    $lastCell = $used.SpecialCells(11)
    $lastrow = $lastCell.row 
    $i = 2
    Do 
    {
        # $ws1.cells.Item($i,5).Value()
###########################################
# Format cells
        if (($ws1.cells.Item($i,5).Value() -ne '-2146826246') -or ($ws1.cells.Item($i,6).Value() -ne '-2146826246'))
        {
            If (($ws1.cells.Item($i,7).Value() -match "Failed") -or ($ws1.cells.Item($i,7).Value() -match "In Progress"))
            {
              $ws1.Range("$($i):$($i)").interior.colorindex = 6
            }
        }                      	
        $i++
    }
    While ($i -le $lastRow)
######################################################################################	
#Write-Output "Save $wb1" 
    $wb2.SaveAs($FinalFile,51)
    $wb2.close($true) # close and save destination workbook
    $excel.quit()
Write-Host "$(get-date) ---- File saved" -ForegroundColor Green
    Start-Sleep -Seconds 2
# If(Test-Path $destfile){Remove-Item $DestFile -Force}
######################################################################################	
######################################################################################
$SEDate = (GET-DATE)
$Span = NEW-TIMESPAN –Start $SSDate –End $SEDate
$Min = $Span.minutes
$Sec = $Span.Seconds
Write-Host "$(Get-Date)`tTotal script ran for $min minutes and $sec seconds`r`n" -ForegroundColor Cyan
######################################################################################	
######################################################################################

<############################################################################
# MATCH DP PACKAGES TO TS REFERENCES
$i = 1
$Output = @()
ForEach ($Ref in $TSOutout)
{
    ForEach ($DPPKG in $DPPKGs)
    {
        $PKGName = $($DPPKG.Name).split("`t")[0]
          $PKGID = $($DPPKG.packageid).split("`t")[1]

        IF ($Ref -like $PKGID){$Output += "$PKGName";$i++}
    }
}
##############################################
$MissingRefs = $null
$MissingRefs = $RequiredRefs | ?{$Output -notcontains $_}
If ($MissingRefs -eq $null){$Output += 'All Refs are on DP'}
Else{ForEach ($MissingRef in $MissingRefs){$output += 'Missing --- ' + $MissingRef + ','}}
Set-Location -Path $env:windir
$Output
#>
