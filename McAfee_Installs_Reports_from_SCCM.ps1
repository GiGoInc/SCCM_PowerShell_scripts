Function CreateAllTextXSLX ($CSVIn,$ExcelOut)
{
    # OPENCSV.PS1
    # $csv = Get-Item $args[0]
    $csv = Get-Item $CSVIn

    [string]$WSName = $csv.basename

    $excel = New-Object -ComObject excel.application
    $excel.visible = $False
    $workbook = $excel.Workbooks.Add()
    $worksheet = $workbook.worksheets.Item(1)
    $worksheet.Name = "$WSName"

    $arrFormats = ,2 * $worksheet.Cells.Columns.Count

    $TxtConnector = ("TEXT;" + $csv.fullname)
    $Connector = $worksheet.QueryTables.add($TxtConnector,$worksheet.Range("A1"))

    $query = $worksheet.QueryTables.item($Connector.name)
    $query.TextFileOtherDelimiter = $Excel.Application.International(5)
    $query.TextFileParseType  = 1
    $query.TextFileColumnDataTypes = $arrFormats
    $query.AdjustColumnWidth = 1
    $query.Refresh()
    $query.Delete()

    Remove-Item -Path $ExcelOut -Force -ErrorAction SilentlyContinue
    $worksheet.SaveAs($ExcelOut,51)    # Save destination workbook

    # Remove-Item variable:arrFormats # Gives error when included in Function.....needs looking into

    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($worksheet)
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook)
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel)
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    $excel.quit()
}

# Variables
    $ADateStart = Get-Date -Format "yyyy-MM-dd__hh.mm.ss.tt"
    $user = 'domain\user1'
    # $cred = New-Object System.Management.Automation.PsCredential $user,(Get-Content 'C:\Scripts\securestring_tsa.txt' | ConvertTo-SecureString)	
    $cred = New-Object System.Management.Automation.PsCredential $user,(Get-Content 'C:\Scripts\securestring_ats.txt' | ConvertTo-SecureString)

       $SCCMFile = "C:\Temp\SCCM_Report_original.csv"
       $SCCMEdit = "C:\Temp\SCCM_Report.csv"
        $SCCMXLS = "C:\Temp\SCCM_Report.xlsx"
       $FileFile = "D:\Projects\McAfee_Upgrades\McAfee_Installs_from_SCCM--$ADateStart.xlsx"
    $McAfeeFile1 = "D:\Projects\McAfee_Upgrades\McAfee_installs---Systems_fully_upgraded_to_all_the_latest_versions--$ADateStart.csv"

    # Remove temp files before starting
    If (Test-Path $SCCMEdit){Remove-Item -Path $SCCMEdit -Force | Out-Null}
    If (Test-Path $SCCMFile){Remove-Item -Path $SCCMFile -Force | Out-Null}
    If (Test-Path $SCCMXLS){Remove-Item -Path $SCCMXLS -Force | Out-Null}

    # Generate SCCM Report to current directory
    Write-Host "Generating SCCM report..." -NoNewline
    ##################################
        ## KEEP THIS QUERY - DO NOT DELETE
        # $postParams = @{filterwildcard='%McAfee%';CollID=$CollID}   
        # Invoke-WebRequest "http://sccmdb1/ReportServer?%2fConfigMgr_SS1%2fCorporate+Name%2fCOM+-+Computers+with+specific+software+(with+Product+Version)&rs:Command=Render&rs:Format=CSV&rc:Toolbar=False" -credential $cred -outfile $SCCMFile -Method POST -Body $postParams 
    ##################################

# SCCM Report 1
    Invoke-WebRequest "http://sccmdb1/ReportServer?%2fConfigMgr_SS1%2fIsaac%2fHW+-+McAfee+installs+-+Systems+fully+upgraded+to+all+the+latest+versions&rs:Command=Render&rs:Format=CSV&rc:Toolbar=False" -credential $cred -outfile $McAfeeFile1

# SCCM Report 2
    Invoke-WebRequest "http://sccmdb1/ReportServer?%2fConfigMgr_SS1%2fIsaac%2fHW+-+McAfee+installs+-+Systems+at+least+partially+upgraded&rs:Command=Render&rs:Format=CSV&rc:Toolbar=False" -credential $cred -outfile $SCCMFile
    D:

###############################################################################
Write-Host "`nHold onto your seats....cleaning up SCCM CSV...see ya in a bit..." -ForegroundColor Green
get-date
$objs =@();
$output = Import-csv -Path $SCCMFile
"SystemName,UserName,OSName,AppName,AppVersion,AppName --- AppVersion" | Set-Content $SCCMEdit
ForEach ($line in $Output)
{
           $SystemName = $line.Details_Table0_Netbios_Name0
             #$SiteCode = $line.Details_Table0_SiteCode
              # $Domain = $line.Details_Table0_User_Domain0
             $UserName = $line.Details_Table0_User_Name0
               $OSName = $line.Details_Table0_Operating_System_Name_and0
              $AppName = $line.Details_Table0_DisplayName0
           $AppVersion = $line.Textbox2
    $AppNameAppVersion = $line.Details_Table0_DisplayName0 + ' --- ' + $line.Textbox2
    $objs += "$SystemName, $UserName,$OSName,$AppName,$AppVersion,$AppNameAppVersion"
}
$objs | Add-Content $SCCMEdit
get-date
Write-Host "...and we are back" -ForegroundColor Green
###############################################################################


###############################################################################
# EXCEL WORK IN PROGRESS
###############################################################################
# Kill processes
    $ProcessName = "Excel"
    If ($Process = (Get-Process -Name $ProcessName -ErrorAction SilentlyContinue))
    {
    	$Process.Kill()
    }
    Write-Host "Stopped process: $($ProcessName)" -ForegroundColor Red
    Start-Sleep -Milliseconds 500

# Create Excel Workbooks from CSV - import everything as TEXT
    Write-Host "Open CSV and save them as XLSX"
    Write-Host "Create $SCCMXLS"
    CreateAllTextXSLX -CSVIn $SCCMEdit -ExcelOut $SCCMXLS
    
# Create XLS Object
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $false
    $excel.DisplayAlerts = $false

# Open Workbooks
    Write-Host "Open $SCCMXLS"
        $wbSCCM = $excel.Workbooks.Open($SCCMXLS)

#Activate Worksheet
    $Worksheet = $wbSCCM.worksheets | where {$_.name -eq "SCCM_Report--$CollID"}
    $worksheet.activate()
    Start-Sleep -Seconds 1

# Freeze header row
    Write-Host "Freezing header row in Book1"
    $worksheet.application.activewindow.splitcolumn = 0
    $worksheet.application.activewindow.splitrow = 1
    $worksheet.application.activewindow.freezepanes = $true

# Make Table
    Write-Host "Making table in Book1"
    $excel.ActiveSheet.ListObjects.add(1,$excel.ActiveSheet.UsedRange,0,1) | out-null

# Write info to worksheet
    Write-Host "Write Value to SCCM_Report sheet"
    $worksheet.cells.Item(1,8).Value() = 'AppName --- AppVersion'
    $worksheet.cells.Item(1,9).Value() = 'Counts'
    $worksheet.cells.Item(2,9).Value() = '=CountIf($F$2:$F$80000,H2)'

# Copy Column
    Write-Host "Copy column info"
    $Range = $worksheet.Range("F1").EntireColumn
# Copy unique info from column back to worksheet as another column
    Write-Host "Copy unique info from column back to worksheet as another column"
    $row = 1
    $s = $Range.Value2
    $NewInfo = $s | sort -Unique
    $NewInfo | foreach -process {
    $worksheet.Cells.Item($row,8) = $_;
    $row++
    }

# AutoFit all columns
    Write-Host "Autofit columns in Book1"
    $excel.ActiveSheet.UsedRange.EntireColumn.AutoFit() | out-null

# Find the used row count in a column or columns
    Write-Host "Getting row count of unique info"
    $rows = $worksheet.UsedRange.Rows.Count
    foreach ( $col in "H" )
    {
        $RowCount = $excel.WorksheetFunction.CountIf($worksheet.Range($col + "1:" + $col + $rows), "<>")
        Write-Host "Counted $RowCount rows"
    }

# Make another Table
Write-Host "Making table in Book1"
# Select area and make it a table
    # $excel.ActiveSheet.ListObjects.add(1,$excel.ActiveSheet.UsedRange,0,1) | out-null
    $excel.ActiveSheet.ListObjects.Add(1,$excel.ActiveSheet.Range('$H1:$I'+"$RowCount")) | out-null

Write-Host "Close and save files"
    $wbSCCM.SaveAs($FileFile)                                 # Save destination workbook
    $wbSCCM.close($true)                                      # close destination workbook
    $excel.quit()
    spps -n excel
get-date

<#
# Active sheet is already the only sheet in workbook
Write-Host "Find SCCM_Report_original in Book1"
    $ws1 = $wbSCCM.worksheets | where {$_.name -eq "SCCM_Report_original"}     # <------- Selects AD_Workstations
    $ws1.activate()  # Activate sheet 1



    Write-Host "Write Value to AD_Workstations sheet"
    $ws1 = $wbSCCM.worksheets | where {$_.name -eq "SCCM_Report"} 
    $ws1.ActiveSheet.cells.Item(2,10).Value() = '=CountIf($D$2:$D$80000,I2)'


$path = "C:\Temp\RealTimeUserInfo.xlsx" 
$Excel = New-Object -ComObject excel.application
$Excel.visible = $false
$Workbook = $excel.Workbooks.open($path)
$Worksheet = $Workbook.WorkSheets.item("outfile")
$worksheet.activate()  
$range = $WorkSheet.Range("I1").EntireColumn
$range.Copy() | out-null
$worksheet = $Workbook.Worksheets.add()
$Worksheet = $Workbook.Worksheets.item('Sheet1')
$Range = $Worksheet.Range("A1") | sort -unique
$Worksheet.Paste($range) 

Write-Host "Close and save files"
    $wbSCCM.SaveAs($FileFile)                                 # Save destination workbook
    $wbSCCM.close($true)                                      # close destination workbook
    $excel.quit()
    spps -n excel

# Close extra Workbooks
        Write-Host "Close extra Workbooks"
            $wbSCCM.close($false)                                                            # close source workbook w/o saving

# Cleanup data now that everything is in Excel
        Write-Host "Delete extra sheet Sheet1"
            $wsSheet1 = $wbNew.worksheets | where {$_.name -eq "Sheet1"} #<------- Selects sheet 1
            $wsSheet1.delete()  # Activate sheet 1

# Modify wbNew AD_Workstations sheet
        Write-Host "Find AD_Workstations in Book1"
            $ws1 = $wbNew.worksheets | where {$_.name -eq "AD_Workstations"} #<------- Selects AD_Workstations
            $ws1.activate()  # Activate sheet 1

        Write-Host "Making table in Book1"
        # Select area and make it a table
            $excel.ActiveSheet.ListObjects.add(1,$excel.ActiveSheet.UsedRange,0,1) | out-null

        # How do I select an entire row?
            $range = $ws1.Cells.Item(1,1).EntireRow
            $range.font.bold = $true # sets the top row to bold

        Write-Host "Freezing header row in Book1"
        # Freeze header row
            $range.application.activewindow.splitcolumn = 0
            $range.application.activewindow.splitrow = 1
            $range.application.activewindow.freezepanes = $true

# Create a table with header and match codes
        Write-Host "Write Value to AD_Workstations sheet"
            $ws1.cells.Item(1,2).Value() = 'UAC'
            $ws1.cells.Item(1,3).Value() = 'Operating System'
            $ws1.cells.Item(1,4).Value() = 'OS Type'
            $ws1.cells.Item(1,5).Value() = 'AD Stale'
            $ws1.cells.Item(1,6).Value() = 'Model Name'
            $ws1.cells.Item(1,7).Value() = 'Client Active Status'
            $ws1.cells.Item(1,8).Value() = 'SCCM User Name'
            $ws1.cells.Item(1,9).Value() = 'SCCM Real Name'
            $ws1.cells.Item(1,10).Value() = 'SNOW User Name'
            $ws1.cells.Item(1,11).Value() = 'SNOW Real Name'
            $ws1.cells.Item(2,4).Value() = '=INDEX(SCCM_Report!$K$2:$K$13000,MATCH(A2,SCCM_Report!$A$2:$A$13000,FALSE),1)'
            $ws1.cells.Item(2,5).Value() = '=INDEX(DSQuery_Stale_Computer_60_Days!$A$2:$A$13000,MATCH(A2,DSQuery_Stale_Computer_60_Days!$A$2:$A$13000,FALSE),1)'
            $ws1.cells.Item(2,6).Value() = '=INDEX(SCCM_Report!$H$2:$H$13000,MATCH(A2,SCCM_Report!$A$2:$A$13000,FALSE),1)'
            $ws1.cells.Item(2,7).Value() = '=INDEX(SCCM_Report!$M$2:$M$13000,MATCH(A2,SCCM_Report!$A$2:$A$13000,FALSE),1)'
            $ws1.cells.Item(2,8).Value() = '=INDEX(SCCM_Report!$B$2:$B$13000,MATCH(A2,SCCM_Report!$A$2:$A$13000,FALSE),1)'
            $ws1.cells.Item(2,9).Value() = '=INDEX(AD_Users!$C$2:$C$13000,MATCH(H2,AD_Users!$D$2:$D$13000,FALSE),1)'
            $ws1.cells.Item(2,10).Value() = '=INDEX(SNOW_Computers_by_Location!$D$2:$D$13000,MATCH(A2,SNOW_Computers_by_Location!$A$2:$A$13000,FALSE),1)'
            $ws1.cells.Item(2,11).Value() = '=INDEX(AD_Users!$C$2:$C$13000,MATCH(J2,AD_Users!$D$2:$D$13000,FALSE),1)'

        Write-Host "Autofit columns in Book1"
            $excel.ActiveSheet.UsedRange.EntireColumn.AutoFit() | out-null

        Write-Host "Close and save files"
            $wbNew.SaveAs($DestFile)                                 # Save destination workbook
            $wbNew.close($true)                                      # close destination workbook
            $excel.quit()
            spps -n excel

    # Write-Host "Copying files to current directory"
        Copy-Item -Path $DestFile -Destination $FinalFile -Force
#>