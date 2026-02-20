<#
}
    Write-Host "$DPGroup" -ForegroundColor Red
<#
    cls
    $Files = Get-ChildItem -Path Z:\Packages\Dell_BIOS_Updates -Filter *.exe -Recurse
    $Files | % { $($_.DirectoryName).split('\')[3] + "`t" + $_.Name }

Get-CMApplication -Name "Dell BIOS Latitude_5510_1.23.1"

$DeploymentHash = @{
					CollectionName = $CollName
					Name = $AppName
					AvaliableDate = $ADate
					AvaliableTime = $ATime
					Comment = $Comm
					DeployAction = $DAction
					EnableMomAlert = $False
					FailParameterValue = 40
					OverrideServiceWindow = $True
					PersistOnWriteFilterDevice = $False
					PreDeploy = $True
					RaiseMomAlertsOnFailure = $False
					RebootOutsideServiceWindow = $True
					SendWakeUpPacket = $True
					TimeBaseOn = "LocalTime"
					UseMeteredNetwork = $True
					UserNotification = "DisplaySoftwareCenterOnly"
                    }
Write-Output Comment - $Comm
Start-CMApplicationDeployment @DeploymentHash

#>
##########################################################################
# Static Variables
cls
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

               $Comm = "Deployment from POWERSHELL of $AppName to $CollName"
              $ADate = Get-Date -UFormat "%Y/%m/%d"
              $ATime = Get-Date -UFormat "%R"
              $Owner = "Endpoint Engineers"
            $AppDesc = "Install created from PowerShell"
            $DAction = "Install"
            $DPGroup = "All DP's"
          $DTRunTime = '20'
          $Publisher = 'Dell'
        $ReleaseDate = $(Get-Date)
       $DTMaxRunTime = '30'
 $DeploymentTypeName = 'Install'
##########################################################################
# VARIABLE VARIABLES

# $FileInfo = (Foldername) ; (File Version) ; (Folder Name) ; (File Name)

$FileInfo = 'BIOS__Latitude_5510;1.28.0;BIOS_Latitude_5510;Latitude_5x10_Precision_3550_1.28.0.exe', 
            'BIOS__Latitude_7400_2-In-1;1.1.28.0;BIOS_Latitude_7400_2-In-1;Latitude_7400_2-In-1_1.28.0.exe', 
            'BIOS__Latitude_7430;1.23.0;BIOS_Latitude_7430;Latitude_7x30_1.23.0.exe', 
            'BIOS__Latitude_7440;1.14.1;BIOS_Latitude_7440;Latitude_7x40_1.14.1.exe', 
            'BIOS__Latitude_7450;1.4.0;BIOS_Latitude_7450;Latitude_7x50_1.4.0.exe'



ForEach ($File in $FileInfo)
{   
           $AppName = $File.split(';')[0]
   $SoftwareVersion = $File.split(';')[1]
      $SourceFolder = $File.split(';')[2]
          $FileName = $File.split(';')[3]
   

    $SourceLocation = "\\DOMAIN.COM\GROUP1\SERVER1\MCM\Packages\Dell_BIOS_Updates\$SourceFolder"
     $InstallSyntax = "Deploy-Application.exe"

####################################################################################################
# APPLICATION
New-CMApplication `
        -Name $Appname `
        -AutoInstall $True `
        -Description $AppDesc `
        -DisplaySupersedenceInApplicationCatalog $False `
        -ReleaseDate $ReleaseDate
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
                                                  -Value -ExpectedValue "$SoftwareVersion" `
                                                  -ExpressionOperator GreaterEquals
##################################################
# OS REQUIREMENT FOR DEPLOYMENT RULE
    $myGC = Get-CMGlobalCondition -Name "Operating System" | Where-Object PlatformType -eq 1
    $platformA = Get-CMConfigurationPlatform -LocalizedDisplayName "All Windows 10 (64-bit)" -Fast
    $platformB = Get-CMConfigurationPlatform -LocalizedDisplayName "All Windows 11 Professional/Enterprise and higher (64-bit)" -Fast
    $platforms += $platformA
    $platforms += $platformB
    $myRule = $myGC | New-CMRequirementRuleOperatingSystemValue -RuleOperator OneOf -Platform $platforms
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
                           -LogonRequirementType 'WhereOrNotUserLoggedOn' `
                           -EstimatedRuntimeMins $DTRunTime `
                           -MaximumRuntimeMins $DTMaxRunTime `
                           -UserInteractionMode 'Normal' `
                           -SlowNetworkDeploymentMode Download `
                           -AddRequirement $myRule
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
