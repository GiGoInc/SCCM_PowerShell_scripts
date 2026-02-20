cls
Start-Sleep -Seconds 10
Write-Host "`n$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
cls

########################################################################################################################################
# FUNCTIONS
########################################################################################################################################
Function CreateAllTextXSLX ($CSVIn,$ExcelOut) {
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

Function Test-ADCredential {
    [CmdletBinding()]
    Param
    (
        [string]$UserName,
        [string]$Password
    )
    If (!($UserName) -or !($Password))
    {
        Write-Warning 'Test-ADCredential: Please specify both user name and password'
    }
    Else
    {
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
        $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('domain')
        $DS.ValidateCredentials($UserName, $Password)
    }
}

Function Variables {
    ########################################################################################################################################  
    # VARIABLES
    ########################################################################################################################################
    $Global:ADate = Get-Date -Format "yyyy-MM-dd__hh.mm.ss.tt"
    $Global:SDate = Get-Date

    #1 AD USER VARIABLES
           $Global:UserRVar = 'objectCategory=person'
           $Global:UserLVar = 'objectClass,displayName,sAMAccountName,mail'  
           $Global:AD_Users = "C:\Temp\AD_Users.csv"
        $Global:AD_UsersXLS = "C:\Temp\AD_Users.xlsx"

    #2 AD COMPUTER VARIABLES
         $Global:CompRVar = 'objectCategory=computer'
         $Global:CompLVar = 'cn,whencreated,userAccountControl,operatingSystem'
         $Global:MidFile0 = "C:\Temp\AD_00_Computers.csv"
        $Global:MidFile00 = "C:\Temp\AD_00_Windows_Systems.csv"
         $Global:MidFile1 = "C:\Temp\01_AD_Enabled_Workstations.csv"
            $Global:AD_PC = "C:\Temp\AD_Workstations.csv"
         $Global:AD_PCXLS = "C:\Temp\AD_Workstations.xlsx"

    #3 AD STALE PC VARIABLES
                $Global:DSQ = "computer -stalepwd 60 > $Global:AD_StalePC -limit 0"
         $Global:AD_StalePC = "C:\Temp\DSQuery_Stale_Computer_60_Days_orginal.csv"
     $Global:AD_StalePCEdit = "C:\Temp\DSQuery_Stale_Computer_60_Days.csv"
      $Global:AD_StalePCXLS = "C:\Temp\DSQuery_Stale_Computer_60_Days.xlsx"

    #4 SCCM - ADOBE VARIABLES
         $Global:SCCMAdobeFile = "C:\Temp\SCCM_ADOBE_Report.csv"
        $Global:SCCMAdobe_Mod1 = "C:\Temp\SCCM_ADOBE_Report_Edit1.csv"
        $Global:SCCMAdobe_Mod2 = "C:\Temp\SCCM_ADOBE_Report_Edit2.csv"
         $Global:SCCMAdobeEdit = "C:\Temp\SCCM_ADOBE_Report.csv"
          $Global:SCCMAdobeXLS = "C:\Temp\SCCM_ADOBE_Report.xlsx"
  
    #4 SCCM - CHROME VARIABLES
         $Global:SCCMChromeFile = "C:\Temp\SCCM_CHROME_Report.csv"
        $Global:SCCMChrome_Mod1 = "C:\Temp\SCCM_CHROME_Report_Edit1.csv"
        $Global:SCCMChrome_Mod2 = "C:\Temp\SCCM_CHROME_Report_Edit2.csv"
         $Global:SCCMChromeEdit = "C:\Temp\SCCM_CHROME_Report.csv"
          $Global:SCCMChromeXLS = "C:\Temp\SCCM_CHROME_Report.xlsx"

    #4 SCCM - EDGE VARIABLES
         $Global:SCCMEdgeFile = "C:\Temp\SCCM_EDGE_Report.csv"
        $Global:SCCMEdge_Mod1 = "C:\Temp\SCCM_EDGE_Report_Edit1.csv"
        $Global:SCCMEdge_Mod2 = "C:\Temp\SCCM_EDGE_Report_Edit2.csv"
         $Global:SCCMEdgeEdit = "C:\Temp\SCCM_EDGE_Report.csv"
          $Global:SCCMEdgeXLS = "C:\Temp\SCCM_EDGE_Report.xlsx" 

    #4 SCCM - JAVA VARIABLES
          $Global:SCCMJavaFile = "C:\Temp\SCCM_JAVA_Report.csv"
         $Global:SCCMJava_Mod1 = "C:\Temp\SCCM_JAVA_Report_Edit1.csv"
         $Global:SCCMJava_Mod2 = "C:\Temp\SCCM_JAVA_Report_Edit2.csv"
          $Global:SCCMJavaEdit = "C:\Temp\SCCM_JAVA_Report.csv"
           $Global:SCCMJavaXLS = "C:\Temp\SCCM_JAVA_Report.xlsx" 

        # FINAL FILES VARIABLES
           $Global:DestFile = "C:\Temp\AD_SCCM_Compiler--Results_$ADate.xlsx"
          $Global:FinalFile = "D:\Powershell\AD_SCCM_SNOW_Compiler\AD_SCCM_Compiler--Results_$ADate.xlsx"

    cd 'D:\Powershell\AD_SCCM_SNOW_Compiler'
    D:
}

#0 ROLL OUT
Function GoGoStartingScript {
    Write-Host 'Checking variables and copying initial files...' -ForegroundColor Cyan

########################################################################################################################################
# Remove temp files before starting 
########################################################################################################################################
    If (Test-Path $SCCMAdobeFile)    { Remove-Item -Path $SCCMAdobeFile -Force | Out-Null }
    If (Test-Path $SCCMChromeFile)   { Remove-Item -Path $SCCMChromeFile -Force | Out-Null }
    If (Test-Path $SCCMEdgeFile)     { Remove-Item -Path $SCCMEdgeFile -Force | Out-Null }
    If (Test-Path $SCCMJavaFile)     { Remove-Item -Path $SCCMJavaFile -Force | Out-Null }

    # FINAL FILES VARIABLES           
    If (Test-Path $DestFile)          { Remove-Item -Path $DestFile -Force | Out-Null }
    If (Test-Path $FinalFile)         { Remove-Item -Path  $FinalFile -Force | Out-Null }

    ########################################################################################################################################
    # OPENING COMMENTS
    ########################################################################################################################################

    Write-Host ''
    Write-Host "Ready to start running AD to SCCM to SNOW compile jobs!!!"
    Write-Host ''
    Write-Host 'This will only run under an account with SCCM access.' -ForegroundColor Cyan
    Write-Host ''
    Write-Host 'THIS WILL ONLY RUN UNDER AN ACCOUNT WITH SCCM ACCESS!!!' -ForegroundColor Green
    Write-Host ''
    Write-Host ''
    Write-Host "This  WILL kill all running Excel instances, so save your work and close all Excel before pressing Enter!!!" -ForegroundColor Magenta
    Write-Host ''
    Write-Host ''
    Write-Host "READY?" -ForegroundColor Cyan
    Write-Host ''
    Read-Host -Prompt "Press Enter to continue or CTRL+C to quit" 

    Write-Host "$SDate --- script starting..." -ForegroundColor Yellow

    ########################################################################################################################################
    # Use saved password are $Cred
    ########################################################################################################################################
    $user = 'DOMAIN\aUSER1'
    $PassFile = "C:\Scripts\ats_securestring.txt"
    # Check for Password file
        If (!(Test-Path $PassFile))
                                                                                        {
        Write-Host ""
        Write-Host "Hey, dum dum it doesn't look like the password file " -NoNewline -ForegroundColor Cyan  
        Write-host "C:\Scripts\ats_securestring.txt " -ForegroundColor Green  -NoNewline
        Write-Host "exists..." -ForegroundColor Cyan  
        Write-Host ""
        Write-Host "You need to either generate it like this: " -ForegroundColor Cyan
        Write-Host ""
        Write-Host '# Create encrypted password'
        Write-Host "Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File `"$PassFile`""
        Write-Host ""
        Write-Host "....or modify it's location in this script!!!" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Also, make sure you change the username for the file from " -NoNewline -ForegroundColor Green
        Write-Host "`"$user`" " -NoNewline -ForegroundColor Red
        Write-Host "to yours!!!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Action cancelled." -ForegroundColor Red
        Read-Host -Prompt 'Press Enter to exit...'
        Exit
    }

    $ErrorActionPreference = 'Stop'
    Try { $cred = New-Object System.Management.Automation.PsCredential $user,(Get-Content $PassFile | ConvertTo-SecureString) }
                            Catch { 
        $errr = [string]$error[0]
        Write-Host "`n`nERROR: $errr"  -ForegroundColor Red
        Write-Host 'Recreate encrypted password:'
        Write-Host "Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File `"$PassFile`"" -ForegroundColor Green
        Exit
    }
    Finally { $ErrorActionPreference = 'Continue' }



# Kill Excel
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $false
    $excel.DisplayAlerts = $false
    $excel.quit()
    spps -n excel | Out-Null
}

#1 AD USER
Function ADUsers {
########################################################################################################################################
    Write-Host "$(Get-Date)`t--`tGenerating $AD_Users..." -NoNewLine -ForegroundColor Yellow
        Start-Process -FilePath 'CSVDE.exe' -ArgumentList ("-f $AD_Users -r $UserRVar -l $UserLVar") -Wait
    Write-Host "done." -ForegroundColor Green
########################################################################################################################################
}

#2 AD COMPUTER
Function ADPC { 
########################################################################################################################################
# Generate AD computers list
Write-Host "$(Get-Date)`t--`tGenerating $MidFile0 report..." -NoNewLine -ForegroundColor Yellow
    Start-Process -FilePath 'CSVDE.exe' -ArgumentList ("-f $MidFile0 -r $CompRVar -l $CompLVar") -Wait
    Write-Host "done." -ForegroundColor Green
    Start-Sleep -s 2

    $Records = @()
    $ADRecords = Import-Csv $MidFile0

    ForEach ($Record in $ADRecords)
    {
        $first                      = $Record.DN.split(',')[0]
        $DN                         = $($Record.DN -replace "^$first").trimstart(',')
        $cn                         = $Record.cn                                  
        $whenCreated                = $Record.whenCreated.Substring(0,4) + '-' + $Record.whenCreated.Substring(4,2) + '-' + $Record.whenCreated.Substring(6,2)        
        $userAccountControl         = $Record.userAccountControl        
        $operatingSystem            = $Record.operatingSystem           

        If ($operatingSystem -eq "X'57696e646f7773205669737461e284a220427573696e657373'") { $operatingSystem = 'Windows Vista Business' }
        ElseIf ($operatingSystem -eq "X'57696e646f777320536572766572c2ae2032303038205374616e646192.420776974686f75742048797065722d56'") { $operatingSystem = 'Windows Server 2008 Standard without Hyper-V' }
        ElseIf ($operatingSystem -eq "X'57696e646f777320536572766572c2ae2032303038205374616e646192.4'") { $operatingSystem = 'Windows Server 2008 Standard' }
        ElseIf ($operatingSystem -eq "X'57696e646f777320536572766572c2ae203230303820456e7465727072697365'") { $operatingSystem = 'Windows Server 2008 Enterprise' }
        Else {$operatingSystem = $operatingSystem }
        
            If ($userAccountControl -eq "4096")     { $userAccountControl = 'WORKSTATION_TRUST_ACCOUNT' }
        ElseIf ($userAccountControl -eq "4096")     { $userAccountControl = 'DISABLED - WORKSTATION_TRUST_ACCOUNT' }
        ElseIf ($userAccountControl -eq "4128")     { $userAccountControl = 'WORKSTATION TRUST ACCOUNT, PASSWORD NOT REQUIRED' }
        ElseIf ($userAccountControl -eq "4130")     { $userAccountControl = 'DISABLED - WORKSTATION TRUST ACCOUNT, PASSWORD NOT REQUIRED' }
        ElseIf ($userAccountControl -eq "16781312") { $userAccountControl = 'WORKSTATION_TRUST_ACCOUNT - TRUSTED_TO_AUTH_FOR_DELEGATION' }
        ElseIf ($userAccountControl -eq "528384")   { $userAccountControl = 'ENABLE UNCONSTRAINED DELEGATION' }		
        ElseIf ($userAccountControl -eq "532480")   { $userAccountControl = 'DOMAIN CONTROLLER' }
        ElseIf ($userAccountControl -eq "69632")    { $userAccountControl = 'WORKSTATION TRUST ACCOUNT - DONT_EXPIRE_PASSWORD' }		 
          Else {$userAccountControl = $userAccountControl }			
		
		
        $Records += '"' + $DN + '","' + $cn + '","' + $userAccountControl + '","' + $operatingSystem + '","' + $whenCreated + '","' + $whenChanged + '","' + $description + '"'
    }
    $LineCount = $ADRecords.count
	Write-Output "$ADate`tCompiled $LineCount AD machines"
	Start-Sleep -s 3  

    'DN,cn,whenCreated,userAccountControl,operatingSystem' | Set-Content "$AD_PC"
    $Records | Add-Content "$AD_PC"
}

#4 SCCM ADOBE
Function SCCMAdobe { 
########################################################################################################################################
    Write-Host "$(Get-Date)`t--`tGenerating $SCCMAdobeFile..." -NoNewLine -ForegroundColor Yellow
    $SQL_Query = "
    select SYS.Netbios_Name0, OS.Caption0, SF.FileName, SF.FileDescription, SF.FileVersion, SF.FileSize, SF.FileModifiedDate, SF.FilePath 
    From v_GS_SoftwareFile  SF 
    join v_R_System  SYS on SYS.ResourceID = SF.ResourceID
    join v_GS_OPERATING_SYSTEM  OS on SYS.ResourceID = OS.ResourceID
    Where (OS.Caption0 = 'Microsoft Windows 10 Enterprise' OR  OS.Caption0 = 'Microsoft Windows 11 Enterprise') AND 
	    SF.FileName LIKE 'AcroRd32.exe'
    ORDER BY SF.FileVersion desc"
##########################################################################
      $SQL_DB = 'CM_XX1'
  $SQL_Server = 'SERVER'
$SQL_Instance = 'SERVER'
##########################################################################
   $SQL_Check = Invoke-Sqlcmd -ConnectionTimeout 60 `
        -Database $SQL_DB  `
        -HostName $SQL_Server  `
        -Query $SQL_Query `
        -QueryTimeout 600 `
        -ServerInstance $SQL_Instance
##########################################################################
    'Netbios Name, Operating System,File Name,File Description,File Version,File Size,File Modified Date,File Path' | Set-Content $SCCMAdobeFile

    $output = @()
    ForEach ($Check in $SQL_Check)
    {
        [string]$Netbios_Name0    = $Check."Netbios_Name0"
        [string]$Caption0         = $Check."Caption0"
        [string]$FileName         = $Check."FileName"
        [string]$FileDescription  = $Check."FileDescription"
        [string]$FileVersion      = $Check."FileVersion"
        [string]$FileSize         = $Check."FileSize"
        [string]$FileModifiedDate = $Check."FileModifiedDate"
        [string]$FilePath         = $Check."FilePath"

         $output += '"' + $Netbios_Name0     + '","' + `
                          $Caption0          + '","' + `
                          $FileName          + '","' + `
                          $FileDescription   + '","' + `
                          $FileVersion       + '","' + `
                          $FileSize          + '","' + `
                          $FileModifiedDate  + '","' + `
                          $FilePath          + '"'
    }
    $output | Add-Content $SCCMAdobeFile
    Write-Host "done." -ForegroundColor Green
########################################################################################################################################
}

#4 SCCM CHROME
Function SCCMChrome { 
########################################################################################################################################
    Write-Host "$(Get-Date)`t--`tGenerating $SCCMChromeFile..." -NoNewLine -ForegroundColor Yellow
    $SQL_Query = "
    select SYS.Netbios_Name0, OS.Caption0, SF.FileName, SF.FileDescription, SF.FileVersion, SF.FileSize, SF.FileModifiedDate, SF.FilePath 
    From v_GS_SoftwareFile  SF 
    join v_R_System  SYS on SYS.ResourceID = SF.ResourceID
    join v_GS_OPERATING_SYSTEM  OS on SYS.ResourceID = OS.ResourceID
    Where (OS.Caption0 = 'Microsoft Windows 10 Enterprise' OR  OS.Caption0 = 'Microsoft Windows 11 Enterprise') AND 
	    SF.FileName LIKE 'Chrome.exe' 
    ORDER BY SF.FilePath"
##########################################################################
      $SQL_DB = 'CM_XX1'
  $SQL_Server = 'SERVER'
$SQL_Instance = 'SERVER'
##########################################################################
   $SQL_Check = Invoke-Sqlcmd -ConnectionTimeout 60 `
        -Database $SQL_DB  `
        -HostName $SQL_Server  `
        -Query $SQL_Query `
        -QueryTimeout 600 `
        -ServerInstance $SQL_Instance
##########################################################################
    'Netbios Name, Operating System,File Name,File Description,File Version,File Size,File Modified Date,File Path' | Set-Content $SCCMChromeFile

    $output = @()
    ForEach ($Check in $SQL_Check)
    {
        [string]$Netbios_Name0    = $Check."Netbios_Name0"
        [string]$Caption0         = $Check."Caption0"
        [string]$FileName         = $Check."FileName"
        [string]$FileDescription  = $Check."FileDescription"
        [string]$FileVersion      = $Check."FileVersion"
        [string]$FileSize         = $Check."FileSize"
        [string]$FileModifiedDate = $Check."FileModifiedDate"
        [string]$FilePath         = $Check."FilePath"

        If ($FileVersion -match "^[6-9].*") { $FileVersion = "0" + $FileVersion }

         $output += '"' + $Netbios_Name0     + '","' + `
                          $Caption0          + '","' + `
                          $FileName          + '","' + `
                          $FileDescription   + '","' + `
                          $FileVersion       + '","' + `
                          $FileSize          + '","' + `
                          $FileModifiedDate  + '","' + `
                          $FilePath          + '"'
    }
    $output | Add-Content $SCCMChromeFile
    Write-Host "done." -ForegroundColor Green
    ########################################################################################################################################
}

#4 SCCM EDGE
Function SCCMEdge { 
########################################################################################################################################
    Write-Host "$(Get-Date)`t--`tGenerating $SCCMEdgeFile..." -NoNewLine -ForegroundColor Yellow
    $SQL_Query = "
    select SYS.Netbios_Name0, OS.Caption0, SF.FileName, SF.FileDescription, SF.FileVersion, SF.FileSize, SF.FileModifiedDate, SF.FilePath 
    From v_GS_SoftwareFile  SF 
    join v_R_System  SYS on SYS.ResourceID = SF.ResourceID
    join v_GS_OPERATING_SYSTEM  OS on SYS.ResourceID = OS.ResourceID
    Where (OS.Caption0 = 'Microsoft Windows 10 Enterprise' OR  OS.Caption0 = 'Microsoft Windows 11 Enterprise') AND 
	    SF.FileName LIKE 'msEdge.exe'
    ORDER BY SF.FilePath"
##########################################################################
      $SQL_DB = 'CM_XX1'
  $SQL_Server = 'SERVER'
$SQL_Instance = 'SERVER'
##########################################################################
   $SQL_Check = Invoke-Sqlcmd -ConnectionTimeout 60 `
        -Database $SQL_DB  `
        -HostName $SQL_Server  `
        -Query $SQL_Query `
        -QueryTimeout 600 `
        -ServerInstance $SQL_Instance
##########################################################################
    'Netbios Name, Operating System,File Name,File Description,File Version,File Size,File Modified Date,File Path' | Set-Content $SCCMEdgeFile

    $output = @()
    ForEach ($Check in $SQL_Check)
    {
        [string]$Netbios_Name0    = $Check."Netbios_Name0"
        [string]$Caption0         = $Check."Caption0"
        [string]$FileName         = $Check."FileName"
        [string]$FileDescription  = $Check."FileDescription"
        [string]$FileVersion      = $Check."FileVersion"
        [string]$FileSize         = $Check."FileSize"
        [string]$FileModifiedDate = $Check."FileModifiedDate"
        [string]$FilePath         = $Check."FilePath"

        If ($FileVersion -match "^[6-9].*") { $FileVersion = "0" + $FileVersion }

         $output += '"' + $Netbios_Name0     + '","' + `
                          $Caption0          + '","' + `
                          $FileName          + '","' + `
                          $FileDescription   + '","' + `
                          $FileVersion       + '","' + `
                          $FileSize          + '","' + `
                          $FileModifiedDate  + '","' + `
                          $FilePath          + '"'
    }
    $output | Add-Content $SCCMEdgeFile
    Write-Host "done." -ForegroundColor Green
########################################################################################################################################
}

#4 SCCM JAVA
Function SCCMJava { 
########################################################################################################################################
    Write-Host "$(Get-Date)`t--`tGenerating $SCCMJavaFile..." -NoNewLine -ForegroundColor Yellow
$SQL_Query = "
    select SYS.Netbios_Name0, OS.Caption0, SF.FileName, SF.FileDescription, SF.FileVersion, SF.FileSize, SF.FileModifiedDate, SF.FilePath 
    From v_GS_SoftwareFile  SF 
    join v_R_System  SYS on SYS.ResourceID = SF.ResourceID
    join v_GS_OPERATING_SYSTEM  OS on SYS.ResourceID = OS.ResourceID
    Where (OS.Caption0 = 'Microsoft Windows 10 Enterprise' OR  OS.Caption0 = 'Microsoft Windows 11 Enterprise') AND 
	    SF.FileName LIKE 'java.exe' and 
	    SF.FileDescription = 'Java(TM) Platform SE binary' AND
	    SF.FilePath NOT LIKE 'C:\$Recycle.Bin%' AND
	    SF.FilePath NOT LIKE 'C:\Program Files\CUDeviceManager\jre\bin'
    ORDER BY SF.FilePath"
##########################################################################
      $SQL_DB = 'CM_XX1'
  $SQL_Server = 'SERVER'
$SQL_Instance = 'SERVER'
##########################################################################
   $SQL_Check = Invoke-Sqlcmd -ConnectionTimeout 60 `
        -Database $SQL_DB  `
        -HostName $SQL_Server  `
        -Query $SQL_Query `
        -QueryTimeout 600 `
        -ServerInstance $SQL_Instance
##########################################################################
    'Netbios Name, Operating System,File Name,File Description,File Version,File Size,File Modified Date,File Path' | Set-Content $SCCMJavaFile

    $output = @()
    ForEach ($Check in $SQL_Check)
    {
        [string]$Netbios_Name0    = $Check."Netbios_Name0"
        [string]$Caption0         = $Check."Caption0"
        [string]$FileName         = $Check."FileName"
        [string]$FileDescription  = $Check."FileDescription"
        [string]$FileVersion      = $Check."FileVersion"
        [string]$FileSize         = $Check."FileSize"
        [string]$FileModifiedDate = $Check."FileModifiedDate"
        [string]$FilePath         = $Check."FilePath"

        If ($FileVersion -match "^[6-9].*") { $FileVersion = "0" + $FileVersion }

         $output += '"' + $Netbios_Name0     + '","' + `
                          $Caption0          + '","' + `
                          $FileName          + '","' + `
                          $FileDescription   + '","' + `
                          $FileVersion       + '","' + `
                          $FileSize          + '","' + `
                          $FileModifiedDate  + '","' + `
                          $FilePath          + '"'
    }
    $output | Add-Content $SCCMJavaFile
    Write-Host "done." -ForegroundColor Green
########################################################################################################################################
}

# Finalize
Function ExcelFun {
########################################################################################################################################
# EXCEL WORK IN PROGRESS
########################################################################################################################################
########################################################################################################################################
# Kill processes
    $ProcessName = "Excel"
    If ($Process = (Get-Process -Name $ProcessName -ErrorAction SilentlyContinue)) { $Process.Kill() }
    Write-Host "Stopped process: $($ProcessName)" -ForegroundColor Red
    Start-Sleep -Milliseconds 500


Write-Host "$(Get-Date)`t--`tGenerating Excel files..." -NoNewline -ForegroundColor Yellow
# Create Excel Workbooks from CSV - import everything as TEXT
            CreateAllTextXSLX -CSVIn $SCCMAdobeFile -ExcelOut $SCCMAdobeXLS | Out-Null
            CreateAllTextXSLX -CSVIn $SCCMChromeFile -ExcelOut $SCCMChromeXLS | Out-Null
            CreateAllTextXSLX -CSVIn $SCCMEdgeFile -ExcelOut $SCCMEdgeXLS | Out-Null
            CreateAllTextXSLX -CSVIn $SCCMJavaFile -ExcelOut $SCCMJavaXLS | Out-Null
            # $FinalFile

Write-Host "done." -ForegroundColor Green

Write-Host "$(Get-Date)`t--`tOpening Excel files..." -NoNewline -ForegroundColor Yellow
# Create XLS Object
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $False
    $excel.DisplayAlerts = $False
    $wbNew = $excel.Workbooks.Add()
    $shNew = $wbNew.ActiveSheet

# Open Workbooks
        $wbAdobe   = $excel.Workbooks.Open($SCCMAdobeXLS)
        $wbChrome  = $excel.Workbooks.Open($SCCMChromeXLS)
        $wbEdge    = $excel.Workbooks.Open($SCCMEdgeXLS)
        $wbJava    = $excel.Workbooks.Open($SCCMJavaXLS)	
Write-Host "done." -ForegroundColor Green

##################################################################################################################
#1 ADOBE VARIABLES
##################################################################################################################
    Write-Host "Copy sheet from $SCCMAdobeXLS..." -NoNewline -ForegroundColor Yellow
        $sh1_wbAdobe = $wbNew.sheets.item(1)                                              # first sheet in destination workbook
        $sheetToCopy = $wbAdobe.sheets.item('SCCM_ADOBE_Report')                          # source sheet to copy
        $sheetToCopy.copy($sh1_wbAdobe)                                                   # copy source sheet to destination workbook
    Write-Host "done." -ForegroundColor Green
#########################################################
    Write-Host "`tMaking table..." -NoNewline 
    # Select area and make it a table
        $excel.ActiveSheet.ListObjects.add(1,$excel.ActiveSheet.UsedRange,0,1) | out-null
        $TableName = $($excel.ActiveSheet.ListObjects).DisplayName
        $excel.ActiveSheet.ListObjects("$TableName").TableStyle = "TableStyleMedium2"
    # How do I select an entire row?cls
        $range = $sh1_wbAdobe.Cells.Item(1,1).EntireRow
        $range.font.bold = $true # sets the top row to bold
    Write-Host "done." -ForegroundColor Green
    Write-Host "`tFreezing header row.." -NoNewline
    # Freeze header row
        $range.application.activewindow.splitcolumn = 0
        $range.application.activewindow.splitrow = 1
        $range.application.activewindow.freezepanes = $true
    Write-Host "done." -ForegroundColor Green
    Write-Host "`tAutofit columns..." -NoNewline 
        $excel.ActiveSheet.UsedRange.EntireColumn.AutoFit() | out-null
    Write-Host "done." -ForegroundColor Green
    Start-Sleep -Seconds 1
##################################################################################################################
#3 CHROME VARIABLES
##################################################################################################################
    Write-Host "Modify sheet from $SCCMChromeXLS..." -ForegroundColor Yellow
        $sh1_wbEdge = $wbNew.sheets.item(1)                                           # first sheet in destination workbook
        $sheetToCopy = $wbEdge.sheets.item('SCCM_CHROME_Report')                      # source sheet to copy
        $sheetToCopy.copy($sh1_wbChrome)                                              # copy source sheet to destination workbook
#########################################################
    Write-Host "`tMaking table..." -NoNewline 
    # Select area and make it a table
        $excel.ActiveSheet.ListObjects.add(1,$excel.ActiveSheet.UsedRange,0,1) | out-null
        $TableName = $($excel.ActiveSheet.ListObjects).DisplayName
        $excel.ActiveSheet.ListObjects("$TableName").TableStyle = "TableStyleMedium3"
    # How do I select an entire row?
        $range = $sh1_wbEdge.Cells.Item(1,1).EntireRow
        $range.font.bold = $true # sets the top row to bold
    Write-Host "done." -ForegroundColor Green
    Write-Host "`tFreezing header row.." -NoNewline
    # Freeze header row
        $range.application.activewindow.splitcolumn = 0
        $range.application.activewindow.splitrow = 1
        $range.application.activewindow.freezepanes = $true
    Write-Host "done." -ForegroundColor Green
    Write-Host "`tAutofit columns..." -NoNewline 
        $excel.ActiveSheet.UsedRange.EntireColumn.AutoFit() | out-null
    Write-Host "done." -ForegroundColor Green
    Start-Sleep -Seconds 1
##################################################################################################################
#4 EDGE VARIABLES
##################################################################################################################
    Write-Host "Modify sheet from $SCCMEdgeXLS..." -ForegroundColor Yellow
        $sh1_wbJava = $wbNew.sheets.item(1)                                             # first sheet in destination workbook
        $sheetToCopy = $wbJava.sheets.item('SCCM_EDGE_Report')                          # source sheet to copy
        $sheetToCopy.copy($sh1_wbEdge)                                                  # copy source sheet to destination workbook
#########################################################
    Write-Host "`tMaking table..." -NoNewline 
    # Select area and make it a table
        $excel.ActiveSheet.ListObjects.add(1,$excel.ActiveSheet.UsedRange,0,1) | out-null
        $TableName = $($excel.ActiveSheet.ListObjects).DisplayName
        $excel.ActiveSheet.ListObjects("$TableName").TableStyle = "TableStyleMedium6"
    # How do I select an entire row?
        $range = $sh1_wbJava.Cells.Item(1,1).EntireRow
        $range.font.bold = $true # sets the top row to bold
    Write-Host "done." -ForegroundColor Green
    Write-Host "`tFreezing header row.." -NoNewline
    # Freeze header row
        $range.application.activewindow.splitcolumn = 0
        $range.application.activewindow.splitrow = 1
        $range.application.activewindow.freezepanes = $true
    Write-Host "done." -ForegroundColor Green
    Write-Host "`tAutofit columns..." -NoNewline 
        $excel.ActiveSheet.UsedRange.EntireColumn.AutoFit() | out-null
    Write-Host "done." -ForegroundColor Green
    Start-Sleep -Seconds 1
##################################################################################################################
#5 JAVA VARIABLES
##################################################################################################################
    Write-Host "Modify sheet from $SCCMJavaXLS..." -ForegroundColor Yellow
        $sh1_wbSNOW = $wbNew.sheets.item(1)                                              # first sheet in destination workbook
        $sheetToCopy = $wbSNOW.sheets.item('SCCM_JAVA_Report')                           # source sheet to copy
        $sheetToCopy.copy($sh1_wbJava)                                                   # copy source sheet to destination workbook
#########################################################
    Write-Host "`tMaking table..." -NoNewline 
    # Select area and make it a table
        $excel.ActiveSheet.ListObjects.add(1,$excel.ActiveSheet.UsedRange,0,1) | out-null
        $TableName = $($excel.ActiveSheet.ListObjects).DisplayName
        $excel.ActiveSheet.ListObjects("$TableName").TableStyle = "TableStyleMedium7"
    # How do I select an entire row?
        $range = $sh1_wbSNOW.Cells.Item(1,1).EntireRow
        $range.font.bold = $true # sets the top row to bold
    Write-Host "done." -ForegroundColor Green
    Write-Host "`tFreezing header row.." -NoNewline
    # Freeze header row
        $range.application.activewindow.splitcolumn = 0
        $range.application.activewindow.splitrow = 1
        $range.application.activewindow.freezepanes = $true
    Write-Host "done." -ForegroundColor Green
    Write-Host "`tAutofit columns..." -NoNewline 
        $excel.ActiveSheet.UsedRange.EntireColumn.AutoFit() | out-null
    Write-Host "done." -ForegroundColor Green
    Start-Sleep -Seconds 1
##################################################################################################################
#2 AD COMPUTER VARIABLES - MUST BE PROCESSED LAST. THIS IS THE MASTER SHEET
##################################################################################################################
    Write-Host "Modify sheet from $AD_PCXLS..." -ForegroundColor Yellow
        $sh1_wbChrome = $wbNew.sheets.item(1)                                                # first sheet in destination workbook
        $sheetToCopy = $wbChrome.sheets.item('AD_Workstations')                          # source sheet to copy
        #$sheetToCopy.name = 'AD_Workstations'                                           # rename sheet to copy
        $sheetToCopy.copy($sh1_wbChrome)                                                     # copy source sheet to destination workbook
#########################################################
    Write-Host "`tMaking table..." -NoNewline 
    # Select area and make it a table
        $excel.ActiveSheet.ListObjects.add(1,$excel.ActiveSheet.UsedRange,0,1) | out-null
        $TableName = $($excel.ActiveSheet.ListObjects).DisplayName
        $excel.ActiveSheet.ListObjects("$TableName").TableStyle = "TableStyleMedium5"
    # How do I select an entire row?
        $range = $sh1_wbChrome.Cells.Item(1,1).EntireRow
        $range.font.bold = $true # sets the top row to bold
    Write-Host "done." -ForegroundColor Green
    Write-Host "`tFreezing header row.." -NoNewline
    # Freeze header row
        $range.application.activewindow.splitcolumn = 0
        $range.application.activewindow.splitrow = 1
        $range.application.activewindow.freezepanes = $true
    Write-Host "done." -ForegroundColor Green
    Write-Host "`tAutofit columns..." -NoNewline 
        $excel.ActiveSheet.UsedRange.EntireColumn.AutoFit() | out-null
    Write-Host "done." -ForegroundColor Green
    Start-Sleep -Seconds 1
##################################################################################################################
##################################################################################################################
# Close extra Workbooks
    Write-Host "`tClose extra Workbooks..." -NoNewLine
           	$wbAdobe.close($false)                                                       # close source workbook w/o saving
                $wbChrome.close($false)                                                     # close source workbook w/o saving
           $wbEdge.close($false)                                                     # close source workbook w/o saving
              $wbJava.close($false)                                                     # close source workbook w/o saving
              $wbSNOW.close($false)                                                     # close source workbook w/o saving  
               $wbCND.close($false)                                                     # close source workbook w/o saving                  
       $wbSempDisable.close($false)                                                     # close source workbook w/o saving  
        $wbSempEnable.close($false)                                                     # close source workbook w/o saving 
         $wbSempStale.close($false)                                                     # close source workbook w/o saving 
    Write-Host "done." -ForegroundColor Green  

# Cleanup data now that everything is in Excel
    Write-Host "`tDelete extra sheet(s)..." -NoNewLine
        $wsSheet1 = $wbNew.worksheets | where {$_.name -eq "Sheet1"} #<------- Selects sheet 1
        $wsSheet1.delete()  # Activate sheet 1
    Write-Host "done." -ForegroundColor Green    
    Start-Sleep -Seconds 1

# Modify wbNew AD_Workstations sheet
    Write-Host "`tActivate main worksheet..." -NoNewLine
        $ws1 = $wbNew.worksheets | where {$_.name -eq "AD_Workstations"} #<------- Selects AD_Workstations
        $ws1.activate()  # Activate sheet 1
    Write-Host "done." -ForegroundColor Green    
#########################################################
# Write match codes to sheet
    Write-Host "`tModify main speadsheet..." -NoNewline
        $ws1.cells.Item(1,1).Value() = 'AD - Distinguished Name'
        $ws1.cells.Item(1,2).Value() = 'AD - Computer Name'
        $ws1.cells.Item(1,3).Value() = 'AD - UAC'
        $ws1.cells.Item(1,4).Value() = 'AD - Operating System'
        $ws1.cells.Item(1,5).Value() = 'AD - Created'
$i = 6
        $ws1.cells.Item(1,$i).Value() = 'AD - Stale'
        $ws1.Cells.Item(1,$i).Interior.ColorIndex = 9
        $ws1.Cells.Item(1,$i).Font.ColorIndex = 2
        $ws1.cells.Item(2,$i).Value() = '=INDEX(AD_Stale_Computers!$A$2:$A$13000,MATCH(B2,AD_Stale_Computers!$A$2:$A$13000,FALSE),1)'
$i++
        $ws1.cells.Item(1,$i).Value() = 'Semperis - Stale Records'
        $ws1.Cells.Item(1,$i).Interior.ColorIndex = 10
        $ws1.Cells.Item(1,$i).Font.ColorIndex = 2
        $ws1.cells.Item(2,$i).Value() = '=INDEX(Semperis_Stale!$A$2:$A$13000,MATCH(B2,Semperis_Stale!$B$2:$B$13000,FALSE),1)'
$i++
        $ws1.cells.Item(1,$i).Value() = 'Semperis - Disabled Records'
        $ws1.Cells.Item(1,$i).Interior.ColorIndex = 10
        $ws1.Cells.Item(1,$i).Font.ColorIndex = 2
        $ws1.cells.Item(2,$i).Value() = '=INDEX(Semperis_Disables!$A$2:$A$13000,MATCH(B2,Semperis_Disables!$D$2:$D$13000,FALSE),1)'
$i++
        $ws1.cells.Item(1,$i).Value() = 'Semperis - Enabled Records'
        $ws1.Cells.Item(1,$i).Interior.ColorIndex = 10
        $ws1.Cells.Item(1,$i).Font.ColorIndex = 2
        $ws1.cells.Item(2,$i).Value() = '=INDEX(Semperis_Enables!$A$2:$A$13000,MATCH(B2,Semperis_Enables!$D$2:$D$13000,FALSE),1)'
$i++
        $ws1.cells.Item(1,$i).Value() = 'SCCM - Most Recent Record'
        $ws1.Cells.Item(1,$i).Interior.ColorIndex = 11
        $ws1.Cells.Item(1,$i).Font.ColorIndex = 2
        $ws1.cells.Item(2,$i).Value() = '=INDEX(SCCM_Report!$AB$2:$AB$13000,MATCH(B2,SCCM_Report!$B$2:$B$13000,FALSE),1)'
        $t = $i
$i++
        $ws1.cells.Item(1,$i).Value() = 'SNOW - Most Recent Record'        
        $ws1.Cells.Item(1,$i).Interior.ColorIndex = 13
        $ws1.Cells.Item(1,$i).Font.ColorIndex = 2
        $ws1.cells.Item(2,$i).Value() = '=INDEX(SNOW_Workstation_Report!$G$2:$G$13000,MATCH(B2,SNOW_Workstation_Report!$A$2:$A$13000,FALSE),1)'
        $s = $i
$i++
        $ws1.cells.Item(1,$i).Value() = 'SNOW - Computers Not Discovered'
        $ws1.Cells.Item(1,$i).Interior.ColorIndex = 13
        $ws1.Cells.Item(1,$i).Font.ColorIndex = 2
        $ws1.cells.Item(2,$i).Value() = '=INDEX(SNOW_CND!$E$2:$E$13000,MATCH(B2,SNOW_CND!$A$2:$A$13000,FALSE),1)'
$i++
        $ws1.cells.Item(1,$i).Value() = 'SCCM - Operating System'
        $ws1.Cells.Item(1,$i).Interior.ColorIndex = 11
        $ws1.Cells.Item(1,$i).Font.ColorIndex = 2
        $ws1.cells.Item(2,$i).Value() = '=INDEX(SCCM_Report!$F$2:$F$13000,MATCH(B2,SCCM_Report!$B$2:$B$13000,FALSE),1)'
$i++
        $ws1.cells.Item(1,$i).Value() = 'SCCM - Model Name'
        $ws1.Cells.Item(1,$i).Interior.ColorIndex = 11
        $ws1.Cells.Item(1,$i).Font.ColorIndex = 2
        $ws1.cells.Item(2,$i).Value() = '=INDEX(SCCM_Report!$L$2:$L$13000,MATCH(B2,SCCM_Report!$B$2:$B$13000,FALSE),1)'
$i++ 
        $ws1.cells.Item(1,$i).Value() = 'SCCM - Top User'       
        $ws1.Cells.Item(1,$i).Interior.ColorIndex = 11
        $ws1.Cells.Item(1,$i).Font.ColorIndex = 2
        $ws1.cells.Item(2,$i).Value() = '=INDEX(SCCM_Report!$E$2:$E$13000,MATCH(B2,SCCM_Report!$B$2:$B$13000,FALSE),1)'
$i++
        $ws1.cells.Item(1,$i).Value() = 'SCCM - Real Name' 
        $ws1.Cells.Item(1,$i).Interior.ColorIndex = 11
        $ws1.Cells.Item(1,$i).Font.ColorIndex = 2
        $ws1.cells.Item(2,$i).Value() = '=INDEX(AD_Users!$C$2:$C$13000,MATCH(O2,AD_Users!$D$2:$D$13000,FALSE),1)'
$i++
        $ws1.cells.Item(1,$i).Value() = 'SNOW - Operating System'
        $ws1.Cells.Item(1,$i).Interior.ColorIndex = 13
        $ws1.Cells.Item(1,$i).Font.ColorIndex = 2
        $ws1.cells.Item(2,$i).Value() =  '=INDEX(SNOW_Workstation_Report!$B$2:$B$13001,MATCH(B2,SNOW_Workstation_Report!$A$2:$A$13001,FALSE),1)'
$i++
        $ws1.cells.Item(1,$i).Value() = 'SNOW - Model Name'
        $ws1.Cells.Item(1,$i).Interior.ColorIndex = 13
        $ws1.Cells.Item(1,$i).Font.ColorIndex = 2
        $ws1.cells.Item(2,$i).Value() =  '=INDEX(SNOW_Workstation_Report!$F$2:$F$13001,MATCH(B2,SNOW_Workstation_Report!$A$2:$A$13001,FALSE),1)'
$i++
        $ws1.cells.Item(1,$i).Value() = 'SNOW - Status'       
        $ws1.Cells.Item(1,$i).Interior.ColorIndex = 13
        $ws1.Cells.Item(1,$i).Font.ColorIndex = 2
        $ws1.cells.Item(2,$i).Value() = '=INDEX(SNOW_Workstation_Report!$E$2:$E$13001,MATCH(B2,SNOW_Workstation_Report!$A$2:$A$13001,FALSE),1)'
$i++ 
        $ws1.cells.Item(1,$i).Value() = 'SNOW - Assigned User ID'       
        $ws1.Cells.Item(1,$i).Interior.ColorIndex = 13
        $ws1.Cells.Item(1,$i).Font.ColorIndex = 2
        $ws1.cells.Item(2,$i).Value() = '=INDEX(SNOW_Workstation_Report!$I$2:$I$13001,MATCH(B2,SNOW_Workstation_Report!$A$2:$A$13001,FALSE),1)'
 $i++  
        $ws1.cells.Item(1,$i).Value() = 'SNOW - Assigned Real Name'      
        $ws1.Cells.Item(1,$i).Interior.ColorIndex = 13
        $ws1.Cells.Item(1,$i).Font.ColorIndex = 2
        $ws1.cells.Item(2,$i).Value() = '=INDEX(AD_Users!$C$2:$C$13000,MATCH(T2,AD_Users!$D$2:$D$13000,FALSE),1)'                    
    Write-Host "done." -ForegroundColor Green        
#################################################################################
    $ErrorActionPreference = 'SilentlyContinue'
    Write-Host "$(Get-Date)`t--`tApplying conditional formatting to SNOW records (takes about five minutes)..." -NoNewline -ForegroundColor Yellow
    $30Past = $(Get-Date).AddDays(-30).ToString('yyyy-MM-dd')
    $used = $ws1.usedRange
    $lastCell = $used.SpecialCells(11)
    $lastrow = $lastCell.row -1

    $i = 2
    Do 
    {
# Format cells    
        if ($ws1.cells.Item($i,3).Value() -eq '4098')
        {
            $ws1.Cells.Item($i,1).Interior.ColorIndex = 9
            $ws1.Cells.Item($i,1).Font.ColorIndex = 2
            $ws1.Cells.Item($i,1).Font.Bold = $true
            $ws1.Cells.Item($i,2).Interior.ColorIndex = 9
            $ws1.Cells.Item($i,2).Font.ColorIndex = 2
            $ws1.Cells.Item($i,2).Font.Bold = $true
            $ws1.Cells.Item($i,3).Interior.ColorIndex = 9
            $ws1.Cells.Item($i,3).Font.ColorIndex = 2
            $ws1.Cells.Item($i,3).Font.Bold = $true
        }
# Format cells    
        if ($ws1.cells.Item($i,3).Value() -eq '4130')
        {
            $ws1.Cells.Item($i,3).Interior.ColorIndex = 9
            $ws1.Cells.Item($i,3).Font.ColorIndex = 2
            $ws1.Cells.Item($i,3).Font.Bold = $true
        }
# Format cells    
        if ($ws1.cells.Item($i,$t).Value() -eq '-2146826246')
        {
            $ws1.Cells.Item($i,$t).Interior.ColorIndex = 9
            $ws1.Cells.Item($i,$t).Font.ColorIndex = 2
            $ws1.Cells.Item($i,$t).Font.Bold = $true
        }
# Format cells	
        if ($ws1.cells.Item($i,$s).Value() -lt $30Past)
        {
            $ws1.Cells.Item($i,$s).Interior.ColorIndex = 9
            $ws1.Cells.Item($i,$s).Font.ColorIndex = 2
            $ws1.Cells.Item($i,$s).Font.Bold = $true
        }
# Format cells	
        if ($ws1.cells.Item($i,$s).Value() -eq '-2146826246')
        {
            $ws1.Cells.Item($i,$s).Interior.ColorIndex = 9
            $ws1.Cells.Item($i,$s).Font.ColorIndex = 2
            $ws1.Cells.Item($i,$s).Font.Bold = $true
        }
        $i++
        Start-Sleep -Milliseconds 50
    }
    While ($i -lt $lastRow)
    Write-Host "done." -ForegroundColor Green 
#################################################################################
    Write-Host "Close and save files..." -ForegroundColor Green
        $wbNew.SaveAs($DestFile)                                 # Save destination workbook
        $wbNew.close($true)                                      # close destination workbook
        $excel.quit()
        spps -n excel
    
    # Write-Host "Copying files to current directory"
        Copy-Item -Path $DestFile -Destination $FinalFile -Force
    $ErrorActionPreference = 'Continue'
}

########################################################################################################################################
# RUN FUNCTIONS
########################################################################################################################################

Variables
GoGoStartingScript
SCCMAdobe
SCCMChrome
SCCMEdge
SCCMJava

ExcelFun


$EDate = (GET-DATE)
$Span = NEW-TIMESPAN –Start $SDate –End $EDate
$Min = $Span.minutes
$Sec = $Span.Seconds
Write-Host "`n$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
Start-Sleep -Seconds 10
