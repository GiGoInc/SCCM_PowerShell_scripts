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

    #4 SCCM VARIABLES
         $Global:SCCMFile = "C:\Temp\SCCM_Report_original.csv"
        $Global:SCCM_Mod1 = "C:\Temp\SCCM_Report_Edit1.csv"
        $Global:SCCM_Mod2 = "C:\Temp\SCCM_Report_Edit2.csv"
         $Global:SCCMEdit = "C:\Temp\SCCM_Report.csv"
          $Global:SCCMXLS = "C:\Temp\SCCM_Report.xlsx"
  
    #5 SNOW VARIABLES
              $Global:IWR = "\\DOMAIN.COM\GROUP1\SERVER1\MANAGEMENT GROUP\Semperis_Reports\SuperUser's Workstation Report.csv"
              $Global:CND = "\\DOMAIN.COM\GROUP1\SERVER1\MANAGEMENT GROUP\Semperis_Reports\Computers not Discovered or Assigned in last 30 days but Discovered in the last 120 days.csv"		  
          $Global:SNOWIWR = "C:\Temp\SNOW_SuperUser_Workstation_Report.csv"
          $Global:SNOWCND = "C:\Temp\SNOW_CND.csv"
        $Global:SNOW_Mod1 = "C:\Temp\SNOW_IWR_Edit.csv"
        $Global:SNOW_Mod2 = "C:\Temp\SNOW_IWR_Edit2.csv"
        $Global:SNOW_CND1 = "C:\Temp\SNOW_CND_Edit.csv"
        $Global:SNOW_CND2 = "C:\Temp\SNOW_CND_Edit2.csv"
          $Global:SNOWXLS = "C:\Temp\SNOW_SuperUser_Workstation_Report.xlsx"
           $Global:CNDXLS = "C:\Temp\SNOW_CND.xlsx"

    #6 SEMPERIS VARIABLES
            $Global:SempFileD = "\\DOMAIN.COM\GROUP1\SERVER1\MANAGEMENT GROUP\Semperis_Reports\Computer Account Disables in the last 6 months.csv"
            $Global:SempFileE = "\\DOMAIN.COM\GROUP1\SERVER1\MANAGEMENT GROUP\Semperis_Reports\Computer Enables in the last 6 months.csv"
            $Global:SempFileS = "\\DOMAIN.COM\GROUP1\SERVER1\MANAGEMENT GROUP\Semperis_Reports\Stale Computer Accounts.csv"
      $Global:SempDisablesCSV1 = "C:\Temp\Semperis_Computer_Disables1.csv"
      $Global:SempDisablesCSV2 = "C:\Temp\Semperis_Computer_Disables2.csv"
      $Global:SempDisablesCSV3 = "C:\Temp\Semperis_Computer_Disables3.csv"
      $Global:SempDisablesCSV4 = "C:\Temp\Semperis_Computer_Disables4.csv"

       $Global:SempEnablesCSV1 = "C:\Temp\Semperis_Computer_Enables1.csv"
       $Global:SempEnablesCSV2 = "C:\Temp\Semperis_Computer_Enables2.csv"
       $Global:SempEnablesCSV3 = "C:\Temp\Semperis_Computer_Enables3.csv"
       $Global:SempEnablesCSV4 = "C:\Temp\Semperis_Computer_Enables4.csv"

        $Global:SempStalesCSV1 = "C:\Temp\Semperis_Computer_Stale1.csv"
        $Global:SempStalesCSV2 = "C:\Temp\Semperis_Computer_Stale2.csv"
        $Global:SempStalesCSV3 = "C:\Temp\Semperis_Computer_Stale3.csv"
        $Global:SempStalesCSV4 = "C:\Temp\Semperis_Computer_Stale4.csv"

              $Global:SempDXLS = "C:\Temp\Semperis_Computer_Disables.xlsx"
              $Global:SempEXLS = "C:\Temp\Semperis_Computer_Enables.xlsx"      
              $Global:SempSXLS = "C:\Temp\Semperis_Computer_Stale.xlsx" 
              
    #4 SCCM - ADOBE VARIABLES
          $Global:SCCMAdobeCSV = "C:\Temp\SCCM_ADOBE_CSV.csv"
         $Global:SCCMAdobeEdit = "C:\Temp\SCCM_ADOBE_Report.csv"
          $Global:SCCMAdobeXLS = "C:\Temp\SCCM_ADOBE_Report.xlsx"
  
    #4 SCCM - CHROME VARIABLES
          $Global:SCCMChromeCSV = "C:\Temp\SCCM_CHROME_CSV.csv"
         $Global:SCCMChromeEdit = "C:\Temp\SCCM_CHROME_Report.csv"
          $Global:SCCMChromeXLS = "C:\Temp\SCCM_CHROME_Report.xlsx"

    #4 SCCM - EDGE VARIABLES
          $Global:SCCMEdgeCSV = "C:\Temp\SCCM_EDGE_CSV.csv"
         $Global:SCCMEdgeEdit = "C:\Temp\SCCM_EDGE_Report.csv"
          $Global:SCCMEdgeXLS = "C:\Temp\SCCM_EDGE_Report.xlsx" 

    #4 SCCM - JAVA VARIABLES
           $Global:SCCMJavaCSV = "C:\Temp\SCCM_JAVA_CSV.csv"
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

	If ((!(Test-Path $SNOWIWR)) -or (($(Get-ItemProperty -Path $IWR).LastWriteTime -le $(Get-ItemProperty -Path $SNOWIWR).LastWriteTime))) { Copy-Item -Path $IWR -Destination $SNOWIWR -Force }
	If ((!(Test-Path $SNOWCND)) -or (($(Get-ItemProperty -Path $CND).LastWriteTime -lt $(Get-ItemProperty -Path $SNOWCND).LastWriteTime))) { Copy-Item -Path $CND -Destination $SNOWCND -Force }
    If ((!(Test-Path $SempDisablesCSV1)) -or (($(Get-ItemProperty -Path $SempFileD).LastWriteTime -lt $(Get-ItemProperty -Path $SempDisablesCSV1).LastWriteTime))) { Copy-Item -Path $SempFileD -Destination $SempDisablesCSV1 -Force } 
    If ((!(Test-Path $SempEnablesCSV1)) -or (($(Get-ItemProperty -Path $SempFileE).LastWriteTime -lt $(Get-ItemProperty -Path $SempEnablesCSV1).LastWriteTime))) { Copy-Item -Path $SempFileE -Destination $SempEnablesCSV1 -Force } 
    If ((!(Test-Path $SempStalesCSV1)) -or (($(Get-ItemProperty -Path $SempFileS).LastWriteTime -lt $(Get-ItemProperty -Path $SempStalesCSV1).LastWriteTime))) { Copy-Item -Path $SempFileS -Destination $SempStalesCSV1 -Force }
########################################################################################################################################
# Remove temp files before starting 
########################################################################################################################################
    #1 AD USER VARIABLES
    If (Test-Path $AD_Users)          { Remove-Item -Path $AD_Users -Force | Out-Null }
    If (Test-Path $AD_UsersXLS)       { Remove-Item -Path $AD_UsersXLS -Force | Out-Null }
    #2 AD COMPUTER VARIABLES          
    If (Test-Path $MidFile0)          { Remove-Item -Path $MidFile0 -Force | Out-Null }
    If (Test-Path $MidFile00)         { Remove-Item -Path $MidFile00 -Force | Out-Null }
    If (Test-Path $MidFile1)          { Remove-Item -Path $MidFile1 -Force | Out-Null }
    If (Test-Path $AD_PC)             { Remove-Item -Path $AD_PC -Force | Out-Null }
    If (Test-Path $AD_PCXLS)          { Remove-Item -Path $AD_PCXLS -Force | Out-Null }
    #3 AD STALE PC VARIABLES          
    If (Test-Path $AD_StalePC)        { Remove-Item -Path $AD_StalePC -Force | Out-Null }
    If (Test-Path $AD_StalePCEdit)    { Remove-Item -Path $AD_StalePCEdit -Force | Out-Null }
    If (Test-Path $AD_StalePCXLS)     { Remove-Item -Path $AD_StalePCXLS -Force | Out-Null }
    #4 SCCM VARIABLES                 
    If (Test-Path $SCCMFile)          { Remove-Item -Path $SCCMFile -Force | Out-Null }
    If (Test-Path $SCCM_Mod1)         { Remove-Item -Path $SCCM_Mod1 -Force | Out-Null }
    If (Test-Path $SCCM_Mod2)         { Remove-Item -Path $SCCM_Mod2 -Force | Out-Null }
    If (Test-Path $SCCMEdit)          { Remove-Item -Path $SCCMEdit -Force | Out-Null }
    If (Test-Path $SCCMXLS)           { Remove-Item -Path $SCCMXLS -Force | Out-Null }
    #5 SNOW VARIABLES                 
    If (Test-Path $SNOW_Mod1)         { Remove-Item -Path $SNOW_Mod1 -Force | Out-Null }
    If (Test-Path $SNOW_Mod2)         { Remove-Item -Path $SNOW_Mod2 -Force | Out-Null }
    If (Test-Path $SNOW_CND1)         { Remove-Item -Path $SNOW_CND1 -Force | Out-Null }
    If (Test-Path $SNOW_CND2)         { Remove-Item -Path $SNOW_CND2 -Force | Out-Null }
    If (Test-Path $SNOWXLS)           { Remove-Item -Path $SNOWXLS -Force | Out-Null }
    If (Test-Path $CNDXLS)            { Remove-Item -Path $CNDXLS -Force | Out-Null }
    #6 SEMPERIS VARIABLES
    If (Test-Path $SempDisablesCSV2)  { Remove-Item -Path $SempDisablesCSV2 -Force | Out-Null }
    If (Test-Path $SempDisablesCSV3)  { Remove-Item -Path $SempDisablesCSV3 -Force | Out-Null }
    If (Test-Path $SempDisablesCSV4)  { Remove-Item -Path $SempDisablesCSV4 -Force | Out-Null }
    If (Test-Path $SempEnablesCSV2)   { Remove-Item -Path $SempEnablesCSV2 -Force | Out-Null }
    If (Test-Path $SempEnablesCSV3)   { Remove-Item -Path $SempEnablesCSV3 -Force | Out-Null }
    If (Test-Path $SempEnablesCSV4)   { Remove-Item -Path $SempEnablesCSV4 -Force | Out-Null }
    If (Test-Path $SempStalesCSV2)    { Remove-Item -Path $SempStalesCSV2 -Force | Out-Null }
    If (Test-Path $SempStalesCSV3)    { Remove-Item -Path $SempStalesCSV3 -Force | Out-Null }
    If (Test-Path $SempStalesCSV4)    { Remove-Item -Path $SempStalesCSV4 -Force | Out-Null }
    If (Test-Path $SempDXLS)          { Remove-Item -Path $SempDXLS -Force | Out-Null }
    If (Test-Path $SempEXLS)          { Remove-Item -Path $SempEXLS -Force | Out-Null }
    If (Test-Path $SempSXLS)          { Remove-Item -Path $SempSXLS -Force | Out-Null }

    #4 SCCM VARIABLES                 
    If (Test-Path $SCCMAdobeCSV)      { Remove-Item -Path $SCCMAdobeCSV -Force | Out-Null }
    If (Test-Path $SCCMAdobeEdit)     { Remove-Item -Path $SCCMAdobeEdit -Force | Out-Null }
    If (Test-Path $SCCMAdobeXLS)      { Remove-Item -Path $SCCMAdobeXLS -Force | Out-Null }

    If (Test-Path $SCCMChromeCSV)      { Remove-Item -Path $SCCMChromeCSV -Force | Out-Null }
    If (Test-Path $SCCMChromeEdit)     { Remove-Item -Path $SCCMChromeEdit -Force | Out-Null }
    If (Test-Path $SCCMChromeXLS)      { Remove-Item -Path $SCCMChromeXLS -Force | Out-Null }

    If (Test-Path $SCCMEdgeCSV)      { Remove-Item -Path $SCCMEdgeCSV -Force | Out-Null }
    If (Test-Path $SCCMEdgeEdit)     { Remove-Item -Path $SCCMEdgeEdit -Force | Out-Null }
    If (Test-Path $SCCMEdgeXLS)      { Remove-Item -Path $SCCMEdgeXLS -Force | Out-Null }

    If (Test-Path $SCCMJavaCSV)      { Remove-Item -Path $SCCMJavaCSV -Force | Out-Null }
    If (Test-Path $SCCMJavaEdit)     { Remove-Item -Path $SCCMJavaEdit -Force | Out-Null }
    If (Test-Path $SCCMJavaXLS)      { Remove-Item -Path $SCCMJavaXLS -Force | Out-Null }

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



# Check for $SNOWCSV - SNOW SuperUser's Workstation Report file
    If (!(Test-Path "$IWR"))
    {
        Write-Host ""
        Write-Host "Hey, dum dum it doesn't look like " -NoNewline -ForegroundColor Cyan  
        Write-host "$IWR " -ForegroundColor Green  -NoNewline
        Write-Host "exists..." -ForegroundColor Cyan  
        Write-Host ""
        Write-Host "You need to run that report and copy it to $IWR" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Action cancelled." -ForegroundColor Red
        Read-Host -Prompt 'Press Enter to exit...'
        Exit
    }

# Check for "Computers not Discover or Assigned in 30 days, but Discovered in the last 120 days" file
    If (!(Test-Path $CND))
    {
        Write-Host ""
        Write-Host "Hey, dum dum it doesn't look like " -NoNewline -ForegroundColor Cyan  
        Write-host "$CND " -ForegroundColor Green  -NoNewline
        Write-Host "exists..." -ForegroundColor Cyan  
        Write-Host ""
        Write-Host "You need to run that report and copy it to $CND" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Action cancelled." -ForegroundColor Red
        Read-Host -Prompt 'Press Enter to exit...'
        Exit
    }

# Check for Semperis files
    If (!(Test-Path $SempDisablesCSV1))
    {
        Write-Host ""
        Write-Host "Hey, dum dum it doesn't look like " -NoNewline -ForegroundColor Cyan  
        Write-host "$SempDisablesCSV1 " -ForegroundColor Green  -NoNewline
        Write-Host "exists..." -ForegroundColor Cyan  
        Write-Host ""
        Write-Host "You need to run that report and copy it to $SempDisablesCSV1" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Action cancelled." -ForegroundColor Red
        Read-Host -Prompt 'Press Enter to exit...'
        Exit
    }
    If (!(Test-Path $SempEnablesCSV1))
    {
        Write-Host ""
        Write-Host "Hey, dum dum it doesn't look like " -NoNewline -ForegroundColor Cyan  
        Write-host "$SempEnablesCSV1 " -ForegroundColor Green  -NoNewline
        Write-Host "exists..." -ForegroundColor Cyan  
        Write-Host ""
        Write-Host "You need to run that report and copy it to $SempEnablesCSV1" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Action cancelled." -ForegroundColor Red
        Read-Host -Prompt 'Press Enter to exit...'
        Exit
    }

    If (!(Test-Path $SempStalesCSV1))
    {
        Write-Host ""
        Write-Host "Hey, dum dum it doesn't look like " -NoNewline -ForegroundColor Cyan  
        Write-host "$SempStalesCSV1 " -ForegroundColor Green  -NoNewline
        Write-Host "exists..." -ForegroundColor Cyan  
        Write-Host ""
        Write-Host "You need to run that report and copy it to $SempStalesCSV1" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Action cancelled." -ForegroundColor Red
        Read-Host -Prompt 'Press Enter to exit...'
        Exit
    }

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

#3 AD STALE PC
Function ADStale { 
########################################################################################################################################
# Generate AD Stale Computers list
Write-Host "$(Get-Date)`t--`tGenerating $AD_StalePC..." -NoNewline -ForegroundColor Yellow
    $job = Start-Job {dsquery computer -stalepwd 60 > C:\Temp\DSQuery_Stale_Computer_60_Days_orginal.csv -limit 0}
    Wait-Job $job | out-null
    Receive-Job $job
    Write-Host "done." -ForegroundColor Green

    # Run multiple Replace cases
    (Get-Content $AD_StalePC) | Foreach-Object {
        $_ -replace '"', '' `
           -replace 'CN=', '' `
           -replace ',Computers,', ',CN=Computers,'
        } | Add-Content $AD_StalePCEdit

# Cleanup AD Stale PC Report
    Write-Host "`tCleaning up the double quotes in the AD Stale PC report..." -NoNewline
    # Insert Header in CSV
    $a = Get-Content $AD_StalePCEdit
    $b = 'Computer,OU1,OU2,etc...' # now something to add to the beginning, for example the date  
    Set-Content $AD_StalePCEdit –value $b, $a
    Write-Host "done." -ForegroundColor Green
########################################################################################################################################
}

#4 SCCM
Function SCCM { 
########################################################################################################################################
# Generate SCCM Report to current directory
	Write-Host "$(Get-Date)`t--`tGenerating $SCCMFile..." -NoNewline -ForegroundColor Yellow
    #Invoke-WebRequest "http://SERVER/ReportServer?%2fConfigMgr_XX1%2fDOMAIN+Part2%2fCOM+-+The+Works+(Machine+to+User+match)&rs:Command=Render&rs:Format=CSV&rc:Toolbar=False" -credential $cred -outfile $SCCMFile
##########################################################################
$SQL_Query = "
/*
COM _ Top Console User List
	B = v_r_system
	CS = v_gs_computer_system
	D = v_gs_x86_pc_memory
	E = v_gs_processor
	F = v_gs_pc_bios
	G = v_gs_system_enclosure
	H = v_gs_logical_disk
	I = v_GS_SYSTEM_CONSOLE_USAGE
	J = v_GS_OPERATING_SYSTEM
	K = v_UsersPrimaryMachines
	L = v_R_User
*/

DECLARE @Today AS DATE
SET @Today = GETDATE()
 
DECLARE @BackInTime AS DATE
SET @BackInTime = DATEADD(DAY, -30, @Today )
 
SELECT DISTINCT
 SYS.ResourceID,
 SYS.Name0 'Name', 
 SYS.AD_Site_Name0 'ADSite', 
 CS.UserName0 'User Name',
 CASE
 WHEN U.TopConsoleUser0 = '-1' OR U.TopConsoleUser0 IS NULL THEN 'N/A'
 ELSE U.TopConsoleUser0
 END AS TopUser,
 OS.Caption0 AS OS,
 Case
	when OS.BuildNumber0 = 10240 then '1507'
	when OS.BuildNumber0 = 10586 then '1511'
	when OS.BuildNumber0 = 14393 then '1607'
	when OS.BuildNumber0 = 15063 then '1703'
	when OS.BuildNumber0 = 16299 then '1709'
	when OS.BuildNumber0 = 17134 then '1803'
	when OS.BuildNumber0 = 17763 then '1809'
	when OS.BuildNumber0 = 18362 then '1903'
	when OS.BuildNumber0 = 18363 then '1909'
    when OS.BuildNumber0 = 19042 then '20H2'
    when OS.BuildNumber0 = 19043 then '21H2'
    when OS.BuildNumber0 = 19044 then '21H2'
    when OS.BuildNumber0 = 19045 then '22H2'
    when OS.BuildNumber0 = 22621 then '22H2'
else 'Unknown' end as 'Version',

Case
	when OS.BuildNumber0 = 10240 then 'Threshold 1'
	when OS.BuildNumber0 = 10586 then 'Threshold 2'
	when OS.BuildNumber0 = 14393 then 'Redstone 1'
	when OS.BuildNumber0 = 15063 then 'Redstone 2'
	when OS.BuildNumber0 = 16299 then 'Redstone 3'
	when OS.BuildNumber0 = 17134 then 'Redstone 4'
	when OS.BuildNumber0 = 17763 then 'Redstone 5'
	when OS.BuildNumber0 = 18362 then '19H1'
	when OS.BuildNumber0 = 18363 then '1909'
    when OS.BuildNumber0 = 19042 then '20H2'
    when OS.BuildNumber0 = 19043 then '21H2'
    when OS.BuildNumber0 = 19044 then '21H2'
    when OS.BuildNumber0 = 19045 then '22H2'
    when OS.BuildNumber0 = 22621 then '22H2'
else 'Unknown' end as 'Code name',
 
case 
	when Sys.OSRemoteLocale01 = -1 then '(WIPB) Pre-release'
	when Sys.OSRemoteLocale01 = 0 then '(CB) Release-Ready'
	when Sys.OSRemoteLocale01 = 1 then '(CBB) Business-Ready'
	when Sys.OSRemoteLocale01 = 2 then '(LTSB) Mission critical'
Else 'Unknown' end as 'OS RemoteLocale', 

OS.BuildNumber0 as 'Build Number',
/* REPLACE (OS.CSDVersion0,'Service Pack','SP') 'Service Pack', */
 CS.Manufacturer0 'Manufacturer',
/* ############################################################################################################################## */
/* ############################################################################################################################## */
Case
    WHEN CS.Model0 In ( '20QD000LUS' ) THEN 'Laptop - Lenovo ThinkPad X1 Carbon'
    WHEN CS.Model0 In ( '20RH000JUS' ) THEN 'Laptop - Lenovo ThinkPad P43s'
    WHEN CS.Model0 In ( '20RH000PUS' ) THEN 'Laptop - Lenovo ThinkPad P43s'
    WHEN CS.Model0 In ( '344834U' ) THEN 'Laptop - Lenovo ThinkPad X1 Carbon (OLD)'
    WHEN CS.Model0 In ( 'Latitude 5290 2-in-1' ) THEN 'Laptop - Dell Inc. Latitude 5290 2-in-1'
    WHEN CS.Model0 In ( 'Latitude 5480' ) THEN 'Laptop - Dell Inc. Latitude 5480'
    WHEN CS.Model0 In ( 'Latitude 5500' ) THEN 'Laptop - Dell Inc. Latitude 5500'
    WHEN CS.Model0 In ( 'Latitude 5510' ) THEN 'Laptop - Dell Inc. Latitude 5510'
    WHEN CS.Model0 In ( 'Latitude 5520' ) THEN 'Laptop - Dell Inc. Latitude 5520'
    WHEN CS.Model0 In ( 'Latitude 5530' ) THEN 'Laptop - Dell Inc. Latitude 5530'
    WHEN CS.Model0 In ( 'Latitude 5580' ) THEN 'Laptop - Dell Inc. Latitude 5580'
    WHEN CS.Model0 In ( 'Latitude 5590' ) THEN 'Laptop - Dell Inc. Latitude 5590'
    WHEN CS.Model0 In ( 'Latitude 7390' ) THEN 'Laptop - Dell Inc. Latitude 7390'
    WHEN CS.Model0 In ( 'Latitude 7400 2-in-1' ) THEN 'Laptop - Dell Inc. Latitude 7400 2-in-1'
    WHEN CS.Model0 In ( 'Latitude 7400' ) THEN 'Laptop - Dell Inc. Latitude 7400'
    WHEN CS.Model0 In ( 'Latitude 7410' ) THEN 'Laptop - Dell Inc. Latitude 7410'
    WHEN CS.Model0 In ( 'Latitude 7420' ) THEN 'Laptop - Dell Inc. Latitude 7420'
    WHEN CS.Model0 In ( 'Latitude 7430' ) THEN 'Laptop - Dell Inc. Latitude 7430'
    WHEN CS.Model0 In ( 'Latitude 7480' ) THEN 'Laptop - Dell Inc. Latitude 7480'
    WHEN CS.Model0 In ( 'Latitude 9510' ) THEN 'Laptop - Dell Inc. Latitude 9510'
    WHEN CS.Model0 In ( 'Latitude E5540' ) THEN 'Laptop - Dell Inc. Latitude E5540'	 
    WHEN CS.Model0 In ( 'Latitude E554063533007A/' ) THEN 'Laptop - Dell Inc. Latitude E5540'
    WHEN CS.Model0 In ( 'Latitude E5550' ) THEN 'Laptop - Dell Inc. Latitude E5550'
    WHEN CS.Model0 In ( 'Latitude E5570' ) THEN 'Laptop - Dell Inc. Latitude E5570'
    WHEN CS.Model0 In ( 'Latitude E7440' ) THEN 'Laptop - Dell Inc. Latitude E7440'
    WHEN CS.Model0 In ( 'Latitude E7470' ) THEN 'Laptop - Dell Inc. Latitude E7470'
    WHEN CS.Model0 In ( 'OptiPlex 7000' ) THEN 'Desktop - Dell Inc. OptiPlex 7000'
    WHEN CS.Model0 In ( 'OptiPlex 7010' ) THEN 'Desktop - Dell Inc. OptiPlex 7010'
    WHEN CS.Model0 In ( 'OptiPlex 7020' ) THEN 'Desktop - Dell Inc. OptiPlex 7020'
    WHEN CS.Model0 In ( 'OptiPlex 7040' ) THEN 'Desktop - Dell Inc. OptiPlex 7040'
    WHEN CS.Model0 In ( 'OptiPlex 7050' ) THEN 'Desktop - Dell Inc. OptiPlex 7050'
    WHEN CS.Model0 In ( 'OptiPlex 7060' ) THEN 'Desktop - Dell Inc. OptiPlex 7060'
    WHEN CS.Model0 In ( 'OptiPlex 7070' ) THEN 'Desktop - Dell Inc. OptiPlex 7070'
    WHEN CS.Model0 In ( 'OptiPlex 7080' ) THEN 'Desktop - Dell Inc. OptiPlex 7080'
    WHEN CS.Model0 In ( 'OptiPlex 7090' ) THEN 'Desktop - Dell Inc. OptiPlex 7090'
    WHEN CS.Model0 In ( 'OptiPlex 7450 AIO' ) THEN 'Desktop - Dell Inc. OptiPlex 7450 AIO'
    WHEN CS.Model0 In ( 'OptiPlex 9020' ) THEN 'Desktop - Dell Inc. OptiPlex 9020'
    WHEN CS.Model0 In ( 'OptiPlex 90202004CK0002/' ) THEN 'Desktop - Dell Inc. OptiPlex 9020'
    WHEN CS.Model0 In ( 'Precision 3551' ) THEN 'Laptop - Dell Inc. Precision 3551'
    WHEN CS.Model0 In ( 'Precision 3630 Tower' ) THEN 'Desktop - Dell Inc. Precision 3630 Tower'
    WHEN CS.Model0 In ( 'Precision 7740' ) THEN 'Laptop - Dell Inc. Precision 7740'
    WHEN CS.Model0 In ( 'VMWare Virtual Machine' ) THEN 'VMWare Virtual Machine'
    WHEN CS.Model0 In ( 'VMware Virtual Platform' ) THEN 'VMWare Virtual Machine'
    WHEN CS.Model0 In ( 'VMware7,1' ) THEN 'VMWare Virtual Machine'
    WHEN CS.Model0 In ( 'XPS 13 9365' ) THEN 'Laptop - Dell Inc. Latitude XPS 13 (9365)'
    WHEN CS.Model0 In ( 'XPS 15 9575' ) THEN 'Laptop - Dell Inc. Latitude XPS 15 (9575)'
    /* ##################################### */
    WHEN CS.Model0 In ( 'X9SAE' ) THEN 'Desktop - Air Conditioning'	
    WHEN CS.Model0 In ( '4865A17','4865A18' ) THEN 'Desktop - Lenovo ThinkCentre M78'
    WHEN CS.Model0 In ( '5041A3U','5054A3U' ) THEN 'Desktop - Lenovo ThinkCentre M75e'	
    WHEN CS.Model0 In ( 'HP Z420 Workstation' ) THEN 'Desktop - HP Z240 Workstation'
    WHEN CS.Model0 In ( 'To be filled by O.E.M.' ) THEN 'Desktop - NewLine'
    WHEN CS.Model0 In ( 'ProLiant BL685c G6' ) THEN 'Server - ProLiant BL685c G6'
    WHEN CS.Model0 In ( 'ProLiant DL360 Gen10' ) THEN 'Server - ProLiant DL360 Gen10'
    WHEN CS.Model0 In ( 'S3420GP' ) THEN 'Server - S3420GP'
    WHEN CS.Model0 In ( 'PowerEdge 2950' ) THEN 'Server - PowerEdge 2950' 
ELSE CS.Model0 END AS 'Model Name' ,
/* ############################################################################################################################## */
/* ############################################################################################################################## */
CASE SE.ChassisTypes0 
	 WHEN '1' THEN 'VM / Other'
	 WHEN '2' THEN 'Unknown'
	 WHEN '3' THEN 'Desktop'
	 WHEN '4' THEN 'Low Profile Desktop'
	 WHEN '5' THEN 'Pizza Box'
	 WHEN '6' THEN 'Mini Tower'
	 WHEN '7' THEN 'Tower'
	 WHEN '8' THEN 'Portable'
	 WHEN '9' THEN 'Laptop'
	 WHEN '10' THEN 'Laptop'
	 WHEN '11' THEN 'Hand Held'
	 WHEN '12' THEN 'Docking Station'
	 WHEN '13' THEN 'All-in-One'
	 WHEN '14' THEN 'Sub Notebook'
	 WHEN '15' THEN 'Space-Saving'
	 WHEN '16' THEN 'Desktop'
	 WHEN '17' THEN 'Main System Chassis'
	 WHEN '18' THEN 'Expansion Chassis'
	 WHEN '19' THEN 'SubChassis'
	 WHEN '20' THEN 'Bus Expansion Chassis'
	 WHEN '21' THEN 'Peripheral Chassis'
	 WHEN '22' THEN 'Storage Chassis'
	 WHEN '23' THEN 'Rack Mount Chassis'
	 WHEN '24' THEN 'Sealed-Case PC'
	 WHEN '31' THEN 'All-In-One'
	 WHEN '32' THEN 'All-In-One'
 ELSE 'Undefinded' END AS 'PC Type',

 BIOS.SerialNumber0 'Serial Number', 
 CONVERT (DATE,BIOS.ReleaseDate0) AS [BIOS Date], 
 BIOS.SMBIOSBIOSVersion0 AS [BIOS Version],

/*
	Lenovo Thinkpad X1 CARBON -- 1.56
	Lenovo Thinkpad P43S      -- 1.78
	Lenovo Thinkpad P43S      -- 1.78
	Latitude 5290 2-in-1      -- 1.25.0
	Latitude 5480             -- 1.29.0
	Latitude 5500             -- 1.23.0
	Latitude 5510             -- 1.17.0
	Latitude 5520             -- 1.25.1
	Latitude 5530             -- 1.10.0
	Latitude 5580             -- 1.29.0
	Latitude 5590             -- 1.27.1
	Latitude 7390             -- 1.31.1
	Latitude 7400 2-in-1      -- 1.20.0
	Latitude 7400             -- 1.24.0
	Latitude 7410             -- 1.19.0
	Latitude 7420             -- 1.23.1
	Latitude 7430             -- 1.11.0
	Latitude 7480             -- 1.30.0
	Latitude 9510             -- 1.17.1
	Latitude E5540            -- A24	 
	Latitude E5550            -- A24
	Latitude E5570            -- 1.34.3
	Latitude E7440            -- A28
	Latitude E7470            -- 1.36.3
	OptiPlex 7000             -- 1.9.0
	OptiPlex 7010             -- A29
	OptiPlex 7020             -- A18
	OptiPlex 7040             -- 1.24.0
	OptiPlex 7050             -- 1.24.0
	OptiPlex 7060             -- 1.24.0
	OptiPlex 7070             -- 1.20.0
	OptiPlex 7080             -- 1.17.1
	OptiPlex 7090             -- 1.15.0
	OptiPlex 9020             -- A25
	Precision 3551            -- 1.18.0
	Precision 3630 Tower      -- 2.19.0
	Precision 7740            -- 1.24.0
	XPS 13 9365               -- 2.24.0
	XPS 15 9575               -- 1.25.0
*/
/* ############################################################################################################################## */
/* ############################################################################################################################## */
 CASE WHEN CS.Model0 In ( '20QD000LUS' ) THEN '1.56'
      WHEN CS.Model0 In ( '20RH000JUS' ) THEN '1.78'
      WHEN CS.Model0 In ( '20RH000PUS' ) THEN '1.78'
      WHEN CS.Model0 In ( '344834U' ) THEN 'Unknown'
      WHEN CS.Model0 In ( 'Latitude 5290 2-in-1' ) THEN '1.25.0'
      WHEN CS.Model0 In ( 'Latitude 5480' ) THEN '1.29.0'
      WHEN CS.Model0 In ( 'Latitude 5500' ) THEN '1.23.0'
      WHEN CS.Model0 In ( 'Latitude 5510' ) THEN '1.17.0'
      WHEN CS.Model0 In ( 'Latitude 5520' ) THEN '1.25.1'
      WHEN CS.Model0 In ( 'Latitude 5530' ) THEN '1.10.0'
      WHEN CS.Model0 In ( 'Latitude 5580' ) THEN '1.29.0'
      WHEN CS.Model0 In ( 'Latitude 5590' ) THEN '1.27.1'
      WHEN CS.Model0 In ( 'Latitude 7390' ) THEN '1.31.1'
      WHEN CS.Model0 In ( 'Latitude 7400 2-in-1' ) THEN '1.20.0'
      WHEN CS.Model0 In ( 'Latitude 7400' ) THEN '1.24.0'
      WHEN CS.Model0 In ( 'Latitude 7410' ) THEN '1.19.0'
      WHEN CS.Model0 In ( 'Latitude 7420' ) THEN '1.23.1'
      WHEN CS.Model0 In ( 'Latitude 7430' ) THEN '1.11.0'
      WHEN CS.Model0 In ( 'Latitude 7480' ) THEN '1.30.0'
      WHEN CS.Model0 In ( 'Latitude 9510' ) THEN '1.17.1'
      WHEN CS.Model0 In ( 'Latitude E5540' ) THEN 'A24'	 
      WHEN CS.Model0 In ( 'Latitude E554063533007A/' ) THEN 'A24'
      WHEN CS.Model0 In ( 'Latitude E5550' ) THEN 'A24'
      WHEN CS.Model0 In ( 'Latitude E5570' ) THEN '1.34.3'
      WHEN CS.Model0 In ( 'Latitude E7440' ) THEN 'A28'
      WHEN CS.Model0 In ( 'Latitude E7470' ) THEN '1.36.3'
      WHEN CS.Model0 In ( 'OptiPlex 7000' ) THEN '1.9.0'
      WHEN CS.Model0 In ( 'OptiPlex 7010' ) THEN 'A29'
      WHEN CS.Model0 In ( 'OptiPlex 7020' ) THEN 'A18'
      WHEN CS.Model0 In ( 'OptiPlex 7040' ) THEN '1.24.0'
      WHEN CS.Model0 In ( 'OptiPlex 7050' ) THEN '1.24.0'
      WHEN CS.Model0 In ( 'OptiPlex 7060' ) THEN '1.24.0'
      WHEN CS.Model0 In ( 'OptiPlex 7070' ) THEN '1.20.0'
      WHEN CS.Model0 In ( 'OptiPlex 7080' ) THEN '1.17.1'
      WHEN CS.Model0 In ( 'OptiPlex 7090' ) THEN '1.15.0'
      WHEN CS.Model0 In ( 'OptiPlex 7450 AIO' ) THEN 'Unknown'
      WHEN CS.Model0 In ( 'OptiPlex 9020' ) THEN 'A25'
      WHEN CS.Model0 In ( 'OptiPlex 90202004CK0002/' ) THEN 'A25'
      WHEN CS.Model0 In ( 'Precision 3551' ) THEN '1.18.0'
      WHEN CS.Model0 In ( 'Precision 3630 Tower' ) THEN '2.19.0'
      WHEN CS.Model0 In ( 'Precision 7740' ) THEN '1.24.0'
      WHEN CS.Model0 In ( 'VMWare Virtual Machine' ) THEN 'Unknown'
      WHEN CS.Model0 In ( 'VMware Virtual Platform' ) THEN 'Unknown'
      WHEN CS.Model0 In ( 'VMware7,1' ) THEN 'Unknown'
      WHEN CS.Model0 In ( 'XPS 13 9365' ) THEN '2.24.0'
      WHEN CS.Model0 In ( 'XPS 15 9575' ) THEN '1.25.0'
      WHEN CS.Model0 In ( 'HP Z420 Workstation' ) THEN 'Unknown'
      WHEN CS.Model0 In ( 'To be filled by O.E.M.' ) THEN 'Unknown'
      WHEN CS.Model0 In ( 'ProLiant BL685c G6' ) THEN 'Unknown'
      WHEN CS.Model0 In ( 'ProLiant DL360 Gen10' ) THEN 'Unknown'
      WHEN CS.Model0 In ( 'S3420GP' ) THEN 'Unknown'
      WHEN CS.Model0 In ( 'PowerEdge 2950' ) THEN 'Unknown'
      ELSE 'BIOS CHECK N/A'
END AS 'Latest BIOS (2023/03/08)',
/* ############################################################################################################################## */
/* ############################################################################################################################## */
 (SELECT CONVERT(DATE,SYS.Creation_Date0)) 'Managed Date', 
 SUM(ISNULL(RAM.Capacity0,0)) 'Memory (MB)', 
 COUNT(RAM.ResourceID) '# Memory Slots',
 REPLACE (cs.SystemType0,'-based PC','') 'Type',
 SUM(D.Size0) / 1024 AS 'Disk Size GB',
 CONVERT(VARCHAR(26), OS.LastBootUpTime0, 100) AS 'Last Reboot Date/Time',
 CONVERT(VARCHAR(26), OS.InstallDate0, 101) AS 'Install Date',
 CONVERT(VARCHAR(26), WS.LastHWScan, 101) AS 'Last Hardware Inventory',
 CONVERT(VARCHAR(26), CH.LastOnline, 101) AS 'Last Seen Online',
 SYS.Client_Version0 as 'SCCM Agent Version',
 CPU.Manufacturer AS 'CPU Man.',
 CPU.[Number of CPUs] AS '# of CPUs',
 CPU.[Number of Cores per CPU] AS '# of Cores per CPU',
 CPU.[Logical CPU Count] AS 'Logical CPU Count', 
 US.ScanTime AS ' Windows Updates Scan Time' ,
 US.LastErrorCode AS ' Windows Updates Last Error Code' ,
 US.LastScanPackageLocation AS ' Windows Updates Last Package Location'
FROM
 v_R_System SYS
 INNER JOIN (
 SELECT
 Name0,
 MAX(Creation_Date0) AS Creation_Date
 FROM
 dbo.v_R_System 
 GROUP BY
 Name0
 ) AS CleanSystem
 ON SYS.Name0 = CleanSystem.Name0 AND SYS.Creation_Date0 = CleanSystem.Creation_Date
 LEFT JOIN v_GS_COMPUTER_SYSTEM CS 
 ON SYS.ResourceID=cs.ResourceID
 LEFT JOIN v_GS_PC_BIOS BIOS 
 ON SYS.ResourceID=bios.ResourceID
 LEFT JOIN (
 SELECT
 A.ResourceID,
 MAX(A.[InstallDate0]) AS [InstallDate0]
 FROM
 v_GS_OPERATING_SYSTEM A
 GROUP BY
 A.ResourceID
 ) AS X
 ON SYS.ResourceID = X.ResourceID
 INNER JOIN v_GS_OPERATING_SYSTEM OS 
 ON X.ResourceID=OS.ResourceID AND X.InstallDate0 = OS.InstallDate0
 LEFT JOIN v_GS_PHYSICAL_MEMORY RAM 
 ON SYS.ResourceID=ram.ResourceID
 LEFT OUTER JOIN dbo.v_GS_LOGICAL_DISK D
 ON SYS.ResourceID = D.ResourceID AND D.DriveType0 = 3
 LEFT OUTER JOIN v_GS_SYSTEM_CONSOLE_USAGE_MAXGROUP U
 ON SYS.ResourceID = U.ResourceID 
 LEFT JOIN dbo.v_GS_SYSTEM_ENCLOSURE SE ON SYS.ResourceID = SE.ResourceID
 LEFT JOIN dbo.v_GS_ENCRYPTABLE_VOLUME En ON SYS.ResourceID = En.ResourceID
 LEFT JOIN dbo.v_GS_WORKSTATION_STATUS WS ON SYS.ResourceID = WS.ResourceID
 LEFT JOIN v_CH_ClientSummary CH
 ON SYS.ResourceID = CH.ResourceID
 LEFT JOIN (
 SELECT
 DISTINCT(CPU.SystemName0) AS [System Name],
 CPU.Manufacturer0 AS Manufacturer,
 CPU.ResourceID,
 CPU.Name0 AS Name,
 COUNT(CPU.ResourceID) AS [Number of CPUs],
 CPU.NumberOfCores0 AS [Number of Cores per CPU],
 CPU.NumberOfLogicalProcessors0 AS [Logical CPU Count]
 FROM [dbo].[v_GS_PROCESSOR] CPU
 GROUP BY
 CPU.SystemName0,
 CPU.Manufacturer0,
 CPU.Name0,
 CPU.NumberOfCores0,
 CPU.NumberOfLogicalProcessors0,
 CPU.ResourceID
 ) CPU
 ON CPU.ResourceID = SYS.ResourceID
 LEFT JOIN v_UpdateScanStatus US
 ON US.ResourceID = SYS.ResourceID
WHERE SYS.obsolete0=0 AND SYS.client0=1 AND SYS.obsolete0=0 AND SYS.active0=1 AND
 CH.LastOnline BETWEEN @BackInTime AND GETDATE()
 GROUP BY
 SYS.Creation_Date0 ,
 SYS.Name0 , 
 SYS.ResourceID ,
 SYS.AD_Site_Name0 ,
 CS.UserName0 ,
 OS.Caption0, 
Case
	when OS.BuildNumber0 = 10240 then '1507'
	when OS.BuildNumber0 = 10586 then '1511'
	when OS.BuildNumber0 = 14393 then '1607'
	when OS.BuildNumber0 = 15063 then '1703'
	when OS.BuildNumber0 = 16299 then '1709'
	when OS.BuildNumber0 = 17134 then '1803'
	when OS.BuildNumber0 = 17763 then '1809'
	when OS.BuildNumber0 = 18362 then '19H1'
	when OS.BuildNumber0 = 18363 then '1909'
    when OS.BuildNumber0 = 19042 then '20H2'
    when OS.BuildNumber0 = 19043 then '21H2'
	when OS.BuildNumber0 = 19044 then '21H2'	
    when OS.BuildNumber0 = 19045 then '22H2'			
else 'Unknown' end,
 Case
	when OS.BuildNumber0 = 10240 then '1507'
	when OS.BuildNumber0 = 10586 then '1511'
	when OS.BuildNumber0 = 14393 then '1607'
	when OS.BuildNumber0 = 15063 then '1703'
	when OS.BuildNumber0 = 16299 then '1709'
	when OS.BuildNumber0 = 17134 then '1803'
	when OS.BuildNumber0 = 17763 then '1809'
	when OS.BuildNumber0 = 18362 then '19H1'
	when OS.BuildNumber0 = 18363 then '1909'
    when OS.BuildNumber0 = 19042 then '20H2'
    when OS.BuildNumber0 = 19043 then '21H2'
	when OS.BuildNumber0 = 19044 then '21H2'
    when OS.BuildNumber0 = 19045 then '22H2'
    when OS.BuildNumber0 = 19045 then '22H2'	
else 'Unknown' end,
case 
	when Sys.OSRemoteLocale01 = -1 then '(WIPB) Pre-release'
	when Sys.OSRemoteLocale01 = 0 then '(CB) Release-Ready'
	when Sys.OSRemoteLocale01 = 1 then '(CBB) Business-Ready'
	when Sys.OSRemoteLocale01 = 2 then '(LTSB) Mission critical'
Else 'Unknown' end, 
OS.BuildNumber0,
 REPLACE (OS.CSDVersion0,'Service Pack','SP'),
 CS.Manufacturer0 ,
 CS.Model0 ,
 BIOS.SerialNumber0 ,
 REPLACE (cs.SystemType0,'-based PC','') ,
 CONVERT(VARCHAR(26), OS.LastBootUpTime0, 100) ,
 CONVERT(VARCHAR(26), OS.InstallDate0, 101) ,
 CONVERT(VARCHAR(26), WS.LastHWScan, 101),
 CASE
 WHEN U.TopConsoleUser0 = '-1' OR U.TopConsoleUser0 IS NULL THEN 'N/A'
 ELSE U.TopConsoleUser0
 END,
 CPU.Manufacturer, 
 CPU.[Number of CPUs] ,
 CPU.[Number of Cores per CPU], 
 CPU.[Logical CPU Count],
 US.ScanTime ,
 US.LastErrorCode ,
 US.LastScanPackageLocation ,
 CASE SE.ChassisTypes0 
	 WHEN '1' THEN 'VM / Other'
	 WHEN '2' THEN 'Unknown'
	 WHEN '3' THEN 'Desktop'
	 WHEN '4' THEN 'Low Profile Desktop'
	 WHEN '5' THEN 'Pizza Box'
	 WHEN '6' THEN 'Mini Tower'
	 WHEN '7' THEN 'Tower'
	 WHEN '8' THEN 'Portable'
	 WHEN '9' THEN 'Laptop'
	 WHEN '10' THEN 'Laptop'
	 WHEN '11' THEN 'Hand Held'
	 WHEN '12' THEN 'Docking Station'
	 WHEN '13' THEN 'All-in-One'
	 WHEN '14' THEN 'Sub Notebook'
	 WHEN '15' THEN 'Space-Saving'
	 WHEN '16' THEN 'Desktop'
	 WHEN '17' THEN 'Main System Chassis'
	 WHEN '18' THEN 'Expansion Chassis'
	 WHEN '19' THEN 'SubChassis'
	 WHEN '20' THEN 'Bus Expansion Chassis'
	 WHEN '21' THEN 'Peripheral Chassis'
	 WHEN '22' THEN 'Storage Chassis'
	 WHEN '23' THEN 'Rack Mount Chassis'
	 WHEN '24' THEN 'Sealed-Case PC'
	 WHEN '31' THEN 'All-In-One'
	 WHEN '32' THEN 'All-In-One'
 ELSE 'Undefinded'
 END ,
 CONVERT (DATE,BIOS.ReleaseDate0) , 
 BIOS.SMBIOSBIOSVersion0 ,
 SYS.Client_Version0 ,
 CONVERT(VARCHAR(26) ,CH.LastOnline, 101)
 ORDER BY SYS.Name0"
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
'ResourceID,Name,AD Site,User Name,Top User,Ooperating System,OS Version,OS CodeName,OS RemoteLocale,OS Build Number,Manufacturer,Model Name,PC Type,PC Serial Number,BIOS Date,BIOS Version,Latest BIOS,BIOS Status,OS Managed Date,Memory (MB),Memory Slots,RAM Type,Disksize (GB),LastReboot Date/Time,OS Install Date,SCCM Last Hardware Inventory,SCCM Last Seen Online,SCCM Agent Version,CPU Manufacturer,Num CPUs,Num Cores per CPU,Logical CPU Count,Updates Scan Time,Updates Last Error Code,Updates LastPackage Location' | Set-Content $SCCMFile

$output = @()
ForEach ($Check in $SQL_Check)
{
    [string]$ResourceID = $Check."ResourceID"
          [string]$Name = $Check."Name"
        [string]$ADSite = $Check."ADSite"
      [string]$UserName = $Check."User Name"
       [string]$TopUser = $Check."TopUser"
            [string]$OS = $Check."OS"
       [string]$Version = $Check."Version"
      [string]$CodeName = $Check."Code name"
      [string]$OSRemoteLocale = $Check."OS RemoteLocale"
   [string]$BuildNumber = $Check."Build Number"
  [string]$Manufacturer = $Check."Manufacturer"
     [string]$ModelName = $Check."Model Name"
        [string]$PCType = $Check."PC Type"
  [string]$SerialNumber = $Check."Serial Number"
      [string]$BIOSDate = $Check."BIOS Date"
   [string]$BIOSVersion = $Check."BIOS Version"
    [string]$LatestBIOS = $Check."Latest BIOS (2023/03/08)"

##########################################################
    #$ErrorActionPreference = 'SilentlyContinue'
    $BIOSStatus = $Null
    If (($LatestBIOS -eq 'BIOS CHECK N/A') -or ($LatestBIOS -eq 'Unknown'))
    { $BIOSStatus = 'Unable to Resolve' }
    #######################
    # BIOS with letter values
    ElseIf (($ModelName -eq 'Desktop - Dell Inc. OptiPlex 7010') -or `
            ($ModelName -eq 'Desktop - Dell Inc. OptiPlex 9020') -or `
            ($ModelName -eq 'Laptop - Dell Inc. Latitude E5540') -or `
            ($ModelName -eq 'Laptop - Dell Inc. Latitude E5550')) {
        [char]$B21 = $BIOSVersion[0]
        [char]$B22 = $BIOSVersion[1]
        [char]$B23 = $BIOSVersion[2]
        [char]$LB21 = $LatestBIOS[0]
        [char]$LB22 = $LatestBIOS[1]
        [char]$LB23 = $LatestBIOS[2]
        If (($ModelName -eq 'Desktop - Dell Inc. OptiPlex 7010')  -AND ($B21 -ge $LB21) -AND ($B22 -ge $LB22) -AND ($B23 -ge $LB23)) { $BIOSStatus = 'Up-to-date' }    ElseIf ($ModelName -eq 'Desktop - Dell Inc. OptiPlex 7010')  { $BIOSStatus = 'Outdated' }	
        If (($ModelName -eq 'Desktop - Dell Inc. OptiPlex 9020')  -AND ($B21 -ge $LB21) -AND ($B22 -ge $LB22) -AND ($B23 -ge $LB23)) { $BIOSStatus = 'Up-to-date' }    ElseIf ($ModelName -eq 'Desktop - Dell Inc. OptiPlex 9020')  { $BIOSStatus = 'Outdated' }
        If (($ModelName -eq 'Laptop - Dell Inc. Latitude E5540')  -AND ($B21 -ge $LB21) -AND ($B22 -ge $LB22) -AND ($B23 -ge $LB23)) { $BIOSStatus = 'Up-to-date' }    ElseIf ($ModelName -eq 'Laptop - Dell Inc. Latitude E5540')  { $BIOSStatus = 'Outdated' }
        If (($ModelName -eq 'Laptop - Dell Inc. Latitude E5550')  -AND ($B21 -ge $LB21) -AND ($B22 -ge $LB22) -AND ($B23 -ge $LB23)) { $BIOSStatus = 'Up-to-date' }    ElseIf ($ModelName -eq 'Laptop - Dell Inc. Latitude E5550')  { $BIOSStatus = 'Outdated' }
    }
    #######################
    # Sigh.... Lenovos
    ElseIf (($ModelName -eq 'Laptop - Lenovo Thinkpad P43S') -or `
            ($ModelName -eq 'Laptop - Lenovo Thinkpad X1 CARBON')) {
        [Int]$LB1 = $BIOSVersion.split('(')[1].split('.')[0]
        [Int]$LB2 = $BIOSVersion.split('(')[1].split('.')[1].split(' ')[0]
        #[Int]$LB3 = $BIOSVersion.split('(')[1].split('.')[2]
        [Int]$LLB1 = $LatestBIOS.split('.')[0]
        [Int]$LLB2 = $LatestBIOS.split('.')[1]
        If (($ModelName -eq 'Laptop - Lenovo Thinkpad P43S')      -AND ($LB1 -ge $LLB1) -AND ($LB2 -ge $LLB2)) { $BIOSStatus = 'Up-to-date' } ElseIf ($ModelName -eq 'Laptop - Lenovo Thinkpad P43S')  { $BIOSStatus = 'Outdated' }
        If (($ModelName -eq 'Laptop - Lenovo Thinkpad X1 CARBON') -AND ($LB1 -ge $LB21) -AND ($LB2 -ge $LLB2)) { $BIOSStatus = 'Up-to-date' } ElseIf ($ModelName -eq 'Laptop - Lenovo Thinkpad X1 CARBON')  { $BIOSStatus = 'Outdated' }
    }
    #######################
    # Typical Dells
    Else {
    [Int]$B1 = $BIOSVersion.split('.')[0]
    [Int]$B2 = $BIOSVersion.split('.')[1]
    [Int]$B3 = $BIOSVersion.split('.')[2]
    [Int]$LB1 = $LatestBIOS.split('.')[0]
    [Int]$LB2 = $LatestBIOS.split('.')[1]
    [Int]$LB3 = $LatestBIOS.split('.')[2]

	If (($ModelName -eq 'Desktop - Dell Inc. OptiPlex 7000')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }          ElseIf ($ModelName -eq 'Desktop - Dell Inc. OptiPlex 7000')  { $BIOSStatus = 'Outdated' }
	If (($ModelName -eq 'Desktop - Dell Inc. OptiPlex 7020')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }          ElseIf ($ModelName -eq 'Desktop - Dell Inc. OptiPlex 7020')  { $BIOSStatus = 'Outdated' }	
    If (($ModelName -eq 'Desktop - Dell Inc. OptiPlex 7040')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }          ElseIf ($ModelName -eq 'Desktop - Dell Inc. OptiPlex 7040')  { $BIOSStatus = 'Outdated' }
    If (($ModelName -eq 'Desktop - Dell Inc. OptiPlex 7050')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }          ElseIf ($ModelName -eq 'Desktop - Dell Inc. OptiPlex 7050')  { $BIOSStatus = 'Outdated' }
    If (($ModelName -eq 'Desktop - Dell Inc. OptiPlex 7060')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }          ElseIf ($ModelName -eq 'Desktop - Dell Inc. OptiPlex 7060')  { $BIOSStatus = 'Outdated' }
    If (($ModelName -eq 'Desktop - Dell Inc. OptiPlex 7070')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }          ElseIf ($ModelName -eq 'Desktop - Dell Inc. OptiPlex 7070')  { $BIOSStatus = 'Outdated' }
    If (($ModelName -eq 'Desktop - Dell Inc. OptiPlex 7080')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }          ElseIf ($ModelName -eq 'Desktop - Dell Inc. OptiPlex 7080')  { $BIOSStatus = 'Outdated' }
    If (($ModelName -eq 'Desktop - Dell Inc. OptiPlex 7090')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }          ElseIf ($ModelName -eq 'Desktop - Dell Inc. OptiPlex 7090')  { $BIOSStatus = 'Outdated' }
    If (($ModelName -eq 'Desktop - Dell Inc. Precision 3630 Tower')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }   ElseIf ($ModelName -eq 'Desktop - Dell Inc. Precision 3630 Tower')  { $BIOSStatus = 'Outdated' }
	If (($ModelName -eq 'Laptop - Dell Inc. Latitude 5290 2-in-1')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }    ElseIf ($ModelName -eq 'Laptop - Dell Inc. Latitude 5290 2-in-1')  { $BIOSStatus = 'Outdated' }
    If (($ModelName -eq 'Laptop - Dell Inc. Latitude 5480')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }           ElseIf ($ModelName -eq 'Laptop - Dell Inc. Latitude 5480')  { $BIOSStatus = 'Outdated' }
    If (($ModelName -eq 'Laptop - Dell Inc. Latitude 5500')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }           ElseIf ($ModelName -eq 'Laptop - Dell Inc. Latitude 5500')  { $BIOSStatus = 'Outdated' }
    If (($ModelName -eq 'Laptop - Dell Inc. Latitude 5510')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }           ElseIf ($ModelName -eq 'Laptop - Dell Inc. Latitude 5510')  { $BIOSStatus = 'Outdated' }
    If (($ModelName -eq 'Laptop - Dell Inc. Latitude 5520')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }           ElseIf ($ModelName -eq 'Laptop - Dell Inc. Latitude 5520')  { $BIOSStatus = 'Outdated' }
    If (($ModelName -eq 'Laptop - Dell Inc. Latitude 5530')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }           ElseIf ($ModelName -eq 'Laptop - Dell Inc. Latitude 5530')  { $BIOSStatus = 'Outdated' }
    If (($ModelName -eq 'Laptop - Dell Inc. Latitude 5580')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }           ElseIf ($ModelName -eq 'Laptop - Dell Inc. Latitude 5580')  { $BIOSStatus = 'Outdated' }
    If (($ModelName -eq 'Laptop - Dell Inc. Latitude 5590')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }           ElseIf ($ModelName -eq 'Laptop - Dell Inc. Latitude 5590')  { $BIOSStatus = 'Outdated' }	
    If (($ModelName -eq 'Laptop - Dell Inc. Latitude 7390')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }           ElseIf ($ModelName -eq 'Laptop - Dell Inc. Latitude 7390')  { $BIOSStatus = 'Outdated' }
    If (($ModelName -eq 'Laptop - Dell Inc. Latitude 7400 2-in-1')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }    ElseIf ($ModelName -eq 'Laptop - Dell Inc. Latitude 7400 2-in-1')  { $BIOSStatus = 'Outdated' }
    If (($ModelName -eq 'Laptop - Dell Inc. Latitude 7400')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }           ElseIf ($ModelName -eq 'Laptop - Dell Inc. Latitude 7400')  { $BIOSStatus = 'Outdated' }
    If (($ModelName -eq 'Laptop - Dell Inc. Latitude 7410')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }           ElseIf ($ModelName -eq 'Laptop - Dell Inc. Latitude 7410')  { $BIOSStatus = 'Outdated' }
    If (($ModelName -eq 'Laptop - Dell Inc. Latitude 7420')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }           ElseIf ($ModelName -eq 'Laptop - Dell Inc. Latitude 7420')  { $BIOSStatus = 'Outdated' }
    If (($ModelName -eq 'Laptop - Dell Inc. Latitude 7430')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }           ElseIf ($ModelName -eq 'Laptop - Dell Inc. Latitude 7430')  { $BIOSStatus = 'Outdated' }
    If (($ModelName -eq 'Laptop - Dell Inc. Latitude 7480')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }           ElseIf ($ModelName -eq 'Laptop - Dell Inc. Latitude 7480')  { $BIOSStatus = 'Outdated' }
    If (($ModelName -eq 'Laptop - Dell Inc. Latitude 9510')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }           ElseIf ($ModelName -eq 'Laptop - Dell Inc. Latitude 9510')  { $BIOSStatus = 'Outdated' }
    If (($ModelName -eq 'Laptop - Dell Inc. Latitude E5570')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }          ElseIf ($ModelName -eq 'Laptop - Dell Inc. Latitude E5570')  { $BIOSStatus = 'Outdated' }
    If (($ModelName -eq 'Laptop - Dell Inc. Latitude E7440')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }          ElseIf ($ModelName -eq 'Laptop - Dell Inc. Latitude E7440')  { $BIOSStatus = 'Outdated' }
    If (($ModelName -eq 'Laptop - Dell Inc. Latitude E7470')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }          ElseIf ($ModelName -eq 'Laptop - Dell Inc. Latitude E7470')  { $BIOSStatus = 'Outdated' }
    If (($ModelName -eq 'Laptop - Dell Inc. Latitude XPS 13 (9365)')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }  ElseIf ($ModelName -eq 'Laptop - Dell Inc. Latitude XPS 13 (9365)')  { $BIOSStatus = 'Outdated' }
    If (($ModelName -eq 'Laptop - Dell Inc. Latitude XPS 15 (9575)')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }  ElseIf ($ModelName -eq 'Laptop - Dell Inc. Latitude XPS 15 (9575)')  { $BIOSStatus = 'Outdated' }
    If (($ModelName -eq 'Laptop - Dell Inc. Precision 3551')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }          ElseIf ($ModelName -eq 'Laptop - Dell Inc. Precision 3551')  { $BIOSStatus = 'Outdated' }
    If (($ModelName -eq 'Laptop - Dell Inc. Precision 7740')  -AND ($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' }          ElseIf ($ModelName -eq 'Laptop - Dell Inc. Precision 7740')  { $BIOSStatus = 'Outdated' }
    #######################
    # VMWare VMs
    If ($ModelName -eq 'VMWare Virtual Machine') { $BIOSStatus = 'VM' }  
    #######################
	# Servers
    If ($ModelName -eq 'Desktop - HP Z240 Workstation') { $BIOSStatus = 'Unable to Resolve' }	
	If ($ModelName -eq 'Server - ProLiant BL685c G6')   { $BIOSStatus = 'Unable to Resolve' }
    If ($ModelName -eq 'Server - ProLiant DL360 Gen10') { $BIOSStatus = 'Unable to Resolve' }
    If ($ModelName -eq 'Server - S3420GP')  { $BIOSStatus = 'Unable to Resolve' }
    #######################	
    }
    #$ErrorActionPreference = 'Continue'
    
    ##########################################################
                   [string]$ManagedDate = $Check."Managed Date"
                      [string]$MemoryMB = $Check."Memory (MB)"
                   [string]$MemorySlots = $Check."# Memory Slots"
                          [string]$Type = $Check."Type"
                    [string]$DiskSizeGB = $Check."Disk Size GB"
            [string]$LastRebootDateTime = $Check."Last Reboot Date/Time"
                   [string]$InstallDate = $Check."Install Date"
         [string]$LastHardwareInventory = $Check."Last Hardware Inventory"
                [string]$LastSeenOnline = $Check."Last Seen Online"
              [string]$SCCMAgentVersion = $Check."SCCM Agent Version"
                        [string]$CPUMan = $Check."CPU Man"
                       [string]$NumCPUs = $Check."# of CPUs"
                      [string]$NumCores = $Check."# of Cores per CPU"
               [string]$LogicalCPUCount = $Check."Logical CPU Count"
               [string]$UpdatesScanTime = $Check."Windows Updates Scan Time"
          [string]$UpdatesLastErrorCode = $Check."Windows Updates Last Error Code"
    [string]$UpdatesLastPackageLocation = $Check."Windows Updates Last Package Location"

    $output += '"' + $ResourceID                + '","' + `
                    $Name                       + '","' + `
                    $ADSite                     + '","' + `
                    $UserName                   + '","' + `
                    $TopUser                    + '","' + `
                    $OS                         + '","' + `
                    $Version                    + '","' + `
                    $CodeName                   + '","' + `
                    $OSRemoteLocale                   + '","' + `
                    $BuildNumber                + '","' + `
                    $Manufacturer               + '","' + `
                    $ModelName                  + '","' + `
                    $PCType                     + '","' + `
                    $SerialNumber               + '","' + `
                    $BIOSDate                   + '","' + `
                    $BIOSVersion                + '","' + `
                    $LatestBIOS                 + '","' + `
                    $BIOSStatus                 + '","' + `
                    $ManagedDate                + '","' + `
                    $MemoryMB                   + '","' + `
                    $MemorySlots                + '","' + `
                    $Type                       + '","' + `
                    $DiskSizeGB                 + '","' + `
                    $LastRebootDateTime         + '","' + `
                    $InstallDate                + '","' + `
                    $LastHardwareInventory      + '","' + `
                    $LastSeenOnline             + '","' + `
                    $SCCMAgentVersion           + '","' + `
                    $CPUMan                     + '","' + `
                    $NumCPUs                    + '","' + `
                    $NumCores                   + '","' + `
                    $LogicalCPUCount            + '","' + `
                    $UpdatesScanTime            + '","' + `
                    $UpdatesLastErrorCode       + '","' + `
                    $UpdatesLastPackageLocation + '"'
}
$output | Add-Content $SCCMFile
Write-Host "done." -ForegroundColor Green
##########################################################
##########################################################
# Cleanup SCCM Report
Write-Host "$(Get-Date)`t--`tCleaning up SCCM report..." -NoNewline -ForegroundColor Yellow
    If (Test-Path $SCCMFile)
    {
        "ResourceID,Name,AD Site,User Name,Top User,Operating System,OS Version,OS CodeName,OS RemoteLocale,OS Build Number,Manufacturer,Model Name,PC Type,PC Serial Number,BIOS Date,BIOS Version,Latest BIOS,BIOS Status,OS Managed Date,Memory (MB),Memory Slots,RAM Type,Disksize (GB),LastReboot Date/Time,OS Install Date,SCCM Last Hardware Inventory,SCCM Last Seen Online,Most Recent Record,SCCM Agent Version,CPU Manufacturer,Num CPUs,Num Cores per CPU,Logical CPU Count,Updates Scan Time,Updates Last Error Code,Updates LastPackage Location" | Set-Content $SCCM_Mod1

        $Content = Import-Csv $SCCMFile
        ForEach ($Line in  $Content)
        {
            $ResourceID                 = $line.'ResourceID'.Trim()
            $Name                       = $line.'Name'.Trim()
            $ADSite                     = $line.'AD Site'.Trim()
            $UserName                   = $line.'User Name' -replace ('DOMAIN\\', '').Trim()
            $TopUser                    = $line.'Top User' -replace ('DOMAIN\\', '').Trim()
            $OS                         = $line.'Ooperating System'.Trim()
            $OSVersion                  = $line.'OS Version'.Trim()
            $OSCodeName                 = $line.'OS Codename'.Trim()
            $OSRemoteLocale                   = $line.'OS RemoteLocale'.Trim()
            $OSBuildNumber              = $line.'OS Build Number'.Trim()
            $Manufacturer               = $line.'Manufacturer'.Trim()
            $ModelName                  = $line.'Model Name'.Trim()
            $PCType                     = $line.'PC Type'.Trim()
            $PCSerialNumber             = $line.'PC Serial Number'.Trim()
            $BIOSDate                   = $line.'BIOS Date'.Trim()
            $BIOSVersion                = $line.'BIOS Version'.Trim()
            $LatestBIOS                 = $line.'Latest BIOS'.Trim()
            $BIOSStatus                 = $line.'BIOS Status'.Trim()
            $OSManagedDate              = $line.'OS Managed Date'.Trim()
            $Memory                     = $line.'Memory (MB)'.Trim()
            $MemorySlots                = $line.'Memory Slots'
            $RAMType                    = $line.'RAM Type'.Trim()
            $Disksize                   = $line.'Disksize (GB)'.Trim()
            $LastRebootDateTime         = $line.'LastReboot Date/Time'.Trim()
            $OSInstallDate              = $line.'OS Install Date'.Trim()
            $SCCMLastHardwareInventory  = $line.'SCCM Last Hardware Inventory'.Trim()
            $SCCMLastSeenOnline         = $line.'SCCM Last Seen Online'.Trim()
            $SCCMAgentVersion           = $line.'SCCM Agent Version'.Trim()
            $CPUManufacturer            = $line.'CPU Manufacturer'.Trim()
            $NumCPUs                    = $line.'Num CPUs'.Trim()
            $NumCores                   = $line.'Num Cores per CPU'.Trim()
            $LogicalCPUCount            = $line.'Logical CPU Count'.Trim()
            $UpdatesScanTime            = $line.'Updates Scan Time'.Trim()
            $UpdatesLastErrorCode       = $line.'Updates Last Error Code'.Trim()
            $UpdatesLastPackageLocation = $line.'Updates LastPackage Location'.Trim()
    
            $MostRecentRecord = $null
            $DLength = $SCCMLastHardwareInventory.length
            $LLength = $SCCMLastSeenOnline.length

            If ($DLength -eq '0') { $SCCMLastHardwareInventory = "2000-01-01" }
            If ($LLength -eq '0') { $SCCMLastSeenOnline = "2000-01-01" }


            $SCCMLSO = $SCCMLastSeenOnline.split('/')[2] + '-' + $SCCMLastSeenOnline.split('/')[0] + '-' + $SCCMLastSeenOnline.split('/')[1]
            $SCCMLHI = $SCCMLastHardwareInventory.split('/')[2] + '-' + $SCCMLastHardwareInventory.split('/')[0] + '-' + $SCCMLastHardwareInventory.split('/')[1]

                            If (($DLength -eq '0') -and ($LLength -eq '0')) { $MostRecentRecord = "N/A" }
                        ElseIf (($DLength -eq '0') -and ($LLength -ne '0')) { $MostRecentRecord = $SCCMLSO }
                        ElseIf (($DLength -ne '0') -and ($LLength -eq '0')) { $MostRecentRecord = $SCCMLHI }
                                           ElseIf ($SCCMLHI -gt $SCCMLSO)   { $MostRecentRecord = $SCCMLHI }
                                                                       Else { $MostRecentRecord = $SCCMLSO }

            "`"$ResourceID`",`"$Name`",`"$ADSite`",`"$UserName`",`"$TopUser`",`"$OS`",`"$OSVersion`",`"$OSCodeName`",`"$OSRemoteLocale`",`"$OSBuildNumber`",`"$Manufacturer`",`"$ModelName`",`"$PCType`",`"$PCSerialNumber`",`"$BIOSDate`",`"$BIOSVersion`",`"$LatestBIOS`",`"$BIOSStatus`",`"$OSManagedDate`",`"$Memory`",`"$MemorySlots`",`"$RAMType`",`"$Disksize`",`"$LastRebootDateTime`",`"$OSInstallDate`",`"$SCCMLastHardwareInventory`",`"$SCCMLastSeenOnline`",`"$MostRecentRecord`",`"$SCCMAgentVersion`",`"$CPUManufacturer`",`"$NumCPUs`",`"$NumCores`",`"$LogicalCPUCount`",`"$UpdatesScanTime`",`"$UpdatesLastErrorCode`",`"$UpdatesLastPackageLocation`"" | Add-Content $SCCM_Mod1
        }
        Start-Sleep -Seconds 5
        Rename-Item -NewName $SCCM_Mod2 -Path $SCCM_Mod1 -Force
        Import-Csv $SCCM_Mod2 | sort 'Most Recent Record' -Descending | Export-Csv -Path $SCCM_Mod1 -NoTypeInformation
    }
    Else
    {
        Write-Host ""
        Write-Host "Hey, dum dum it doesn't look like " -NoNewline -ForegroundColor Cyan  
        Write-host "$SCCMFile " -ForegroundColor Green  -NoNewline
        Write-Host "exists..." -ForegroundColor Cyan  
        Write-Host ""
        Write-Host "You may not have access to run that report!!!" -ForegroundColor Cyan
        Write-host "$computer " -ForegroundColor Green -NoNewline
        Write-Host ""
        Write-Host "Action cancelled." -ForegroundColor Red
        Read-Host -Prompt 'Press Enter to exit...'
        Exit
    }
Write-Host "done." -ForegroundColor Green
########################################################################################################################################
}

#5 SNOW
Function SNOW { 
########################################################################################################################################
Write-Host "$(Get-Date)`t--`tCleaning up SNOW report..." -NoNewline -ForegroundColor Yellow
# $ErrorActionPreference = 'SilentlyContinue'

"Computer,Operating System,Asset Tag,Serial Number,Install Status,Model ID,Most Recent Record,Assigned To,User ID,Email,Title,Department,Manager,Purchase Date,Created On,Assigned Time,Updated On,Last Login,Last Discovered,Marked for Disposal,Picked Up for Disposal,Disposal Verified" | Set-Content $SNOW_Mod1

$SNOWContent = Import-Csv $SNOWIWR
ForEach ($Item in  $SNOWContent)
{
    $Computer        = $Item.'name'.Trim()
    $OperatingSystem = $Item.'os'.Trim()
    $Assettag        = $Item.'asset_tag'.Trim()
    $Serialnumber    = $Item.'serial_number'.Trim()
    $InstallStatus   = $Item.'install_status'.Trim()
    $ModelID         = $Item.'model_id'.Trim()
    $PurchaseDate    = $Item.'purchase_date'.Trim()
    $CreatedOn       = $Item.'sys_created_on'.Trim()
    $AssignedTime    = $Item.'assigned'.Trim()
    $UpdatedOn       = $Item.'asset.sys_updated_on'.Trim()
    $LastLogin       = $Item.'assigned_to.last_login_time'.Trim()
    $LastDiscovered  = $Item.'last_discovered'.Trim()
    $MarkedforDisp   = $Item.'asset.ref_alm_hardware.u_date_marked_for_disposal'.Trim()
    $PickedUpforDisp = $Item.'asset.ref_alm_hardware.u_date_picked_up_by_disposal_v'.Trim()
    $DispVerfDate    = $Item.'asset.ref_alm_hardware.u_date_disposal_verification_r'.Trim()
    $AssignedTo      = $Item.'assigned_to.name'.Trim()
    $UserID          = $Item.'assigned_to.user_name'.Trim()
    $Email           = $Item.'assigned_to.email'.Trim()
    $Title           = $Item.'assigned_to.title'.Trim()
    $Department      = $Item.'assigned_to.department'.Trim()
    $Manager         = $Item.'assigned_to.manager'.Trim()

    $MostRecentRecord = $null
    
    If ($PurchaseDate.length -eq '0')    { $PurchaseDate = "2000-01-01" }
    If ($CreatedOn.length -eq '0')       { $CreatedOn = "2000-01-01" }
    If ($AssignedTime.length -eq '0')    { $AssignedTime = "2000-01-01" }
    If ($UpdatedOn.length -eq '0')       { $UpdatedOn = "2000-01-01" }
    If ($LastLogin.length -eq '0')       { $LastLogin = "2000-01-01" }
    If ($LastDiscovered.length -eq '0')  { $LastDiscovered = "2000-01-01" }
    If ($MarkedforDisp.length -eq '0')   { $MarkedforDisp = "2000-01-01" }
    If ($PickedUpforDisp.length -eq '0') { $PickedUpforDisp = "2000-01-01" }
    If ($DispVerfDate.length -eq '0')    { $DispVerfDate = "2000-01-01" }

    $DateFields = @(
    [pscustomobject]@{Title='PurchasedDate';Value="$PurchaseDate"}
    [pscustomobject]@{Title='CreatedOn';Value="$CreatedOn"}
    [pscustomobject]@{Title='AssignedTime';Value="$AssignedTime"}
    [pscustomobject]@{Title='UpdatedOn';Value="$UpdatedOn"}
    [pscustomobject]@{Title='LastLogin';Value="$LastLogin"}  
    [pscustomobject]@{Title='LastDiscovered';Value="$LastDiscovered"}
    [pscustomobject]@{Title='MarkedforDisp';Value="$MarkedforDisp"}
    [pscustomobject]@{Title='PickedUpforDisp';Value="$PickedUpforDisp"}
    [pscustomobject]@{Title='DispVerfDate';Value="$DispVerfDate"}
    )
    $Latest = $DateFields | Sort-Object -Property Value | Select-Object -Last 1
    $MostRecentRecord = "$($latest.value)"

    "`"$Computer`",`"$OperatingSystem`",`"$Assettag`",`"$Serialnumber`",`"$InstallStatus`",`"$ModelID`",`"$MostRecentRecord`",`"$AssignedTo`",`"$UserID`",`"$Email`",`"$Title`",`"$Department`",`"$Manager`",`"$PurchaseDate`",`"$CreatedOn`",`"$AssignedTime`",`"$UpdatedOn`",`"$LastLogin`",`"$LastDiscovered`",`"$MarkedforDisp`",`"$PickedUpforDisp`",`"$DispVerfDate`"" | Add-Content $SNOW_Mod1
}
Start-Sleep -Seconds 5
Rename-Item -NewName $SNOW_Mod2 -Path $SNOW_Mod1 -Force
Start-Sleep -Seconds 5
Import-Csv $SNOW_Mod2 | sort 'Most Recent Record' -Descending | Export-Csv -Path $SNOW_Mod1 -NoTypeInformation
Write-Host "done." -ForegroundColor Green
################################################################
################################################################
Write-Host "$(Get-Date)`t--`tCleaning up SNOW Computers not discovered report..." -NoNewline -ForegroundColor Yellow
"Computer,Status,Assettag,Model,MostRecentRecord,AssignedTo,PurchaseDate,CreatedOn,AssignedTime,UpdatedOn,LastLogin,LastDiscovered,MarkedforDisp,PickedUpforDisp,DispVerfDate" | Set-Content $SNOW_CND1

$SNOWContent = Import-Csv $SNOWCND
ForEach ($Item in  $SNOWContent)
{
    $LastDiscovered  = $Item.'last_discovered'.Trim()
    $AssignedTime    = $Item.'assigned'.Trim()
    $UpdatedOn       = $Item.'sys_updated_on'.Trim()
    $CreatedOn       = $Item.'sys_created_on'.Trim()
    $PurchaseDate    = $Item.'purchase_date'.Trim()
    $MarkedforDisp   = $Item.'asset.ref_alm_hardware.u_date_marked_for_disposal'.Trim()
    $DispVerfDate    = $Item.'asset.ref_alm_hardware.u_date_disposal_verification_r'.Trim()
    $PickedUpforDisp = $Item.'asset.ref_alm_hardware.u_date_picked_up_by_disposal_v'.Trim()
    $LastLogin       = $Item.'assigned_to.last_login_time'.Trim()
    $Status          = $Item.'install_status'.Trim()
    $Computer        = $Item.'name'.Trim()
    $AssetTag        = $Item.'asset_tag'.Trim()
    $Model           = $Item.'asset.model.display_name'.Trim()
    $AssignedTo      = $Item.'assigned_to'.Trim()

    $MostRecentRecord = $null
    
    If ($LastDiscovered.length -eq '0')  { $LastDiscovered = "2000-01-01" }	
    If ($AssignedTime.length -eq '0')    { $AssignedTime = "2000-01-01" }	
    If ($UpdatedOn.length -eq '0')       { $UpdatedOn = "2000-01-01" }	
    If ($CreatedOn.length -eq '0')       { $CreatedOn = "2000-01-01" }	
    If ($PurchaseDate.length -eq '0')    { $PurchaseDate = "2000-01-01" }
    If ($MarkedforDisp.length -eq '0')   { $MarkedforDisp = "2000-01-01" }	
    If ($DispVerfDate.length -eq '0')    { $DispVerfDate = "2000-01-01" }	
	If ($PickedUpforDisp.length -eq '0') { $PickedUpforDisp = "2000-01-01" }
    If ($LastLogin.length -eq '0')       { $LastLogin = "2000-01-01" }



    $DateFields = @(
    [pscustomobject]@{Title='PurchasedDate';Value="$PurchaseDate"}
    [pscustomobject]@{Title='CreatedOn';Value="$CreatedOn"}
    [pscustomobject]@{Title='AssignedTime';Value="$AssignedTime"}
    [pscustomobject]@{Title='UpdatedOn';Value="$UpdatedOn"}
    [pscustomobject]@{Title='LastLogin';Value="$LastLogin"}  
    [pscustomobject]@{Title='LastDiscovered';Value="$LastDiscovered"}
    [pscustomobject]@{Title='MarkedforDisp';Value="$MarkedforDisp"}
    [pscustomobject]@{Title='PickedUpforDisp';Value="$PickedUpforDisp"}
    [pscustomobject]@{Title='DispVerfDate';Value="$DispVerfDate"}
    )
    $Latest = $DateFields | Sort-Object -Property Value | Select-Object -Last 1
    $MostRecentRecord = "$($latest.value)"

"`"$Computer`",`"$Status`",`"$Assettag`",`"$Model`",`"$MostRecentRecord`",`"$AssignedTo`",`"$PurchaseDate`",`"$CreatedOn`",`"$AssignedTime`",`"$UpdatedOn`",`"$LastLogin`",`"$LastDiscovered`",`"$MarkedforDisp`",`"$PickedUpforDisp`",`"$DispVerfDate`"" | Add-Content $SNOW_CND1
}
Start-Sleep -Seconds 5
If (Test-Path $SNOW_CND2) { Remove-Item -Path $SNOW_CND2 -Force | Out-Null }
Rename-Item -NewName $SNOW_CND2 -Path $SNOW_CND1 -Force
Start-Sleep -Seconds 5
Import-Csv $SNOW_CND2 | sort 'MostRecentRecord' -Descending | Export-Csv -Path $SNOW_CND1 -NoTypeInformation -Force
Write-Host "done." -ForegroundColor Green
}

#6/7 SEMPERIS
Function Semperis {
########################################################################################################################################
Write-Host "$(Get-Date)`t--`tCleaning up Semperis reports..." -ForegroundColor Yellow 
    (Get-Content $SempDisablesCSV1 | Select-Object -Skip 1) | Set-Content $SempDisablesCSV2
    (Get-Content $SempEnablesCSV1 | Select-Object -Skip 1) | Set-Content $SempEnablesCSV2
    (Get-Content $SempStalesCSV1 | Select-Object -Skip 1) | Set-Content $SempStalesCSV2

    $SempDisables = Import-Csv $SempDisablesCSV2
     $SempEnables = Import-Csv $SempEnablesCSV2
      $SempStales = Import-Csv $SempStalesCSV2
########################################################################################################################################
    Write-Host "`tModifying Semperis Disables report..." -NoNewline
    $Item = $Null					  
    "Most Recent Record,Origin Time,Last Originating Change Time,Computer,Originating Server,Originating User,New Value,Distinguished Name" | Set-Content $SempDisablesCSV3
    ForEach ($SDItem in $SempDisables)
    {
        $LastChange = $SDItem.'from_meta_lastoriginatingchangetime'.replace('Z','').Trim()      
        $Time       = $SDItem.'Origin Time'.replace('Z','').Trim()
        $SAM        = $SDItem.'samaccountname'.replace('$','').Trim()
        $From       = $SDItem.'originatingserver'.Trim()
        $By         = $SDItem.'originatingusers'.Trim()
        $Value      = $SDItem.'to_stringvalue'.Trim()
        $DN         = $SDItem.'distinguishedname'.Trim()
        If ($By.length -eq '0')    { $By = "N/A" }

        #Convert Date format to YYYY-MM-DD
        $LastChange = $LastChange.Split('/')[2].split(' ')[0] + '-' + $LastChange.Split('/')[0].padleft(2,'0') + '-' + $LastChange.Split('/')[1].padleft(2,'0') + ' ' + $LastChange.Split('/')[2].split(' ')[1]
		
		$DateFields = @(
		[pscustomobject]@{Title='Time';Value="$Time"}  
		[pscustomobject]@{Title='LastChange';Value="$LastChange"}
		)
		$Latest = $DateFields | Sort-Object -Property Value | Select-Object -Last 1
		$MostRecentRecord = "$($latest.value)"    
 		
        "`"$MostRecentRecord`",`"$Time`",`"$LastChange`",`"$SAM`",`"$From`",`"$By`",`"$Value`",`"$DN`"" | Add-Content -Path $SempDisablesCSV3
    }
    Start-Sleep -Seconds 2
    Import-Csv $SempDisablesCSV3 | sort 'Most Recent Record' -Descending | Export-Csv -Path $SempDisablesCSV4 -NoTypeInformation
    Write-Host "done." -ForegroundColor Green
    ##############################################################################################################################################################################
    Start-Sleep -Seconds 2
    ##########################################################
    Write-Host "`tModifying Semperis Enables report..." -NoNewline
    $Item = $Null
    "Most Recent Record,Originating Time,Last Originating Change Time,Originating Server,Originating User,New Value," | Set-Content $SempEnablesCSV3
    ForEach ($Item in  $SempEnables)
    {
        $LastChange = $item.'from_meta_lastoriginatingchangetime'.replace('Z','').Trim()
        $Time       = $item.'originatingtime'.replace('Z','').Trim()
        $SAM        = $item.'samaccountname'.replace('$','').Trim()
        $From       = $item.'originatingserver'.Trim()
        $By         = $item.'originatingusers'.Trim()
        $Value      = $item.'to_stringvalue'.Trim()
        $DN         = $item.'distinguishedname'.Trim()
        If ($By.length -eq '0')    { $By = "N/A" }
		
        #Convert Date format to YYYY-MM-DD
        $LastChange = $LastChange.Split('/')[2].split(' ')[0] + '-' + $LastChange.Split('/')[0].padleft(2,'0') + '-' + $LastChange.Split('/')[1].padleft(2,'0') + ' ' + $LastChange.Split('/')[2].split(' ')[1]

		$DateFields = @(
		[pscustomobject]@{Title='LastChange';Value="$LastChange"}  
		[pscustomobject]@{Title='Time';Value="$Time"}
		)		
        $Latest = $DateFields | Sort-Object -Property Value | Select-Object -Last 1
        $MostRecentRecord = "$($latest.value)"    
    		
        "`"$MostRecentRecord`",`"$Time`",`"$LastChange`",`"$SAM`",`"$From`",`"$By`",`"$Value`"" | Add-Content -Path $SempEnablesCSV3
    }
    Start-Sleep -Seconds 2
    Import-Csv $SempEnablesCSV3 | sort 'Most Recent Record' -Descending | Export-Csv -Path $SempEnablesCSV4 -NoTypeInformation
    Write-Host "done." -ForegroundColor Green
    ##############################################################################################################################################################################
    Start-Sleep -Seconds 2
    ##########################################################
    Write-Host "`tModifying Semperis Stales report..." -NoNewline
    $Item = $Null
    "Most Recent Record,Last Logon,Password Last Set,Computer Name,SAM Name,Distinguished Name" | Set-Content $SempStalesCSV3
    ForEach ($Item in  $SempStales)
    {
        $DN   = $item.'distinguishedname'.Trim()
        $Name = $item.'name'.replace('$','').Trim()
        $SAM  = $item.'samaccountname'.replace('$','').Trim()
        $LLT  = $item.'lastlogontimestamp'.replace('Z','').Trim()
        $PLS  = $item.'pwdlastset'.replace('Z','').Trim()
        If ($SAM.length -eq '0')    { $SAM = "N/A" }
       
        $DateFields = @(
        [pscustomobject]@{Title='lastlogontimestamp';Value="$LLT"}  
        [pscustomobject]@{Title='pwdlastset';Value="$PLS"}
        )
        $Latest = $DateFields | Sort-Object -Property Value | Select-Object -Last 1
        $MostRecentRecord = "$($latest.value)"       

        "`"$MostRecentRecord`",`"$LLT`",`"$PLS`",`"$Name`",`"$SAM`",`"$DN`"" | Add-Content -Path $SempStalesCSV3
     }
    Start-Sleep -Seconds 2
    Import-Csv $SempStalesCSV3 | sort 'Most Recent Record' -Descending | Export-Csv -Path $SempStalesCSV4 -NoTypeInformation
    Write-Host "done." -ForegroundColor Green
    ########################################################################################################################################
}

#4 SCCM ADOBE
Function SCCMAdobe { 
########################################################################################################################################
    Write-Host "$(Get-Date)`t--`tGenerating $SCCMAdobeCSV..." -NoNewLine -ForegroundColor Yellow
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
    'Netbios Name, Operating System,File Name,File Description,File Version,File Size,File Modified Date,File Path' | Set-Content $SCCMAdobeCSV

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
    $output | Add-Content $SCCMAdobeCSV

    Import-Csv $SCCMAdobeCSV | sort 'File Version' -Descending | Export-Csv -Path $SCCMAdobeFile -NoTypeInformation
    Write-Host "done." -ForegroundColor Green
########################################################################################################################################
}

#4 SCCM CHROME
Function SCCMChrome { 
########################################################################################################################################
    Write-Host "$(Get-Date)`t--`tGenerating $SCCMChromeCSV..." -NoNewLine -ForegroundColor Yellow
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
    'Netbios Name, Operating System,File Name,File Description,File Version,File Size,File Modified Date,File Path' | Set-Content $SCCMChromeCSV

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
    $output | Add-Content $SCCMChromeCSV

    Import-Csv $SCCMChromeCSV | sort 'File Version' -Descending | Export-Csv -Path $SCCMChromeEdit -NoTypeInformation
    Write-Host "done." -ForegroundColor Green
    ########################################################################################################################################
}

#4 SCCM EDGE
Function SCCMEdge { 
########################################################################################################################################
    Write-Host "$(Get-Date)`t--`tGenerating $SCCMEdgeCSV..." -NoNewLine -ForegroundColor Yellow
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
    'Netbios Name, Operating System,File Name,File Description,File Version,File Size,File Modified Date,File Path' | Set-Content $SCCMEdgeCSV

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
    $output | Add-Content $SCCMEdgeCSV

    Import-Csv $SCCMEdgeCSV | sort 'File Version' -Descending | Export-Csv -Path $SCCMEdgeEdit -NoTypeInformation
    Write-Host "done." -ForegroundColor Green
########################################################################################################################################
}

#4 SCCM JAVA
Function SCCMJava { 
########################################################################################################################################
    Write-Host "$(Get-Date)`t--`tGenerating $SCCMJavaCSV..." -NoNewLine -ForegroundColor Yellow
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
    'Netbios Name, Operating System,File Name,File Description,File Version,File Size,File Modified Date,File Path' | Set-Content $SCCMJavaCSV

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
    $output | Add-Content $SCCMJavaCSV

    Import-Csv $SCCMJavaCSV | sort 'File Version' -Descending | Export-Csv -Path $SCCMJavaEdit -NoTypeInformation
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
            CreateAllTextXSLX -CSVIn $AD_Users -ExcelOut $AD_UsersXLS | Out-Null
            CreateAllTextXSLX -CSVIn $AD_PC -ExcelOut $AD_PCXLS | Out-Null
            CreateAllTextXSLX -CSVIn $AD_StalePCEdit -ExcelOut $AD_StalePCXLS | Out-Null
            CreateAllTextXSLX -CSVIn $SCCM_Mod1 -ExcelOut $SCCMXLS | Out-Null
            CreateAllTextXSLX -CSVIn $SNOW_Mod1 -ExcelOut $SNOWXLS | Out-Null
            CreateAllTextXSLX -CSVIn $SNOW_CND1 -ExcelOut $CNDXLS | Out-Null
            CreateAllTextXSLX -CSVIn $SempDisablesCSV4 -ExcelOut $SempDXLS | Out-Null
            CreateAllTextXSLX -CSVIn $SempEnablesCSV4 -ExcelOut $SempEXLS | Out-Null
            CreateAllTextXSLX -CSVIn $SempStalesCSV4 -ExcelOut $SempSXLS | Out-Null
            CreateAllTextXSLX -CSVIn $SCCMAdobeEdit -ExcelOut $SCCMAdobeXLS | Out-Null
            CreateAllTextXSLX -CSVIn $SCCMChromeEdit -ExcelOut $SCCMChromeXLS | Out-Null
            CreateAllTextXSLX -CSVIn $SCCMEdgeEdit -ExcelOut $SCCMEdgeXLS | Out-Null
            CreateAllTextXSLX -CSVIn $SCCMJavaEdit -ExcelOut $SCCMJavaXLS | Out-Null
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
        $wbUser    = $excel.Workbooks.Open($AD_UsersXLS)
        $wbPC      = $excel.Workbooks.Open($AD_PCXLS)
        $wbPCStale = $excel.Workbooks.Open($AD_StalePCXLS)
        $wbSCCM    = $excel.Workbooks.Open($SCCMXLS)
        $wbSNOW    = $excel.Workbooks.Open($SNOWXLS)
        $wbCND     = $excel.Workbooks.Open($CNDXLS)
    $wbSempDisable = $excel.Workbooks.Open($SempDXLS)
    $wbSempEnable  = $excel.Workbooks.Open($SempEXLS)
    $wbSempStale   = $excel.Workbooks.Open($SempSXLS)	
        $wbAdobe   = $excel.Workbooks.Open($SCCMAdobeXLS)
        $wbChrome  = $excel.Workbooks.Open($SCCMChromeXLS)
        $wbEdge    = $excel.Workbooks.Open($SCCMEdgeXLS)
        $wbJava    = $excel.Workbooks.Open($SCCMJavaXLS)	
Write-Host "done." -ForegroundColor Green

##################################################################################################################
#1 AD USER VARIABLES
##################################################################################################################
    Write-Host "Copy sheet from $AD_UsersXLS..." -NoNewline -ForegroundColor Yellow
        $sh1_wbUser = $wbNew.sheets.item(1)                                              # first sheet in destination workbook
        $sheetToCopy = $wbUser.sheets.item('AD_Users')                                   # source sheet to copy
        $sheetToCopy.copy($sh1_wbUser)                                                   # copy source sheet to destination workbook
    Write-Host "done." -ForegroundColor Green
#########################################################
    Write-Host "`tMaking table..." -NoNewline 
    # Select area and make it a table
        $excel.ActiveSheet.ListObjects.add(1,$excel.ActiveSheet.UsedRange,0,1) | out-null
        $TableName = $($excel.ActiveSheet.ListObjects).DisplayName
        $excel.ActiveSheet.ListObjects("$TableName").TableStyle = "TableStyleMedium2"
    # How do I select an entire row?cls
        $range = $sh1_wbUser.Cells.Item(1,1).EntireRow
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
#3 AD STALE PC VARIABLES
##################################################################################################################
    Write-Host "Modify sheet from $AD_StalePCXLS..." -ForegroundColor Yellow
        $sh1_wbPCStale = $wbNew.sheets.item(1)                                           # first sheet in destination workbook
        $sheetToCopy = $wbPCStale.sheets.item('DSQuery_Stale_Computer_60_Days')          # source sheet to copy
        $sheetToCopy.name = 'AD_Stale_Computers'                                          # rename sheet to copy
        $sheetToCopy.copy($sh1_wbPCStale)                                                # copy source sheet to destination workbook
#########################################################
    Write-Host "`tMaking table..." -NoNewline 
    # Select area and make it a table
        $excel.ActiveSheet.ListObjects.add(1,$excel.ActiveSheet.UsedRange,0,1) | out-null
        $TableName = $($excel.ActiveSheet.ListObjects).DisplayName
        $excel.ActiveSheet.ListObjects("$TableName").TableStyle = "TableStyleMedium3"
    # How do I select an entire row?
        $range = $sh1_wbPCStale.Cells.Item(1,1).EntireRow
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
#4 SCCM VARIABLES
##################################################################################################################
    Write-Host "Modify sheet from $SCCMXLS..." -ForegroundColor Yellow
        $sh1_wbSCCM = $wbNew.sheets.item(1)                                              # first sheet in destination workbook
        $sheetToCopy = $wbSCCM.sheets.item('SCCM_Report_Edit1')                          # source sheet to copy
        $sheetToCopy.name = 'SCCM_Report'                                                # rename sheet to copy
        $sheetToCopy.copy($sh1_wbSCCM)                                                   # copy source sheet to destination workbook
#########################################################
    Write-Host "`tMaking table..." -NoNewline 
    # Select area and make it a table
        $excel.ActiveSheet.ListObjects.add(1,$excel.ActiveSheet.UsedRange,0,1) | out-null
        $TableName = $($excel.ActiveSheet.ListObjects).DisplayName
        $excel.ActiveSheet.ListObjects("$TableName").TableStyle = "TableStyleMedium6"
    # How do I select an entire row?
        $range = $sh1_wbSCCM.Cells.Item(1,1).EntireRow
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
#5 SNOW WORKSTATION REPORT VARIABLES
##################################################################################################################
    Write-Host "Modify sheet from $SNOWXLS..." -ForegroundColor Yellow
        $sh1_wbSNOW = $wbNew.sheets.item(1)                                              # first sheet in destination workbook
        $sheetToCopy = $wbSNOW.sheets.item('SNOW_IWR_Edit')                             # source sheet to copy
        $sheetToCopy.name = 'SNOW_Workstation_Report'                                    # rename sheet to copy
        $sheetToCopy.copy($sh1_wbSNOW)                                                   # copy source sheet to destination workbook
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
#5.5 SNOW NOT DISCOVERED VARIABLES
##################################################################################################################
    Write-Host "Modify sheet from $CNDXLS..." -ForegroundColor Yellow
        $sh1_wbCND = $wbNew.sheets.item(1)                                               # first sheet in destination workbook
        $sheetToCopy = $wbCND.sheets.item('SNOW_CND_Edit')                              # source sheet to copy
        $sheetToCopy.name = 'SNOW_CND'                                                   # rename sheet to copy
        $sheetToCopy.copy($sh1_wbCND)                                                    # copy source sheet to destination workbook
#########################################################
    Write-Host "`tMaking table..." -NoNewline 
    # Select area and make it a table
        $excel.ActiveSheet.ListObjects.add(1,$excel.ActiveSheet.UsedRange,0,1) | out-null
        $TableName = $($excel.ActiveSheet.ListObjects).DisplayName
        $excel.ActiveSheet.ListObjects("$TableName").TableStyle = "TableStyleMedium7"
    # How do I select an entire row?
        $range = $sh1_wbCND.Cells.Item(1,1).EntireRow
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
#6 SEMPERIS COMPUTER DISABLES
##################################################################################################################
    Write-Host "Modify sheet from $SempDXLS..." -ForegroundColor Yellow
        $sh1_wbSempDisable = $wbNew.sheets.item(1)                                              # first sheet in destination workbook
        $sheetToCopy = $wbSempDisable.sheets.item('Semperis_Computer_Disables4')                  # source sheet to copy
        $sheetToCopy.name = 'Semperis_Disables'                                           # rename sheet to copy
        $sheetToCopy.copy($sh1_wbSempDisable)                                                   # copy source sheet to destination workbook
#########################################################
    Write-Host "`tMaking table..." -NoNewline 
    # Select area and make it a table
        $excel.ActiveSheet.ListObjects.add(1,$excel.ActiveSheet.UsedRange,0,1) | out-null
        $TableName = $($excel.ActiveSheet.ListObjects).DisplayName
        $excel.ActiveSheet.ListObjects("$TableName").TableStyle = "TableStyleMedium4"
    # How do I select an entire row?
        $range = $sh1_wbSempDisable.Cells.Item(1,1).EntireRow
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
#7 SEMPERIS COMPUTER ENABLES
##################################################################################################################
    Write-Host "Modify sheet from $SempEXLS..." -ForegroundColor Yellow
        $sh1_wbSempEnable = $wbNew.sheets.item(1)                                              # first sheet in destination workbook
        $sheetToCopy = $wbSempEnable.sheets.item('Semperis_Computer_Enables4')                  # source sheet to copy
        $sheetToCopy.name = 'Semperis_Enables'                                            # rename sheet to copy
        $sheetToCopy.copy($sh1_wbSempEnable)                                                   # copy source sheet to destination workbook
#########################################################
    Write-Host "`tMaking table..." -NoNewline 
    # Select area and make it a table
        $excel.ActiveSheet.ListObjects.add(1,$excel.ActiveSheet.UsedRange,0,1) | out-null
        $TableName = $($excel.ActiveSheet.ListObjects).DisplayName
        $excel.ActiveSheet.ListObjects("$TableName").TableStyle = "TableStyleMedium4"
    # How do I select an entire row?
        $range = $sh1_wbSempEnable.Cells.Item(1,1).EntireRow
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
#8 SEMPERIS COMPUTER STALE 
##################################################################################################################
    Write-Host "Modify sheet from $SempSXLS..." -ForegroundColor Yellow
        $sh1_wbSempStale = $wbNew.sheets.item(1)                                              # first sheet in destination workbook
        $sheetToCopy = $wbSempStale.sheets.item('Semperis_Computer_Stale4')                     # source sheet to copy
        $sheetToCopy.name = 'Semperis_Stale'                                              # rename sheet to copy
        $sheetToCopy.copy($sh1_wbSempStale)                                                   # copy source sheet to destination workbook
#########################################################
    Write-Host "`tMaking table..." -NoNewline 
    # Select area and make it a table
        $excel.ActiveSheet.ListObjects.add(1,$excel.ActiveSheet.UsedRange,0,1) | out-null
        $TableName = $($excel.ActiveSheet.ListObjects).DisplayName
        $excel.ActiveSheet.ListObjects("$TableName").TableStyle = "TableStyleMedium4"
    # How do I select an entire row?
        $range = $sh1_wbSempStale.Cells.Item(1,1).EntireRow
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
        $sh1_wbChrome = $wbNew.sheets.item(1)                                           # first sheet in destination workbook
        $sheetToCopy = $wbChrome.sheets.item('SCCM_CHROME_Report')                      # source sheet to copy
        $sheetToCopy.copy($sh1_wbChrome)                                              # copy source sheet to destination workbook
#########################################################
    Write-Host "`tMaking table..." -NoNewline 
    # Select area and make it a table
        $excel.ActiveSheet.ListObjects.add(1,$excel.ActiveSheet.UsedRange,0,1) | out-null
        $TableName = $($excel.ActiveSheet.ListObjects).DisplayName
        $excel.ActiveSheet.ListObjects("$TableName").TableStyle = "TableStyleMedium3"
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
#4 EDGE VARIABLES
##################################################################################################################
    Write-Host "Modify sheet from $SCCMEdgeXLS..." -ForegroundColor Yellow
        $sh1_wbEdge = $wbNew.sheets.item(1)                                             # first sheet in destination workbook
        $sheetToCopy = $wbEdge.sheets.item('SCCM_EDGE_Report')                          # source sheet to copy
        $sheetToCopy.copy($sh1_wbEdge)                                                  # copy source sheet to destination workbook
#########################################################
    Write-Host "`tMaking table..." -NoNewline 
    # Select area and make it a table
        $excel.ActiveSheet.ListObjects.add(1,$excel.ActiveSheet.UsedRange,0,1) | out-null
        $TableName = $($excel.ActiveSheet.ListObjects).DisplayName
        $excel.ActiveSheet.ListObjects("$TableName").TableStyle = "TableStyleMedium6"
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
#5 JAVA VARIABLES
##################################################################################################################
    Write-Host "Modify sheet from $SCCMJavaXLS..." -ForegroundColor Yellow
        $sh1_wbJava = $wbNew.sheets.item(1)                                              # first sheet in destination workbook
        $sheetToCopy = $wbjava.sheets.item('SCCM_JAVA_Report')                           # source sheet to copy
        $sheetToCopy.copy($sh1_wbJava)                                                   # copy source sheet to destination workbook
#########################################################
    Write-Host "`tMaking table..." -NoNewline 
    # Select area and make it a table
        $excel.ActiveSheet.ListObjects.add(1,$excel.ActiveSheet.UsedRange,0,1) | out-null
        $TableName = $($excel.ActiveSheet.ListObjects).DisplayName
        $excel.ActiveSheet.ListObjects("$TableName").TableStyle = "TableStyleMedium7"
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
#2 AD COMPUTER VARIABLES - MUST BE PROCESSED LAST. THIS IS THE MASTER SHEET
##################################################################################################################
    Write-Host "Modify sheet from $AD_PCXLS..." -ForegroundColor Yellow
        $sh1_wbPC = $wbNew.sheets.item(1)                                                # first sheet in destination workbook
        $sheetToCopy = $wbPC.sheets.item('AD_Workstations')                              # source sheet to copy
        #$sheetToCopy.name = 'AD_Workstations'                                           # rename sheet to copy
        $sheetToCopy.copy($sh1_wbPC)                                                     # copy source sheet to destination workbook
#########################################################
    Write-Host "`tMaking table..." -NoNewline 
    # Select area and make it a table
        $excel.ActiveSheet.ListObjects.add(1,$excel.ActiveSheet.UsedRange,0,1) | out-null
        $TableName = $($excel.ActiveSheet.ListObjects).DisplayName
        $excel.ActiveSheet.ListObjects("$TableName").TableStyle = "TableStyleMedium5"
    # How do I select an entire row?
        $range = $sh1_wbPC.Cells.Item(1,1).EntireRow
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
           	  $wbUser.close($false)                                                     # close source workbook w/o saving
                $wbPC.close($false)                                                     # close source workbook w/o saving
           $wbPCStale.close($false)                                                     # close source workbook w/o saving
              $wbSCCM.close($false)                                                     # close source workbook w/o saving
              $wbSNOW.close($false)                                                     # close source workbook w/o saving  
               $wbCND.close($false)                                                     # close source workbook w/o saving                  
       $wbSempDisable.close($false)                                                     # close source workbook w/o saving  
        $wbSempEnable.close($false)                                                     # close source workbook w/o saving 
         $wbSempStale.close($false)                                                     # close source workbook w/o saving 
             $wbAdobe.close($false)                                                     # close source workbook w/o saving                  
            $wbChrome.close($false)                                                     # close source workbook w/o saving  
              $wbEdge.close($false)                                                     # close source workbook w/o saving 
              $wbJava.close($false)                                                     # close source workbook w/o saving 
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
$i++
        $ws1.cells.Item(1,$i).Value() = 'SCCM - Adobe Version'
        $ws1.Cells.Item(1,$i).Interior.ColorIndex = 13
        $ws1.Cells.Item(1,$i).Font.ColorIndex = 2
        $ws1.cells.Item(2,$i).Value() =  '=INDEX(SCCM_ADOBE_Report!$E$2:$E$13001,MATCH(B2,SCCM_ADOBE_Report!$A$2:$A$13001,FALSE),1)'
$i++
        $ws1.cells.Item(1,$i).Value() = 'SCCM - Chrome Version'
        $ws1.Cells.Item(1,$i).Interior.ColorIndex = 13
        $ws1.Cells.Item(1,$i).Font.ColorIndex = 2
        $ws1.cells.Item(2,$i).Value() =  '=INDEX(SCCM_CHROME_Report!$E$2:$E$13001,MATCH(B2,SCCM_CHROME_Report!$A$2:$A$13001,FALSE),1)'
$i++ 
        $ws1.cells.Item(1,$i).Value() = 'SCCM - Edge Version'
        $ws1.Cells.Item(1,$i).Interior.ColorIndex = 13
        $ws1.Cells.Item(1,$i).Font.ColorIndex = 2
        $ws1.cells.Item(2,$i).Value() =  '=INDEX(SCCM_EDGE_Report!$E$2:$E$13001,MATCH(B2,SCCM_EDGE_Report!$A$2:$A$13001,FALSE),1)'
 $i++  
        $ws1.cells.Item(1,$i).Value() = 'SCCM - Java Version'
        $ws1.Cells.Item(1,$i).Interior.ColorIndex = 13
        $ws1.Cells.Item(1,$i).Font.ColorIndex = 2
        $ws1.cells.Item(2,$i).Value() =  '=INDEX(SCCM_JAVA_Report!$E$2:$E$13001,MATCH(B2,SCCM_Java_Report!$A$2:$A$13001,FALSE),1)'                      
    Write-Host "done." -ForegroundColor Green        
<#################################################################################
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
#################################################################################>
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
ADUsers
ADPC
ADStale
SCCM
SNOW
Semperis
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
