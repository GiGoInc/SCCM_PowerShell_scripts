cls
#endregion Step4.5_DeploymentCreation
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
Write-Host "All-Encompassing BIOS Creation and Deployment Script" -ForegroundColor Cyan -NoNewline
Write-Host "`".`n"  
Write-Host "This bad boy will take your input and create everything it needs to deploy the BIOS installs."
Write-Host "`n`tIncluding the collections, applications, and two deployments for each.."
Write-Host "`t`tStep 1) Create the two application source content and copy it to the SCCM share"
Write-Host "`t`tStep 2) Create an Application for systems with no logged on user and another for if someone if logged on or off"
Write-Host "`t`tStep 3) Create Collections for the deployments"
Write-Host "`t`tStep 4) Create deployment to that Collection of the approriate application"
Write-Host "`n"
Write-Host "Take a bit and digest that..."
Start-Sleep -Seconds 10
Write-Host "If you didn't understand those details...then stop this script, and do NOT run it." -ForegroundColor Red
Write-Host "`n"
Read-Host -Prompt  "Ok, ready to break some stuff? Press any key to continue or CTRL+C to quit"
Start-Sleep -Seconds 2
Read-Host -Prompt  "Seriously...if you don't have this thing set up correctly you are gonna have a bad day...press any key to continue or CTRL+C to quit"
Start-Sleep -Seconds 2
Write-Host "Ok, so the expected input is a set of variables in this order, seperated by a ';'."
Write-Host "(App Name) ; (Source Folder Name) ; (File Name) ; (File Version)"
Write-Host "`n"
Write-Host 
Read-Host -Prompt "Is your `$FileInfo variable populated correctly?...if so, press any key to continue or CTRL+C to quit"
Write-Host "There should already be a set of folders with the PSAppDeployToolkit files and the BIOS EXE in a folder on " -NoNewline
Write-Host "\\DOMAIN.COM\GROUP1\SERVER1\MCM\Packages\Dell_BIOS_Updates " -ForegroundColor Cyan
Write-Host "The BIOS EXE should be named with underscores and end with the file version seperated by preceding `"_`" and the numbers seperated by `".`""
Write-Host "For example: Latitude_7400_2-in-1_1.28.0.exe"
Read-Host -Prompt "`nAre you BIOS exes named correctly?...if so, press any key to continue or CTRL+C to quit"
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
<#
$FileInfo = 'BIOS_Latitude_5500;BIOS_Latitude_5500;1.30.0;Latitude_5X00_Precision_3540_1.30.0.exe;BIOS - Dell Latitude 5500', 
            'BIOS_Latitude_5510;BIOS_Latitude_5510;1.28.0;Latitude_5X10_Precision_3550_1.28.0.exe;BIOS - Dell Latitude 5510', 
            'BIOS_Latitude_5520;BIOS_Latitude_5520;1.37.0;Precision_3560_Latitude_5520_1.37.0.exe;BIOS - Dell Latitude 5520', 
            'BIOS_Latitude_5530;BIOS_Latitude_5530;1.22.0;Precision_3570_Latitude_5530_1.22.0.exe;BIOS - Dell Latitude 5530', 
            'BIOS_Latitude_5540;BIOS_Latitude_5540;1.13.0;Precision_3580_Latitude_5540_1.13.0.exe;BIOS - Dell Latitude 5540', 
            'BIOS_Latitude_5550;BIOS_Latitude_5550;1.4.0;Precision_3590_3591_Latitude_5550_1.4.0.exe;BIOS - Dell Latitude 5550', 
            'BIOS_Latitude_7390;BIOS_Latitude_7390;1.38.0;Latitude_7X90_1.38.0.exe;BIOS - Dell Latitude 7390', 
            'BIOS_Latitude_7400_2-in-1;BIOS_Latitude_7400_2-in-1;1.1.28.0;Latitude_7400_2-in-1.1.28.0.exe;BIOS - Dell Latitude 7400 2-in-1', 
            'BIOS_Latitude_7420;BIOS_Latitude_7420;1.35.0;Latitude_7X20_1.35.0.exe;BIOS - Dell Latitude 7420', 
            'BIOS_Latitude_7430;BIOS_Latitude_7430;1.23.0;Latitude_7X30_1.23.0.exe;BIOS - Dell Latitude 7430', 
            'BIOS_Latitude_7440;BIOS_Latitude_7440;1.14.1;Latitude_7X40_1.14.1.exe;BIOS - Dell Latitude 7440', 
            'BIOS_Latitude_7450;BIOS_Latitude_7450;1.4.0;Latitude_7X50_1.4.0.exe;BIOS - Dell Latitude 7450', 
            'BIOS_Optiplex_7000;BIOS_Optiplex_7000;1.22.0;OptiPlex_7000_1.22.0.exe;BIOS - Dell Optiplex 7000', 
            'BIOS_Optiplex_7010;BIOS_Optiplex_7010;1.14.0;OptiPlex_7010_1.14.0.exe;BIOS - Dell Optiplex 7010 SFF', 
            'BIOS_Optiplex_7020;BIOS_Optiplex_7020;1.4.1;OptiPlex_7020_1.4.1.exe;BIOS - Dell Optiplex 7020 SFF', 
            'BIOS_Optiplex_7070;BIOS_Optiplex_7070;1.27.0;OptiPlex_7070_1.27.0.exe;BIOS - Dell Optiplex 7070', 
            'BIOS_Optiplex_7080;BIOS_Optiplex_7080;1.26.0;OptiPlex_7080_1.26.0.exe;BIOS - Dell Optiplex 7080', 
            'BIOS_Optiplex_7090;BIOS_Optiplex_7090;1.25.0;OptiPlex_7090_1.25.0.exe;BIOS - Dell Optiplex 7090', 
            'BIOS_Precision_7440;BIOS_Precision_7440;1.29.0;Precision_7440_1.29.0.exe;BIOS - Dell Precision 7440', 
            'BIOS_Precision_7740;BIOS_Precision_7740;1.29.0;Precision_7X40_1.29.0.exe;BIOS - Dell Precision 7740'
#>
$FileInfo = 'BIOS_Latitude_5510;BIOS_Latitude_5510;1.28.0;Latitude_5X10_Precision_3550_1.28.0.exe;BIOS - Dell Latitude 5510', 
            'BIOS_Latitude_5500;BIOS_Latitude_5500;1.30.0;Latitude_5X00_Precision_3540_1.30.0.exe;BIOS - Dell Latitude 5500',             
            'BIOS_Latitude_5540;BIOS_Latitude_5540;1.13.0;Precision_3580_Latitude_5540_1.13.0.exe;BIOS - Dell Latitude 5540', 
            'BIOS_Latitude_5550;BIOS_Latitude_5550;1.4.0;Precision_3590_3591_Latitude_5550_1.4.0.exe;BIOS - Dell Latitude 5550', 
            'BIOS_Latitude_7390;BIOS_Latitude_7390;1.38.0;Latitude_7X90_1.38.0.exe;BIOS - Dell Latitude 7390', 
            'BIOS_Latitude_7400_2-in-1;BIOS_Latitude_7400_2-in-1;1.1.28.0;Latitude_7400_2-in-1.1.28.0.exe;BIOS - Dell Latitude 7400 2-in-1', 
            'BIOS_Latitude_7420;BIOS_Latitude_7420;1.35.0;Latitude_7X20_1.35.0.exe;BIOS - Dell Latitude 7420', 
            'BIOS_Latitude_7430;BIOS_Latitude_7430;1.23.0;Latitude_7X30_1.23.0.exe;BIOS - Dell Latitude 7430', 
            'BIOS_Latitude_7440;BIOS_Latitude_7440;1.14.1;Latitude_7X40_1.14.1.exe;BIOS - Dell Latitude 7440', 
            'BIOS_Latitude_7450;BIOS_Latitude_7450;1.4.0;Latitude_7X50_1.4.0.exe;BIOS - Dell Latitude 7450', 
            'BIOS_Optiplex_7020;BIOS_Optiplex_7020;1.4.1;OptiPlex_7020_1.4.1.exe;BIOS - Dell Optiplex 7020 SFF', 
            'BIOS_Optiplex_7080;BIOS_Optiplex_7080;1.26.0;OptiPlex_7080_1.26.0.exe;BIOS - Dell Optiplex 7080', 
            'BIOS_Precision_7440;BIOS_Precision_7440;1.29.0;Precision_7440_1.29.0.exe;BIOS - Dell Precision 7440', 
            'BIOS_Precision_7740;BIOS_Precision_7740;1.29.0;Precision_7X40_1.29.0.exe;BIOS - Dell Precision 7740'

#endregion Variables

####################################################################################################################################################
# STEP 1 -- CREATE DEPLOYMENT FILES AND COPY THEM TO DEPLOYMENT SHARE 
####################################################################################################################################################

#region Step2_ApplicationCreation
####################################################################################################################################################
# STEP 2.0 -- CREATING APPLICATION -- FOR THE DEPLOYMENT FOR SYSTEMS WITH NO ONE LOGGED ON 
####################################################################################################################################################

ForEach ($File in $FileInfo)
{   
           $AppName = $File.split(';')[0]
           $AppName = $AppName + "_NotLoggedOn"
      $SourceFolder = $File.split(';')[1]
       $FileVersion = $File.split(';')[2]
          $FileName = $File.split(';')[3]
      $LimitingColl = $File.split(';')[4]

    $SourceLocation = "\\DOMAIN.COM\GROUP1\SERVER1\MCM\Packages\Dell_BIOS_Updates\$SourceFolder"
     $InstallSyntax = "powershell.exe -ExecutionPolicy Bypass -NoLogo -NonInteractive -NoProfile -WindowStyle Hidden -File .\Bitlocker_BiosInstall.ps1 -FileName $FileName"
$DeploymentTypeName = 'LoggedOff Install'

           $Descrip = 'BIOS upgrade that only runs when no user is logged on'

           $Script = "$SourceLocation\Bitlocker_BiosInstall.ps1"

##################################################
# CREATE SCRIPTFILE
$ScriptContent = '
param(
    [string]
    [parameter(mandatory=$true)]
    $filename
)

If(!(Test-Path "C:\Windows\Logs\Software")){New-Item -ItemType Directory -Path "C:\Windows\Logs\Software"}


$BIOS = $(gwmi Win32_BIOS).Version
$PCType = $(gwmi Win32_ComputerSystem).PCSystemType

If ((($PCType -eq "0") -or ($PCType -eq "2") -or ($PCType -eq "10") -or ($PCType -eq "31")) -and 
    ($BIOS -lt "' + $FileVersion + '"))
{
	Suspend-Bitlocker -MountPoint "C:" -RebootCount 1
	$CMDargs = "/s /f /r /l=`"C:\Windows\Logs\Software\BIOS_update.txt`""
	$Process = Start-Process $filename -ArgumentList $CMDargs -PassThru -wait
	Exit 3010
}
ElseIf ($BIOS -lt "' + $FileVersion + '")
{ 
	$CMDargs = "/s /f /r /l=`"C:\Windows\Logs\Software\BIOS_update.txt`""
	$Process = Start-Process $filename -ArgumentList $CMDargs -PassThru -wait
	Exit 3010
}
Else{ [string]$(Get-Date) + " -- BIOS UP-TO-DATE:`t`"$BIOS`"' + ' = `"' + $Fileversion + '`"" | Add-Content "C:\Windows\Logs\Software\BIOS_update.txt"}
'
$ScriptContent | Set-Content $Script
}
##################################################
# APPLICATION
New-CMApplication `
        -Name $Appname `
        -AutoInstall $True `
        -Description $AppDesc `
        -DisplaySupersedenceInApplicationCatalog $False `
        -ReleaseDate $ReleaseDate `
        -LocalizedDescription $Descrip

    Write-Host ""
    Write-Host "Created SCCM Application named: " -NoNewline
    Write-Host "$Appname " -ForegroundColor Green
    Start-Sleep -Seconds 5
##################################################
# APPLICATION
Set-CMApplication `
        -Name $Appname `
        -DistributionPointSetting AutoDownload `
        -SendToProtectedDistributionPoint $True
    Write-Host "Modified SCCM Application named: " -NoNewline
    Write-Host "$Appname " -ForegroundColor Green
##################################################
# MOVE APPLICATION
    $app = Get-CMApplication -Name $Appname
    Move-CMObject -FolderPath "XX1:\Application\Projects\BIOS\Dell BIOS Updates (no logons)" -InputObject $app
##################################################
# DETECTION METHOD BASED ON REGKEY
$DMClause = New-CMDetectionClauseRegistryKeyValue -Hive LocalMachine `
                                                  -KeyName 'HARDWARE\DESCRIPTION\System\BIOS' `
                                                  -PropertyType Version `
                                                  -ValueName 'BIOSVersion' `
                                                  -Value -ExpectedValue "$FileVersion" `
                                                  -ExpressionOperator GreaterEquals
##################################################
# OS REQUIREMENT FOR DEPLOYMENT RULE
    $myGC = Get-CMGlobalCondition -Name "Operating System" | Where-Object PlatformType -eq 1
    $platformA = Get-CMConfigurationPlatform -LocalizedDisplayName "All Windows 10 (64-bit)" -Fast
    $platformB = Get-CMConfigurationPlatform -LocalizedDisplayName "All Windows 11 Professional/Enterprise and higher (64-bit)" -Fast
    $platforms += $platformA
    $platforms += $platformB
    $OSRule = $myGC | New-CMRequirementRuleOperatingSystemValue -RuleOperator OneOf -Platform $platforms
    Write-Host "Set OS deployment rules for: " -NoNewline
    Write-Host "$Appname " -ForegroundColor Green
##################################################
# APPLICATION DeploymentType
Add-CMScriptDeploymentType -ContentLocation $SourceLocation `
                           -ContentFallback `
                           -DeploymentTypeName $DeploymentTypeName `
                           -InstallCommand $InstallSyntax `
                           -AddDetectionClause $DMClause `
                           -ApplicationName $AppName `
                           -InstallationBehaviorType InstallForSystem `
                           -LogonRequirementType 'OnlyWhenNoUserLoggedOn' `
                           -EstimatedRuntimeMins $DTRunTime `
                           -MaximumRuntimeMins $DTMaxRunTime `
                           -UserInteractionMode 'Hidden' `
                           -SlowNetworkDeploymentMode Download `
                           -AddRequirement $OSRule
    Write-Host "Created Application DeploymentType named: " -NoNewline
    Write-Host "$DeploymentTypeName " -ForegroundColor Green -NoNewline
    Write-Host "for Application named " -NoNewline
    Write-Host "$Appname " -ForegroundColor Red
##################################################
# APPLICATION Content Distribution
    Start-CMContentDistribution -ApplicationName $Appname -DistributionPointGroupName $DPGroup
    Write-Host "Created Application Content Distribution for: " -NoNewline
    Write-Host "$Appname " -ForegroundColor Green -NoNewline
    Write-Host "to Distribution Point: " -NoNewline
    Write-Host "$DPGroup" -ForegroundColor Red
}
#endregion Step2_ApplicationCreation

#region Step3_and_Step4_Collection_and_Deployment_Creation
####################################################################################################################################################
# STEP 3.0 and 4.0 -- CREATING COLLECTION AND DEPLOYMENT -- FOR SYSTEMS WITH NO ONE LOGGED ON
####################################################################################################################################################

# Collections Update Schedules
$Schedule1 = New-CMSchedule -DurationInterval Days -DurationCount 0 -RecurInterval Days -RecurCount 1

ForEach ($File in $FileInfo)
{   
           $AppName = $File.split(';')[0]
           $AppName = $AppName + "_NotLoggedOn"
      $SourceFolder = $File.split(';')[1]
       $FileVersion = $File.split(';')[2]
          $FileName = $File.split(';')[3]
      $LimitingColl = $File.split(';')[4]  
          $CollName = 'Logged Off - ' + $LimitingColl
              $Comm = "Deployment from POWERSHELL to $CollName of $AppName"

    Write-Host ""
    Write-Host "Creating new SCCM Device Collection named: " -NoNewline
    Write-Host "$CollName " -ForegroundColor Green
    Write-Host ""
    #New-CMDeviceCollection -Name "$CollName" -LimitingCollectionName "$LimitingColl" -RefreshSchedule $Schedule1 -RefreshType Periodic
    #Start-Sleep -Seconds 3
    #Move-CMObject -FolderPath "XX1:\DeviceCollection\Software Distribution\BIOS Updates for vPro\BIOS Deployments" -InputObject (Get-CMDeviceCollection -Name $CollName)

####################################################################################################################################################
# STEP 4.0 -- CREATING DELOYMENT -- FOR SYSTEMS WITH NO ONE LOGGED ON 
####################################################################################################################################################
    Write-Host ""
    Write-Host "Creating new SCCM Application Deployment named: " -NoNewline
    Write-Host "$AppName " -ForegroundColor Green
    Write-Host ""
    New-CMApplicationDeployment -Name $AppName `
                                -AvailableDateTime $ADateTime `
                                -CollectionName $CollName `
                                -Comment $Comm `
                                -DeadlineDateTime $ADateTime `
                                -DeployAction $DAction `
                                -DeployPurpose $DeployPurpose `
                                -EnableMomAlert $False `
                                -OverrideServiceWindow $True `
                                -PersistOnWriteFilterDevice $False `
                                -PreDeploy $True `
                                -RebootOutsideServiceWindow $True `
                                -SendWakeupPacket $True `
                                -TimeBaseOn LocalTime `
                                -UseMeteredNetwork $True `
                                -UserNotification DisplaySoftwareCenterOnly
}
#endregion Step3_and_Step4_Collection_and_Deployment_Creation

################################################################################################################################################################################
################################################################################################################################################################################

Read-Host -Prompt "`nReady to create Applications, Collections, and Deployments for users with deferrals?...if so, press any key to continue or CTRL+C to quit"

################################################################################################################################################################################
################################################################################################################################################################################

#region Step2.5_ApplicationCreation
####################################################################################################################################################
# STEP 2.5 -- CREATING APPLICATION -- FOR THE DEPLOYMENT FOR SYSTEMS WITH A LOGGED ON USER - HAS DEFERRAL OPTION
####################################################################################################################################################

ForEach ($File in $FileInfo)
{   
           $AppName = $File.split(';')[0]
      $SourceFolder = $File.split(';')[1]
       $FileVersion = $File.split(';')[2]
          $FileName = $File.split(';')[3]
      $LimitingColl = $File.split(';')[4]  

    $SourceLocation = "\\DOMAIN.COM\GROUP1\SERVER1\MCM\Packages\Dell_BIOS_Updates\$SourceFolder"
     $InstallSyntax = "Deploy-Application.exe"
$DeploymentTypeName = 'Install'

           $Descrip = 'BIOS upgrade that has a deferral prompt.'

##################################################
# APPLICATION
New-CMApplication `
        -Name $Appname `
        -AutoInstall $True `
        -Description $AppDesc `
        -DisplaySupersedenceInApplicationCatalog $False `
        -ReleaseDate $ReleaseDate `
        -LocalizedDescription $Descrip

    Write-Host ""
    Write-Host "Created SCCM Application named: " -NoNewline
    Write-Host "$Appname " -ForegroundColor Green
    Start-Sleep -Seconds 5
##################################################
# APPLICATION
Set-CMApplication `
        -Name $Appname `
        -DistributionPointSetting AutoDownload `
        -SendToProtectedDistributionPoint $True
    Write-Host "Modified SCCM Application named: " -NoNewline
    Write-Host "$Appname " -ForegroundColor Green
##################################################
# MOVE APPLICATION
    $app = Get-CMApplication -Name $Appname
    Move-CMObject -FolderPath "XX1:\Application\Projects\BIOS\Dell BIOS Updates" -InputObject $app
##################################################
# DETECTION METHOD BASED ON REGKEY
$DMClause = New-CMDetectionClauseRegistryKeyValue -Hive LocalMachine `
                                                  -KeyName 'HARDWARE\DESCRIPTION\System\BIOS' `
                                                  -PropertyType Version `
                                                  -ValueName 'BIOSVersion' `
                                                  -Value -ExpectedValue "$FileVersion" `
                                                  -ExpressionOperator GreaterEquals
##################################################
# OS REQUIREMENT FOR DEPLOYMENT RULE
    $myGC = Get-CMGlobalCondition -Name "Operating System" | Where-Object PlatformType -eq 1
    $platformA = Get-CMConfigurationPlatform -LocalizedDisplayName "All Windows 10 (64-bit)" -Fast
    $platformB = Get-CMConfigurationPlatform -LocalizedDisplayName "All Windows 11 Professional/Enterprise and higher (64-bit)" -Fast
    $platforms += $platformA
    $platforms += $platformB
    $OSRule = $myGC | New-CMRequirementRuleOperatingSystemValue -RuleOperator OneOf -Platform $platforms
    Write-Host "Set OS deployment rules for: " -NoNewline
    Write-Host "$Appname " -ForegroundColor Green
##################################################
# APPLICATION DeploymentType
Add-CMScriptDeploymentType -ContentLocation $SourceLocation `
                           -ContentFallback `
                           -DeploymentTypeName $DeploymentTypeName `
                           -InstallCommand $InstallSyntax `
                           -AddDetectionClause $DMClause `
                           -ApplicationName $AppName `
                           -InstallationBehaviorType InstallForSystem `
                           -RequireUserInteraction `
                           -LogonRequirementType 'WhetherOrNotUserLoggedOn' `
                           -EstimatedRuntimeMins $DTRunTime `
                           -MaximumRuntimeMins $DTMaxRunTime `
                           -UserInteractionMode 'Normal' `
                           -SlowNetworkDeploymentMode Download `
                           -AddRequirement $OSRule
    Write-Host "Created Application DeploymentType named: " -NoNewline
    Write-Host "$DeploymentTypeName " -ForegroundColor Green -NoNewline
    Write-Host "for Application named " -NoNewline
    Write-Host "$Appname " -ForegroundColor Red
##################################################
# APPLICATION Content Distribution
    Start-CMContentDistribution -ApplicationName $Appname -DistributionPointGroupName $DPGroup
    Write-Host "Created Application Content Distribution for: " -NoNewline
    Write-Host "$Appname " -ForegroundColor Green -NoNewline
    Write-Host "to Distribution Point: " -NoNewline
    Write-Host "$DPGroup" -ForegroundColor Red
}
#endregion Step2.5_ApplicationCreation

#region Step3.5_CollectionCreation
####################################################################################################################################################
# STEP 3.5 and 4.5 -- CREATING COLLECTION AND DEPLOYMENT -- FOR SYSTEMS WITH A LOGGED ON USER - HAS DEFERRAL OPTION
####################################################################################################################################################

# Collections Update Schedules
$Schedule1 = New-CMSchedule -DurationInterval Days -DurationCount 0 -RecurInterval Days -RecurCount 1

ForEach ($File in $FileInfo)
{   
           $AppName = $File.split(';')[0]
      $SourceFolder = $File.split(';')[1]
       $FileVersion = $File.split(';')[2]
          $FileName = $File.split(';')[3]
      $LimitingColl = $File.split(';')[4]  
          $CollName = $SourceFolder.replace('_',' ')
              $Comm = "Deployment from POWERSHELL to $CollName of $AppName"

    New-CMDeviceCollection -Name "$CollName" -LimitingCollectionName "$LimitingColl" -RefreshSchedule $Schedule1 -RefreshType Periodic
    Start-Sleep -Seconds 3
    Move-CMObject -FolderPath "XX1:\DeviceCollection\Software Distribution\BIOS Updates for vPro\BIOS Deployments" -InputObject (Get-CMDeviceCollection -Name $CollName)
#endregion Step3.5_CollectionCreation

#region Step4.5_DeploymentCreation
####################################################################################################################################################
# STEP 4.5 -- CREATING DELOYMENT -- FOR SYSTEMS WITH A LOGGED ON USER - HAS DEFERRAL OPTION
####################################################################################################################################################

    New-CMApplicationDeployment -Name $AppName `
                                -AvailableDateTime $ADateTime `
                                -CollectionName $CollName `
                                -Comment $Comm `
                                -DeadlineDateTime $DDateTime `
                                -DeployAction $DAction `
                                -DeployPurpose $DeployPurpose `
                                -EnableMomAlert $False `
                                -OverrideServiceWindow $True `
                                -PersistOnWriteFilterDevice $False `
                                -PreDeploy $True `
                                -RebootOutsideServiceWindow $True `
                                -SendWakeupPacket $True `
                                -TimeBaseOn LocalTime `
                                -UseMeteredNetwork $True `
                                -UserNotification DisplaySoftwareCenterOnly
}
#endregion Step4.5_DeploymentCreation
