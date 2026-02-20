cls
#endregion Step3_and_Step4_Collection_and_Deployment_Creation
}
cls
#region StartScript
C:
 ##############################
 # Add Required Type Libraries
     [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ManagementProvider.dll")) | Out-Null
     [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.dll")) | Out-Null
     [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.Extender.dll")) | Out-Null
     [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.MsiInstaller.dll")) | Out-Null
##############################
# CD 'C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin'
##############################
CD 'C:\Program Files (x86)\ConfigMgr Console\bin'
##############################
Import-Module ".\ConfigurationManager.psd1"
Start-Sleep -Milliseconds 500
Set-Location XX1:
CD XX1:

cls
Write-Host "Welcome to my `"" -NoNewline 
Write-Host "All-Encompassing IMECI Creation and Deployment Script" -ForegroundColor Cyan -NoNewline
Write-Host "`".`n"  
Write-Host "This bad boy will take your input and create everything it needs to deploy the IMECI installs."
Write-Host "`n`tIncluding the collections, applications, and a deployment for each.."
Write-Host "`t`tStep 1) Create the Package source content and copy it to the SCCM share"
Write-Host "`t`tStep 2) Create an Package for systems"
Write-Host "`t`tStep 3) Create Collections for the deployments"
Write-Host "`t`tStep 4) Create deployment to that Collection of the approriate Pacakge"
Write-Host "`n"
Write-Host "Take a bit and digest that..."
# Start-Sleep -Seconds 10
Write-Host "If you didn't understand those details...then stop this script, and do NOT run it." -ForegroundColor Red
Write-Host "`n"
Read-Host -Prompt  "Ok, ready to break some stuff? Press any key to continue or CTRL+C to quit"
# Start-Sleep -Seconds 2
Read-Host -Prompt  "Seriously...if you don't have this thing set up correctly you are gonna have a bad day...press any key to continue or CTRL+C to quit"
Start-Sleep -Seconds 2
Write-Host "Ok, so the expected input is a set of variables in this order, seperated by a ';'."
Write-Host "(App Name) ; (Source Folder Name) ; (File Version) ; (File Name) ; LimitingColl"
Write-Host "`n"
Write-Host 
Read-Host -Prompt "Is your `$FileInfo variable populated correctly?...if so, press any key to continue or CTRL+C to quit"
Write-Host "There should already be a set of folders with the PSAppDeployToolkit files and the EXE in a folder on " -NoNewline
Write-Host "\\DOMAIN.COM\GROUP1\SERVER1\MCM\Packages\Dell_IME_Updates " -ForegroundColor Cyan
# Write-Host "The EXE should be named with underscores and end with the file version seperated by preceding `"_`" and the numbers seperated by `".`""
# Write-Host "For example: Latitude_7400_2-in-1_1.28.0.exe"
# Read-Host -Prompt "`nAre you EXE files named correctly?...if so, press any key to continue or CTRL+C to quit"
Start-Sleep -Seconds 2
Write-Host "Ok....here we go..." -ForegroundColor Green
####################################################################################################################################################
#endregion StartScript

#region Variables
####################################################################################################################################################
# STATIC VARIABLES
          $Global:ADateTime = Get-Date -UFormat "%Y/%m/%d %R"
          $Global:DDateTime = Get-Date -UFormat "%Y/%m/%d 20:00:00"
              $Global:Owner = "Endpoint Engineers"
            $Global:AppDesc = "Install created from PowerShell"
            $Global:DAction = "Install"
            $Global:DPGroup = "All DP's"
          $Global:DTRunTime = '20'
          $Global:Publisher = 'Dell'
        $Global:ReleaseDate = $(Get-Date)
       $Global:DTMaxRunTime = '30'
      $Global:DeployPurpose = 'Required'

####################################################################################################################################################
# VARIABLE VARIABLES
####################################################################################################################################################
###    
###
###  $FileInfo = (App Name) ; (Source Folder Name) ; (File Version) ; (File Name) ; LimitingColl
###         'BIOS__Latitude_5500	|	BIOS_Latitude_5500	|	1.30.0	|	Latitude_5X00_Precision_3540_1.30.0.exe	|	Dell BIOS Latitude 5500'
###
###  

# 
# $FileInfo = 'IMECI_Latitude_5500;IMECI_Latitude_5500;A13;Intel-Management-Engine-Components-Installer_7FHFF_WIN64_2345.5.42.0_A13.EXE;Dell Latitude 5500',
#             'IMECI_Latitude_5510;IMECI_Latitude_5510;A13;Intel-Management-Engine-Components-Installer_7FHFF_WIN64_2345.5.42.0_A13.EXE;Dell Latitude 5510',
#             'IMECI_Latitude_5520;IMECI_Latitude_5520;A12;Intel-Management-Engine-Components-Installer_3XG3X_WIN64_2345.5.42.0_A12_01.EXE;Dell Latitude 5520',
#             'IMECI_Latitude_5530;IMECI_Latitude_5530;A09;Intel-Management-Engine-Components-Installer_1MHW9_WIN64_2407.5.59.0_A09.EXE;Dell Latitude 5530',
#             'IMECI_Latitude_5540;IMECI_Latitude_5540;A10;Intel-Management-Engine-Components-Installer_67P2D_WIN64_2413.5.67.0_A10.EXE;Dell Latitude 5540',
#             'IMECI_Latitude_5550;Latitude_5550_IMECI;A03;Intel-Management-Engine-Components-Installer_CN5WD_WIN64_2409.5.63.0_A03.EXE;Dell Latitude 5550',
#             'IMECI_Latitude_5580;IMECI_Latitude_5580;A18;Intel-Management-Engine-Components-Installer_J4CFD_WIN_2345.5.42.0_A18_01.EXE;Dell Latitude 5580',
#             'IMECI_Latitude_7390;IMECI_Latitude_7390;A18;Intel-Management-Engine-Components-Installer_J4CFD_WIN_2345.5.42.0_A18_01.EXE;Dell Latitude 7390',
#             'IMECI_Latitude_7400;IMECI_Latitude_7400;A13;Intel-Management-Engine-Components-Installer_7FHFF_WIN64_2345.5.42.0_A13.EXE;Dell Latitude 7400',
#             'IMECI_Latitude_7400_2-in-1;IMECI_Latitude_7400_2-in-1;A13;Intel-Management-Engine-Components-Installer_7FHFF_WIN64_2345.5.42.0_A13.EXE;Dell Latitude 7400 2-in-1',
#             'IMECI_Latitude_7410;IMECI_Latitude_7410;A13;Intel-Management-Engine-Components-Installer_7FHFF_WIN64_2345.5.42.0_A13.EXE;Dell Latitude 7410',
#             'IMECI_Latitude_7420;IMECI_Latitude_7420;A12;Intel-Management-Engine-Components-Installer_3XG3X_WIN64_2345.5.42.0_A12_01.EXE;Dell Latitude 7420',
#             'IMECI_Latitude_7430;IMECI_Latitude_7430;A09;Intel-Management-Engine-Components-Installer_1MHW9_WIN64_2407.5.59.0_A09.EXE;Dell Latitude 7430',
#             'IMECI_Latitude_7440;IMECI_Latitude_7440;A09;Intel-Management-Engine-Components-Installer_1MHW9_WIN64_2407.5.59.0_A09.EXE;Dell Latitude 7440',
#             'IMECI_Latitude_7450;IMECI_Latitude_7450;A11;Intel-Management-Engine-Components-Installer_WR6M5_WIN64_2413.5.68.0_A11.EXE;Dell Latitude 7450',
#            #'IMECI_Optiplex_7000;IMECI_Optiplex_7000;A11;Intel-Management-Engine-Components-Installer_WR6M5_WIN64_2413.5.68.0_A11.EXE;Dell Optiplex 7000',
#             'IMECI_Optiplex_7010;IMECI_Optiplex_7010;A11;Intel-Management-Engine-Components-Installer_WR6M5_WIN64_2413.5.68.0_A11.EXE;Dell Optiplex 7010',
#             'IMECI_Optiplex_7020;IMECI_Optiplex_7020;A11;Intel-Management-Engine-Components-Installer_WR6M5_WIN64_2413.5.68.0_A11.EXE;Dell Optiplex 7020',
#             'IMECI_Optiplex_7040;IMECI_Optiplex_7040;A10;Intel-Management-Engine-Components-Installer_RV5TK_WIN_2205.15.0.2623_A10_01.EXE;Dell Optiplex 7040',
#             'IMECI_Optiplex_7050;IMECI_Optiplex_7050;A17;Intel-Management-Engine-Components-Installer_C98FP_WIN_2325.5.9.0_A17_02.EXE;Dell Optiplex 7050',
#             'IMECI_Optiplex_7070;IMECI_Optiplex_7070;A13;Intel-Management-Engine-Components-Installer_7FHFF_WIN64_2345.5.42.0_A13.EXE;Dell Optiplex 7070',
#             'IMECI_Optiplex_7080;IMECI_Optiplex_7080;A13;Intel-Management-Engine-Components-Installer_7FHFF_WIN64_2345.5.42.0_A13.EXE;Dell Optiplex 7080',
#             'IMECI_Optiplex_7090;IMECI_Optiplex_7090;A13;Intel-Management-Engine-Components-Installer_R6WCW_WIN64_2413.5.68.0_A13.EXE;Dell Optiplex 7090',
#             'IMECI_Precision_7740;IMECI_Precision_7740;A13;Intel-Management-Engine-Components-Installer_7FHFF_WIN64_2345.5.42.0_A13.EXE;Dell Precision 7740'

$FileInfo = 'IMECI_Latitude_5500;IMECI_Latitude_5500;A13;Intel-Management-Engine-Components-Installer_7FHFF_WIN64_2345.5.42.0_A13.EXE;Dell Latitude 5500',
            'IMECI_Latitude_5510;IMECI_Latitude_5510;A13;Intel-Management-Engine-Components-Installer_7FHFF_WIN64_2345.5.42.0_A13.EXE;Dell Latitude 5510',
            'IMECI_Latitude_5520;IMECI_Latitude_5520;A12;Intel-Management-Engine-Components-Installer_3XG3X_WIN64_2345.5.42.0_A12_01.EXE;Dell Latitude 5520',
            'IMECI_Latitude_5530;IMECI_Latitude_5530;A09;Intel-Management-Engine-Components-Installer_1MHW9_WIN64_2407.5.59.0_A09.EXE;Dell Latitude 5530',
            'IMECI_Latitude_5540;IMECI_Latitude_5540;A10;Intel-Management-Engine-Components-Installer_67P2D_WIN64_2413.5.67.0_A10.EXE;Dell Latitude 5540',
            'IMECI_Latitude_5550;Latitude_5550_IMECI;A03;Intel-Management-Engine-Components-Installer_CN5WD_WIN64_2409.5.63.0_A03.EXE;Dell Latitude 5550',
            'IMECI_Latitude_5580;IMECI_Latitude_5580;A18;Intel-Management-Engine-Components-Installer_J4CFD_WIN_2345.5.42.0_A18_01.EXE;Dell Latitude 5580',
            'IMECI_Latitude_7390;IMECI_Latitude_7390;A18;Intel-Management-Engine-Components-Installer_J4CFD_WIN_2345.5.42.0_A18_01.EXE;Dell Latitude 7390',
            'IMECI_Latitude_7400;IMECI_Latitude_7400;A13;Intel-Management-Engine-Components-Installer_7FHFF_WIN64_2345.5.42.0_A13.EXE;Dell Latitude 7400',
            'IMECI_Latitude_7400_2-in-1;IMECI_Latitude_7400_2-in-1;A13;Intel-Management-Engine-Components-Installer_7FHFF_WIN64_2345.5.42.0_A13.EXE;Dell Latitude 7400 2-in-1',
            'IMECI_Latitude_7410;IMECI_Latitude_7410;A13;Intel-Management-Engine-Components-Installer_7FHFF_WIN64_2345.5.42.0_A13.EXE;Dell Latitude 7410',
            'IMECI_Latitude_7420;IMECI_Latitude_7420;A12;Intel-Management-Engine-Components-Installer_3XG3X_WIN64_2345.5.42.0_A12_01.EXE;Dell Latitude 7420',
            'IMECI_Latitude_7430;IMECI_Latitude_7430;A09;Intel-Management-Engine-Components-Installer_1MHW9_WIN64_2407.5.59.0_A09.EXE;Dell Latitude 7430',
            'IMECI_Latitude_7440;IMECI_Latitude_7440;A09;Intel-Management-Engine-Components-Installer_1MHW9_WIN64_2407.5.59.0_A09.EXE;Dell Latitude 7440',
            'IMECI_Latitude_7450;IMECI_Latitude_7450;A11;Intel-Management-Engine-Components-Installer_WR6M5_WIN64_2413.5.68.0_A11.EXE;Dell Latitude 7450'

#endregion Variables



####################################################################################################################################################
# STEP 1 -- CREATE DEPLOYMENT FILES AND COPY THEM TO DEPLOYMENT SHARE 
####################################################################################################################################################

#region Step2_PackageCreation
####################################################################################################################################################
# STEP 2.0 -- CREATING PACKAGE -- FOR THE DEPLOYMENT FOR SYSTEMS WITH NO ONE LOGGED ON 
####################################################################################################################################################

ForEach ($File in $FileInfo)
{   
           $PKGName = $File.split(';')[0]
      $SourceFolder = $File.split(';')[1]
       $FileVersion = $File.split(';')[2]
          $FileName = $File.split(';')[3]
      $LimitingColl = $File.split(';')[4]

    $SourceLocation = "\\DOMAIN.COM\GROUP1\SERVER1\MCM\Packages\Dell_IME_Updates\$SourceFolder"
     $InstallSyntax = "powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -WindowStyle Hidden -File .\IMECIInstall.ps1"
$DeploymentTypeName = 'Install'
           $Descrip = 'IMECI install for vPro'

New-PSDrive -Name 'IMECISource' -PSProvider "FileSystem" -Root $SourceLocation

           $Script = "IMECIInstall.ps1"

      '     PKGName: ' + $PKGName
      'SourceFolder: ' + $SourceFolder 
      ' FileVersion: ' + $FileVersion 
      '    FileName: ' + $FileName 
      'LimitingColl: ' + $LimitingColl 

##################################################
# CREATE SCRIPTFILE
$ScriptContent = 'Function IMECICheck
{
   [string] $(Get-Date) + "`t--`tIntel(R) ME version check" | Add-Content "C:\Windows\Logs\Software\BIOS_update.txt"
# Variables defining minimum supported firmware version for Intel(R) EMA - AMT FW version 11.8 and 
# ISM FW version 16.0 -- as of Intel EMA 1.9.0

[int]$script:FWMajorAMT = "11"
[int]$script:FWMinorAMT = "8"
[int]$script:FWMajorISM = "16"
[int]$script:FWMinorISM = "0"

# Read SMBIOS data via WMI ########################################################################

$global:discoveryData = $null
$smbiosBytes = (Get-WmiObject -Namespace root\WMI -Class MS_SmBios).SMBiosData
$smbiosHex = ([System.BitConverter]::ToString($smbiosBytes))

# Find $AMT signature as anchor to to locate Intel(R) ME attributes ###############################

If ($smbiosHex.Contains("24-41-4D-54")) {    
    [int]$signatureLoc = ($smbiosHex.IndexOf("24-41-4D-54"))    
    [int]$tableLength = ([convert]::ToInt16($smbiosHex.Substring($signatureLoc - 9).Substring(0,2), 16))

    # Calculate offsets to locate Intel(R) ME attributes in SMBIOS data ###########################
    
    # Note that offsets are different with 12th gen CPUs
    If ($tableLength -eq "20") {
        [int]$offset = 173
    } Else {
        [int]$baseOff = (($tableLength - 20) * 3)
        [int]$offset = 173 + $baseOff
    }

    # Identify Intel(R) ME version ################################################################

    $version = $smbiosHex.Substring($signatureLoc - 12,$offset).Substring($offset - 23,23)

    # ME FW version in hex is in min, maj, rev, hf order, but should be written as maj.min.hf.rev
    $minVer = [convert]::ToInt16($version.Substring(3,2) + $version.Substring(0,2), 16)
    $majVer = [convert]::ToInt16($version.Substring(9,2) + $version.Substring(6,2), 16)
    $revVer = [convert]::ToInt16($version.Substring(15,2) + $version.Substring(12,2), 16)
    $hfVer = [convert]::ToInt16($version.Substring(21,2) + $version.Substring(18,2), 16)    

    If (($skuStr -eq "Intel(R) Full AMT Manageability") -and (($majVer -ge $FWMajorAMT -And $minVer -ge $FWMinorAMT) -Or ($majVer -ge ($FWMajorAMT + 1)))) {
        $MESupported = $true
    } ElseIf (($skuStr -eq "Intel(R) Standard Manageability") -and (($majVer -ge $FWMajorISM -And $minVer -ge $FWMinorISM) -Or ($majVer -ge ($FWMajorISM + 1)))) {
        $MESupported = $true
    } Else {
        $MESupported = $false
    }

    # Report SMBIOS results #######################################################################
    "`tIntel(R) ME version".PadRight(40,".") + "$majVer.$minVer.$hfVer.$revVer" | Add-Content "C:\Windows\Logs\Software\BIOS_update.txt"


} Else { # $AMT signature not found in SMBIOS data

    # Report results when $AMT signature not found ################################################

    "`tIntel(R) vPro platform".PadRight(40,".") + ": $false" | Add-Content "C:\Windows\Logs\Software\BIOS_update.txt"
    $global:discoveryData = ConvertTo-Json -InputObject @{vpro_platform = $false}            
    Return

}}

If(!(Test-Path "C:\Windows\Logs\Software")){New-Item -ItemType Directory -Path "C:\Windows\Logs\Software"}

IMECICheck

#################################################################
# EXE INSTALLER with ARGUEMENTS
Start-Process -FilePath ".\' + $FileName + '" -ArgumentList "/s" -Wait -WindowStyle Hidden

IMECICheck
'
cd IMECISource:
New-Item $Script -ItemType File -Force
$ScriptContent | Set-Content ".\$Script"
Remove-PSDrive -Name 'IMECISource' -Force

cd XX1:
##################################################
##################################################
# CREATE PACKAGE
    New-CMPackage -Name $PKGname `
                  -Path $SourceLocation
    $PKGID = $(Get-CMPackage -Name $PKGName).packageID
    Write-Host ""
    Write-Host "Created SCCM Package named: " -NoNewline
    Write-Host "$PKGname " -ForegroundColor Green
    Start-Sleep -Seconds 5
##################################################
# CREATE PROGRAM
    New-CMProgram -CommandLine $InstallSyntax `
                  -PackageName $PKGName `
                  -StandardProgramName Install `
                  -RunType Hidden `
                  -RunMode RunWithAdministrativeRights `
                  -ProgramRunType WhetherOrNotUserIsLoggedOn
##################################################
# SET PACKAGE
    Set-CMPackage -Name $PKGName `
                  -EnableBinaryDeltaReplication $True `
                  -MulticastAllow $True `
                  -PrestageBehavior OnDemand
##################################################
# MOVE PACKAGE
    Move-CMObject -FolderPath "XX1:\Package\BIOS and Drivers\Dell IME Updates" -ObjectId $PKGID
##################################################
# PACKAGE Content Distribution
    Start-CMContentDistribution -PackageName $PKGname -DistributionPointGroupName $DPGroup
    Write-Host "Created Package Content Distribution for: " -NoNewline
    Write-Host "$PKGname " -ForegroundColor Green -NoNewline
    Write-Host "to Distribution Point: " -NoNewline
    Write-Host "$DPGroup" -ForegroundColor Red
}
#endregion Step2_PackageCreation

#region Step3_and_Step4_Collection_and_Deployment_Creation
####################################################################################################################################################
# STEP 3.0 and 4.0 -- CREATING COLLECTION AND DEPLOYMENT
####################################################################################################################################################

# Collections Update Schedules
$Schedule1 = New-CMSchedule -DurationInterval Days -DurationCount 0 -RecurInterval Days -RecurCount 1

ForEach ($File in $FileInfo)
{   
           $PKGName = $File.split(';')[0]
      $SourceFolder = $File.split(';')[1]
       $FileVersion = $File.split(';')[2]
          $FileName = $File.split(';')[3]
      $LimitingColl = $File.split(';')[4]  
          $CollName = 'IMECI - ' + $LimitingColl
              $Comm = "Deployment from POWERSHELL to $CollName of $PKGName"

    Write-Host ""
    Write-Host "Creating new SCCM Device Collection named: " -NoNewline
    Write-Host "$CollName " -ForegroundColor Green
    Write-Host ""
    New-CMDeviceCollection -Name "$CollName" -LimitingCollectionName "$LimitingColl" -RefreshSchedule $Schedule1 -RefreshType Periodic
    Start-Sleep -Seconds 3
    Move-CMObject -FolderPath "XX1:\DeviceCollection\Software Distribution\vPro Management\IMECI Installs" -InputObject (Get-CMDeviceCollection -Name $CollName)

####################################################################################################################################################
# STEP 4.0 -- CREATING DEPLOYMENT -- FOR SYSTEMS WITH NO ONE LOGGED ON 
####################################################################################################################################################
    Write-Host ""
    Write-Host "Creating new SCCM Package Deployment named: " -NoNewline
    Write-Host "$PKGName " -ForegroundColor Green
    Write-Host ""

    $Package = Get-CMPackage -Name $PKGName    
    
    New-CMPackageDeployment -PackageId $($Package).PackageID `
                            -ProgramName Install `
                            -StandardProgram `
                            -AllowFallback $True `
                            -AvailableDateTime $ADateTime `
                            -CollectionName "$CollName" `
                            -Comment $Comm `
                            -DeployPurpose $DeployPurpose `
                            -RerunBehavior NeverRerunDeployedProgram `
                            -ScheduleEvent AsSoonAsPossible `
                            -SlowNetworkOption DownloadContentFromDistributionPointAndLocally `
                            -SoftwareInstallation $True `
                            -SystemRestart $False `
                            -UseMeteredNetwork $True
}
#endregion Step3_and_Step4_Collection_and_Deployment_Creation
