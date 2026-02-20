$ADate = Get-Date -Format "yyyy-MM-dd__hh.mm.ss.tt"
	If (Test-Path $AD_UsersXLS){Remove-Item -Path $AD_UsersXLS -Force | Out-Null}
	If (Test-Path $AD_Users){Remove-Item -Path $AD_Users -Force | Out-Null}
$ADate = Get-Date -Format "yyyy-MM-dd__hh.mm.ss.tt"

 #Get current working paths
$CurrentDirectory = split-path $MyInvocation.MyCommand.Path

 # Variables for file log creation

$creds = Get-Credential DOMAIN\SUPERUSER

   $SCCMFile = "C:\Temp\SCCM_Report.csv"
   $SCCMEdit = "C:\Temp\SCCM_Report2.csv"   
    $SCCMXLS = "C:\Temp\SCCM_Report.xlsx"

   $MidFile0 = "C:\Temp\AD_00_Computers.csv"
   $MidFile1 = "C:\Temp\01_AD_Enabled_Workstations.csv"
      $AD_PC = "C:\Temp\AD_Workstations.csv"
   $AD_PCXLS = "C:\Temp\AD_Workstations.xlsx"

    $AD_Users = "C:\Temp\AD_Users.csv"
 $AD_UsersXLS = "C:\Temp\AD_Users.xlsx"

   $DestFile = "C:\Temp\AD_SCCM_Compiler--Results_$ADate.xlsx"
  $FinalFile = "$CurrentDirectory\AD_SCCM_Compiler--Results_$ADate.xlsx"

 # Variables for CSVDE
$CompRVar = 'objectCategory=computer'
$CompLVar = 'cn,userAccountControl,operatingSystem'
$UserRVar = 'objectCategory=person'
$UserLVar = 'objectClass,displayName,sAMAccountName'


 #Remove temp files before starting
	If (Test-Path $SCCMFile){Remove-Item -Path $SCCMFile -Force | Out-Null}
	If (Test-Path $SCCMEdit){Remove-Item -Path $SCCMEdit -Force | Out-Null}
	If (Test-Path $SCCMXLS){Remove-Item -Path $SCCMXLS -Force | Out-Null}
	If (Test-Path $MidFile0){Remove-Item -Path $MidFile0 -Force | Out-Null}
	If (Test-Path $MidFile1){Remove-Item -Path $MidFile1 -Force | Out-Null}
	If (Test-Path $AD_PC){Remove-Item -Path $AD_PC -Force | Out-Null}
	If (Test-Path $AD_PCXLS){Remove-Item -Path $AD_PCXLS -Force | Out-Null}
	If (Test-Path $AD_Users){Remove-Item -Path $AD_Users -Force | Out-Null}
	If (Test-Path $AD_UsersXLS){Remove-Item -Path $AD_UsersXLS -Force | Out-Null}

 # Create header on $AD_PC
"PC Name,UAC,Operating System,Service Pack" | Add-Content -Path $AD_PC

 # Generate SCCM Report to current directory
Write-Output "Generating SCCM report..."
    Invoke-WebRequest "http://SERVER/ReportServer?%2fConfigMgr_XX1%2fDOMAIN+Part2%2fCOM+-+The+Works+(Machine+to+User+match)&rs:Command=Render&rs:Format=CSV&rc:Toolbar=False" -credential $creds -outfile $SCCMFile

 # Generate AD computers list
Write-Output "Generating AD PC Workstations report..."
    CSVDE.exe -f $MidFile0 -r $CompRVar -l $CompLVar

 # Generate AD Users list
Write-Output "Generating AD USers report..."
    CSVDE.exe -f $AD_Users -r $UserRVar -l $UserLVar


 # Separate out workstation lines
Write-Output "Separate out workstation lines from $MidFile0"
    If (Test-Path -Path $MidFile0){$Line = Select-String -Path $MidFile0 -pattern "Windows 7 Enterprise","Windows 7 Professional","Windows 7 Ultimate","Windows 8 Enterprise","Windows 8.1 Enterprise","Windows 8.1 Pro","Windows Embedded Standard","Windows Technical Preview for Enterprise","Windows XP Professional" | Add-Content -Path $Midfile1 -Force}

 # Separate out extra data
Write-Output "Check $Midfile1 and extract out computernames"
    Start-Sleep -s 3
    $Lines = Get-Content $Midfile1
    ForEach ($midstring in $Lines)
    {
        $string = $midstring -replace 'DC=COM",',';'
        $separator = ';'
        $parts = $string.split($separator)[1]
             #$parts = $string.split($separator)[1].split(',')[0]
        $parts -join "," | Add-Content -Path $AD_PC
             # Write-Output "$parts"
    }

start-sleep -Milliseconds 500

 # Cleanup AD_users
Write-Output "Cleaning up the usernames in the SCCM report"
    Get-Content $SCCMFile | % { $_ -replace 'DOMAIN\\', '' } | Set-Content $SCCMEdit

 # Create XLS
            $excel = New-Object -ComObject Excel.Application
            $excel.Visible = $false
            $excel.DisplayAlerts = $false
            $wbNew = $excel.Workbooks.Add()
            $shNew = $wbNew.ActiveSheet

        Write-Output "Open CSV and save them as XLSX"
            $excel.Workbooks.Open($AD_Users).SaveAs($AD_UsersXLS,51)
        Write-Output "Create $AD_PCXLS"
            $excel.Workbooks.Open($AD_PC).SaveAs($AD_PCXLS,51)
        Write-Output "Create $SCCMXLS"
            $excel.Workbooks.Open($SCCMEdit).SaveAs($SCCMXLS,51)

  # Combine workbooks
        Write-Output "Open $AD_UsersXLS"
            $wbUser = $excel.Workbooks.Open($AD_UsersXLS)
        Write-Output "Open $AD_PCXLS"
            $wbPC = $excel.Workbooks.Open($AD_PCXLS)
        Write-Output "Open $AD_PCXLS"
            $wbSCCM = $excel.Workbooks.Open($SCCMXLS)

        Write-Output "Copy sheet from $AD_UsersXLS"
            $sh1_wbUser = $wbNew.sheets.item(1)                           # first sheet in destination workbook
            $sheetToCopy = $wbUser.sheets.item('AD_Users')                # source sheet to copy
            $sheetToCopy.copy($sh1_wbUser)                                # copy source sheet to destination workbook

        Write-Output "Copy sheet from $SCCMXLS"
            $sh1_wbSCCM = $wbNew.sheets.item(1)                           # first sheet in destination workbook
            $sheetToCopy = $wbSCCM.sheets.item('SCCM_Report2')             # source sheet to copy
            $sheetToCopy.copy($sh1_wbSCCM)                                # copy source sheet to destination workbook

        Write-Output "Copy sheet from $AD_PCXLS"
            $sh1_wbPC = $wbNew.sheets.item(1)                             # first sheet in destination workbook
            $sheetToCopy = $wbPC.sheets.item('AD_Workstations')           # source sheet to copy
            $sheetToCopy.copy($sh1_wbPC)                                  # copy source sheet to destination workbook

 # Close extra Workbooks
        Write-Output "Close extra Workbooks"
              $wbPC.close($false)                                         # close source workbook w/o saving
            $wbUser.close($false)                                         # close source workbook w/o saving
            $wbSCCM.close($false)                                         # close source workbook w/o saving

 # Modify wbNew AD_Workstations sheet
        Write-Output "Find AD_Workstations in Book1"
            $ws1 = $wbNew.worksheets | where {$_.name -eq "AD_Workstations"}  #<------- Selects AD_Workstations
            $ws1.activate()   # Activate sheet 1

        Write-Output "Making table in Book1"
         # Select area and make it a table
            $excel.ActiveSheet.ListObjects.add(1,$excel.ActiveSheet.UsedRange,0,1) | out-null

         # How do I select an entire row?
            $range = $ws1.Cells.Item(1,1).EntireRow
            $range.font.bold = $true  # sets the top row to bold

        Write-Output "Freezing header row in Book1"
         # Freeze header row
            $range.application.activewindow.splitcolumn = 0
            $range.application.activewindow.splitrow = 1
            $range.application.activewindow.freezepanes = $true

 # Create a table with header and match codes
        Write-Output "Write Value to AD_Workstations sheet"
            $ws1.cells.Item(1,2).Value() = 'UAC'
            $ws1.cells.Item(1,3).Value() = 'Operating System'
            $ws1.cells.Item(1,4).Value() = 'OS Type'
            $ws1.cells.Item(2,4).Value() = '=INDEX(SCCM_Report2!$K$2:$K$13000,MATCH(A2,SCCM_Report2!$A$2:$A$13000,FALSE),1)'
            $ws1.cells.Item(1,5).Value() = 'Model Name'
            $ws1.cells.Item(2,5).Value() = '=INDEX(SCCM_Report2!$H$2:$H$13000,MATCH(A2,SCCM_Report2!$A$2:$A$13000,FALSE),1)'
            $ws1.cells.Item(1,6).Value() = 'Client Active Status'
            $ws1.cells.Item(2,6).Value() = '=INDEX(SCCM_Report2!$M$2:$M$13000,MATCH(A2,SCCM_Report2!$A$2:$A$13000,FALSE),1)'
            $ws1.cells.Item(1,7).Value() = 'User Name'
            $ws1.cells.Item(2,7).Value() = '=INDEX(SCCM_Report2!$B$2:$B$13000,MATCH(A2,SCCM_Report2!$A$2:$A$13000,FALSE),1)'
            $ws1.cells.Item(1,8).Value() = 'Real Name'
            $ws1.cells.Item(2,8).Value() = '=INDEX(AD_Users!$C$2:$C$13000,MATCH(G2,AD_Users!$D$2:$D$13000,FALSE),1)'

        Write-Output "Autofit columns in Book1"
            $excel.ActiveSheet.UsedRange.EntireColumn.AutoFit() | out-null


        Write-Output "Delete extra sheet Sheet1"
            $wsSheet1 = $wbNew.worksheets | where {$_.name -eq "Sheet1"}  #<------- Selects sheet 1
            $wsSheet1.delete()   # Activate sheet 1

        Write-Output "Close and save files" 
            $wbNew.SaveAs($DestFile)                                      # Save destination workbook
             $wbNew.close($true)                                          # close destination workbook
            $excel.quit()
            spps -n excel

        Write-Output "Copying files to current directory" 
            Copy-Item -Path $DestFile -Destination $FinalFile -Force

 #Remove temp after completed
	If (Test-Path $SCCMFile){Remove-Item -Path $SCCMFile -Force | Out-Null}
	If (Test-Path $SCCMEdit){Remove-Item -Path $SCCMEdit -Force | Out-Null}
	If (Test-Path $SCCMXLS){Remove-Item -Path $SCCMXLS -Force | Out-Null}
	If (Test-Path $MidFile0){Remove-Item -Path $MidFile0 -Force | Out-Null}
	If (Test-Path $MidFile1){Remove-Item -Path $MidFile1 -Force | Out-Null}
	If (Test-Path $AD_PC){Remove-Item -Path $AD_PC -Force | Out-Null}
	If (Test-Path $AD_PCXLS){Remove-Item -Path $AD_PCXLS -Force | Out-Null}
	If (Test-Path $AD_Users){Remove-Item -Path $AD_Users -Force | Out-Null}
	If (Test-Path $AD_UsersXLS){Remove-Item -Path $AD_UsersXLS -Force | Out-Null}
