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

    If (Test-Path "H:\Powershell\AD_SCCM_SNOW_Compiler"){}
    Else { net use H: \\DOMAIN\isilon\home\aUSER1 /peristent }

    #4 SCCM VARIABLES
         $Global:SCCMFile = "C:\Temp\SCCM_Report_original.csv"
        $Global:SCCM_Mod1 = "C:\Temp\SCCM_Report_Edit1.csv"
        $Global:SCCM_Mod2 = "C:\Temp\SCCM_Report_Edit2.csv"
         $Global:SCCMEdit = "C:\Temp\SCCM_Report.csv"
          $Global:SCCMXLS = "C:\Temp\SCCM_Report.xlsx"

        # FINAL FILES VARIABLES
           $Global:DestFile = "C:\Temp\SCCM_TheWorks_$ADate.xlsx"
          $Global:FinalFile = "H:\Powershell\!SCCM_PS_scripts\SCCM_TheWorks_$ADate.xlsx"

    cd 'H:\Powershell\!SCCM_PS_scripts'
    H:
}

#region 0_ROLL_OUT
Function GoGoStartingScript {
    Write-Host 'Checking variables and copying initial files...' -ForegroundColor Cyan

########################################################################################################################################
# Remove temp files before starting 
########################################################################################################################################
    #4 SCCM VARIABLES                 
    If (Test-Path $SCCMFile)          { Remove-Item -Path $SCCMFile -Force | Out-Null }
    If (Test-Path $SCCM_Mod1)         { Remove-Item -Path $SCCM_Mod1 -Force | Out-Null }
    If (Test-Path $SCCM_Mod2)         { Remove-Item -Path $SCCM_Mod2 -Force | Out-Null }
    If (Test-Path $SCCMEdit)          { Remove-Item -Path $SCCMEdit -Force | Out-Null }
    If (Test-Path $SCCMXLS)           { Remove-Item -Path $SCCMXLS -Force | Out-Null }
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
#endregion 0_ROLL_OUT

#region 4_SCCM
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
    WHEN CS.Model0 In ( '4865A17','4865A18' ) THEN 'Desktop - Lenovo ThinkCentre M78'
    WHEN CS.Model0 In ( '5041A3U','5054A3U' ) THEN 'Desktop - Lenovo ThinkCentre M75e'	
    WHEN CS.Model0 In ( 'HP Z420 Workstation' ) THEN 'Desktop - HP Z240 Workstation'
    WHEN CS.Model0 In ( 'LATITUDE 5540' ) THEN 'Laptop - Dell Inc. Latitude 5540'
    WHEN CS.Model0 In ( 'LATITUDE 5550' ) THEN 'Laptop - Dell Inc. Latitude 5550'
    WHEN CS.Model0 In ( 'LATITUDE 7440' ) THEN 'Laptop - Dell Inc. Latitude 7440'
    WHEN CS.Model0 In ( 'LATITUDE 7450' ) THEN 'Laptop - Dell Inc. Latitude 7450'	
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
    WHEN CS.Model0 In ( 'OPTIPLEX SFF PLUS 7010' ) THEN 'Desktop - Dell Inc. OptiPlex 7010 SFF'
    WHEN CS.Model0 In ( 'OPTIPLEX SFF PLUS 7020' ) THEN 'Desktop - Dell Inc. OptiPlex 7020 SFF'
    WHEN CS.Model0 In ( 'OptiPlex 7000' ) THEN 'Desktop - Dell Inc. OptiPlex 7000'
    WHEN CS.Model0 In ( 'OptiPlex 7040' ) THEN 'Desktop - Dell Inc. OptiPlex 7040'
    WHEN CS.Model0 In ( 'OptiPlex 7050' ) THEN 'Desktop - Dell Inc. OptiPlex 7050'
    WHEN CS.Model0 In ( 'OptiPlex 7060' ) THEN 'Desktop - Dell Inc. OptiPlex 7060'
    WHEN CS.Model0 In ( 'OptiPlex 7070' ) THEN 'Desktop - Dell Inc. OptiPlex 7070'
    WHEN CS.Model0 In ( 'OptiPlex 7080' ) THEN 'Desktop - Dell Inc. OptiPlex 7080'
    WHEN CS.Model0 In ( 'OptiPlex 7090' ) THEN 'Desktop - Dell Inc. OptiPlex 7090'
    WHEN CS.Model0 In ( 'OptiPlex 7450 AIO' ) THEN 'Desktop - Dell Inc. OptiPlex 7450 AIO'
    WHEN CS.Model0 In ( 'OptiPlex 9020' ) THEN 'Desktop - Dell Inc. OptiPlex 9020'
    WHEN CS.Model0 In ( 'OptiPlex 90202004CK0002/' ) THEN 'Desktop - Dell Inc. OptiPlex 9020'
    WHEN CS.Model0 In ( 'PRECISION 3660' ) THEN 'Laptop - Dell Inc. Precision 3660'
    WHEN CS.Model0 In ( 'PRECISION 5540' ) THEN 'Laptop - Dell Inc. Precision 5540'
    WHEN CS.Model0 In ( 'PRECISION 7770' ) THEN 'Laptop - Dell Inc. Precision 7770'
    WHEN CS.Model0 In ( 'PowerEdge 2950' ) THEN 'Server - PowerEdge 2950' 
    WHEN CS.Model0 In ( 'Precision 3551' ) THEN 'Laptop - Dell Inc. Precision 3551'
    WHEN CS.Model0 In ( 'Precision 3630 Tower' ) THEN 'Desktop - Dell Inc. Precision 3630 Tower'
    WHEN CS.Model0 In ( 'Precision 7740' ) THEN 'Laptop - Dell Inc. Precision 7740'
    WHEN CS.Model0 In ( 'ProLiant BL685c G6' ) THEN 'Server - ProLiant BL685c G6'
    WHEN CS.Model0 In ( 'ProLiant DL360 Gen10' ) THEN 'Server - ProLiant DL360 Gen10'
    WHEN CS.Model0 In ( 'S3420GP' ) THEN 'Server - S3420GP'
    WHEN CS.Model0 In ( 'Server - S3240GP' ) THEN 'Server - Xeon CPU' 	
    WHEN CS.Model0 In ( 'To be filled by O.E.M.' ) THEN 'Desktop - NewLine'
    WHEN CS.Model0 In ( 'VMWare Virtual Machine' ) THEN 'VMWare VM'
    WHEN CS.Model0 In ( 'VMware Virtual Platform' ) THEN 'VMWare VM'
    WHEN CS.Model0 In ( 'VMware7,1' ) THEN 'VMWare VM'
    WHEN CS.Model0 In ( 'X9SAE' ) THEN 'Desktop - Air Conditioning'	
    WHEN CS.Model0 In ( 'XPS 13 9365' ) THEN 'Laptop - Dell Inc. Latitude XPS 13 (9365)'
    WHEN CS.Model0 In ( 'XPS 15 9575' ) THEN 'Laptop - Dell Inc. Latitude XPS 15 (9575)'	
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

/*  2024-08-23
	LATITUDE 5500			1.30.0
	LATITUDE 5510			1.28.0
	LATITUDE 5520			1.37.0
	LATITUDE 5530			1.22.0
	LATITUDE 5540			1.13.0
	LATITUDE 5550			1.4.0
	LATITUDE 7390			1.38.0
	LATITUDE 7400 2-IN-1	1.28.0
	LATITUDE 7420			1.35.0
	LATITUDE 7430			1.23.0
	LATITUDE 7440			1.14.1
	LATITUDE 7450			1.4.0
	OPTIPLEX 7000			1.22.0
	OPTIPLEX 7010			1.15.0
	OPTIPLEX 7020			1.4.1
	OPTIPLEX 7070			1.27.0
	OPTIPLEX 7080			1.26.0
	OPTIPLEX 7090			1.25.0
	PRECISION 7440			1.29.0
	PRECISION 7740			1.29.0
*/
/* ############################################################################################################################## */
/* ############################################################################################################################## */
 CASE WHEN CS.Model0 In ( 'Latitude 5500' )          THEN '1.30.0'
	WHEN CS.Model0 In ( 'Latitude 5510' )            THEN '1.28.0'	   
	WHEN CS.Model0 In ( 'Latitude 5520' )            THEN '1.37.0'
	WHEN CS.Model0 In ( 'Latitude 5530' )            THEN '1.22.0'
	WHEN CS.Model0 In ( 'Latitude 5540' )            THEN '1.13.0'		   
	WHEN CS.Model0 In ( 'Latitude 5550' )            THEN '1.4.0'	 
	WHEN CS.Model0 In ( 'Latitude 7390' )            THEN '1.38.0'
	WHEN CS.Model0 In ( 'Latitude 7400 2-in-1' )     THEN '1.28.0'
	WHEN CS.Model0 In ( 'Latitude 7420' )            THEN '1.35.0'
	WHEN CS.Model0 In ( 'Latitude 7430' )            THEN '1.23.0'	
	WHEN CS.Model0 In ( 'Latitude 7440' )            THEN '1.14.1'	
	WHEN CS.Model0 In ( 'Latitude 7450' )            THEN '1.4.0'	
	WHEN CS.Model0 In ( 'OptiPlex 7000' )            THEN '1.22.0'
	WHEN CS.Model0 In ( 'OPTIPLEX SFF PLUS 7010' )   THEN '1.15.0'
	WHEN CS.Model0 In ( 'OPTIPLEX SFF PLUS 7020' )   THEN '1.4.1'	
	WHEN CS.Model0 In ( 'OptiPlex 7070' )            THEN '1.27.0'
	WHEN CS.Model0 In ( 'OptiPlex 7080' )            THEN '1.26.0'
	WHEN CS.Model0 In ( 'OptiPlex 7090' )            THEN '1.25.0'	
 	WHEN CS.Model0 In ( 'Precision 7440' )           THEN '1.29.0'	
 	WHEN CS.Model0 In ( 'Precision 7740' )           THEN '1.29.0' 
/* ############################################################# */	
	WHEN CS.Model0 In ( '20QD000LUS' )               THEN '1.56'
	WHEN CS.Model0 In ( '20RH000JUS' )               THEN '1.78'
	WHEN CS.Model0 In ( '20RH000PUS' )               THEN '1.78'
	WHEN CS.Model0 In ( '344834U' )                  THEN 'Unknown'
	WHEN CS.Model0 In ( 'Latitude 5290 2-in-1' )     THEN '1.25.0'
	WHEN CS.Model0 In ( 'Latitude 5480' )            THEN '1.29.0'	
	WHEN CS.Model0 In ( 'Latitude 5580' )            THEN '1.32.2'
	WHEN CS.Model0 In ( 'Latitude 5590' )            THEN '1.27.1'	
	WHEN CS.Model0 In ( 'Latitude 7400' )            THEN '1.28.0'
	WHEN CS.Model0 In ( 'Latitude 7410' )            THEN '1.25.1'
	WHEN CS.Model0 In ( 'Latitude 7480' )            THEN '1.30.0'
	WHEN CS.Model0 In ( 'Latitude 9510' )            THEN '1.17.1'
	WHEN CS.Model0 In ( 'Latitude E5540' )           THEN 'A24'	 
	WHEN CS.Model0 In ( 'Latitude E554063533007A/' ) THEN 'A24'
	WHEN CS.Model0 In ( 'Latitude E5550' )           THEN 'A24'
	WHEN CS.Model0 In ( 'Latitude E5570' )           THEN '1.34.3'
	WHEN CS.Model0 In ( 'Latitude E7440' )           THEN 'A28'
	WHEN CS.Model0 In ( 'Latitude E7470' )           THEN '1.36.3'
	WHEN CS.Model0 In ( 'OptiPlex 7040' )            THEN '1.24.0'
	WHEN CS.Model0 In ( 'OptiPlex 7050' )            THEN '1.24.0'
	WHEN CS.Model0 In ( 'OptiPlex 7060' )            THEN '1.24.0'
	WHEN CS.Model0 In ( 'OptiPlex 7450 AIO' )        THEN 'Unknown'
	WHEN CS.Model0 In ( 'OptiPlex 9020' )            THEN 'A25'
	WHEN CS.Model0 In ( 'OptiPlex 90202004CK0002/' ) THEN 'A25'
	WHEN CS.Model0 In ( 'Precision 3551' )           THEN '1.18.0'
	WHEN CS.Model0 In ( 'Precision 3630 Tower' )     THEN '2.19.0'
	WHEN CS.Model0 In ( 'VMWare Virtual Machine' )   THEN 'VMWWare VM'
	WHEN CS.Model0 In ( 'VMware Virtual Platform' )  THEN 'Unknown'
	WHEN CS.Model0 In ( 'VMware7,1' )                THEN 'Unknown'
	WHEN CS.Model0 In ( 'XPS 13 9365' )              THEN '2.24.0'
	WHEN CS.Model0 In ( 'XPS 15 9575' )              THEN '1.25.0'
	WHEN CS.Model0 In ( 'HP Z420 Workstation' )      THEN 'Unknown'
	WHEN CS.Model0 In ( 'To be filled by O.E.M.' )   THEN 'Unknown'
	WHEN CS.Model0 In ( 'ProLiant BL685c G6' )       THEN 'Unknown'
	WHEN CS.Model0 In ( 'ProLiant DL360 Gen10' )     THEN 'Unknown'
	WHEN CS.Model0 In ( 'S3420GP' )                  THEN 'Unknown'
	WHEN CS.Model0 In ( 'PowerEdge 2950' )           THEN 'Unknown'
	ELSE 'BIOS CHECK N/A'
END AS 'Latest BIOS (2024/08/23)',
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
 ORDER BY 'Model Name' desc"
##########################################################################
      $SQL_DB = 'CM_XX1'
  $SQL_Server = 'SERVER.DOMAIN.COM'
$SQL_Instance = 'SERVER'
##########################################################################
   $SQL_Check = Invoke-Sqlcmd -ConnectionTimeout 60 `
        -Database $SQL_DB  `
        -HostName $SQL_Server  `
        -Query $SQL_Query `
        -QueryTimeout 600 `
        -ServerInstance $SQL_Instance `
        -Encrypt Optional `
        -TrustServerCertificate


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
    [string]$LatestBIOS = $Check."Latest BIOS (2024/08/23)"

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

    If (($B1 -ge $LB1) -AND ($B2 -ge $LB2) -AND ($B3 -ge $LB3)) { $BIOSStatus = 'Up-to-date' } Else { $BIOSStatus = 'Outdated' }    #######################
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
#endregion 4_SCCM

#region ExcelFun
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
            CreateAllTextXSLX -CSVIn $SCCM_Mod1 -ExcelOut $SCCMXLS | Out-Null
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
    $wbSCCM = $excel.Workbooks.Open($SCCMXLS)	
Write-Host "done." -ForegroundColor Green

##################################################################################################################
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
              $wbSCCM.close($false)                                                     # close source workbook w/o saving
    Write-Host "done." -ForegroundColor Green  

# Cleanup data now that everything is in Excel
    Write-Host "`tDelete extra sheet(s)..." -NoNewLine
        $wsSheet1 = $wbNew.worksheets | where {$_.name -eq "Sheet1"} #<------- Selects sheet 1
        $wsSheet1.delete()  # Activate sheet 1
    Write-Host "done." -ForegroundColor Green    
    Start-Sleep -Seconds 1

# Modify wbNew AD_Workstations sheet
    Write-Host "`tActivate main worksheet..." -NoNewLine
        $ws1 = $wbNew.worksheets | where {$_.name -eq "SCCM_Report"} #<------- Selects AD_Workstations
        $ws1.activate()  # Activate sheet 1
    Write-Host "done." -ForegroundColor Green    
#########################################################
    Write-Host "done." -ForegroundColor Green        
    Write-Host "Close and save files..." -ForegroundColor Green
        $wbNew.SaveAs($DestFile)                                 # Save destination workbook
        $wbNew.close($true)                                      # close destination workbook
        $excel.quit()
        spps -n excel
    
    # Write-Host "Copying files to current directory"
        Copy-Item -Path $DestFile -Destination $FinalFile -Force
    $ErrorActionPreference = 'Continue'

}
#endregion ExcelFun
########################################################################################################################################
# RUN FUNCTIONS
########################################################################################################################################

Variables
GoGoStartingScript
SCCM
ExcelFun


$EDate = (GET-DATE)
$Span = NEW-TIMESPAN –Start $SDate –End $EDate
$Min = $Span.minutes
$Sec = $Span.Seconds
Write-Host "`n$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
Start-Sleep -Seconds 10
