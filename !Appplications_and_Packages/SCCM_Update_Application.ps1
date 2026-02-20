cls
}
    Write-Host "$Appname " -ForegroundColor Green
cls
# Static Variables
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
####################################################################################################################################################
####################################################################################################################################################
# VARIABLE VARIABLES

# $FileInfo = (Foldername) ; (File Version) ; (Folder Name)

$FileInfo = 'BIOS__Latitude_5520;1.37.0;BIOS_Latitude_5520',  `
            'BIOS__Latitude_5530;1.22.0;BIOS_Latitude_5530',  `
            'BIOS__Latitude_5540;1.13.0;BIOS_Latitude_5540',  `
            'BIOS__Latitude_5550;1.4.0;BIOS_Latitude_5550',  `
            'BIOS__Latitude_7390;1.38.0;BIOS_Latitude_7390',  `
            'BIOS__Optiplex_7010;1.14.0;BIOS_Optiplex_7010',  `
            'BIOS__Optiplex_7020;1.4.1;BIOS_Optiplex_7020',  `
            'BIOS__Optiplex_7070;1.27.0;BIOS_Optiplex_7070',  `
            'BIOS__Optiplex_7080;1.26.0;BIOS_Optiplex_7080',  `
            'BIOS__Optiplex_7090;1.25.0;BIOS_Optiplex_7090',  `
            'BIOS__Latitude_5510;1.28.0;BIOS__Latitude_5510', `
            'BIOS__Latitude_7400_2-in-1;1.1.28.0;BIOS__Latitude_7400_2-in-1', `
            'BIOS__Latitude_7420;1.35.0;BIOS__Latitude_7420', `
            'BIOS__Latitude_7430;1.23.0;BIOS__Latitude_7430', `
            'BIOS__Latitude_7440;1.14.1;BIOS__Latitude_7440', `
            'BIOS__Latitude_7450;1.4.0;BIOS__Latitude_7450'

<#         
'Dell BIOS Latitude_5500_1.25.0;Pilot - Dell BIOS Latitude 5500 1.25.0', 
'Dell BIOS Latitude_5510_1.23.1;Pilot - Dell BIOS Latitude 5510 1.23.0', 
'Dell BIOS Latitude_5520 - 1.32.1;Pilot - Dell BIOS Latitude 5520 1.32.1', 
'Dell BIOS Latitude_5530_1.18.0;Pilot - Dell BIOS Latitude 5530 1.18.0', 
'Dell BIOS Latitude_5540_1.9.0;Pilot - Dell BIOS Latitude 5540 1.9.0', 
'Dell BIOS Latitude_5580_1.32.2;Pilot - Dell BIOS Latitude 5580 1.32.2', 
'Dell BIOS Latitude_7420 1.30.1;Pilot - Dell BIOS Latitude 7420 1.30.0', 
'Dell BIOS Latitude_7430_1.18.0;Pilot - Dell BIOS Latitude 7430 1.18.0', 
'Dell BIOS Optiplex_7000_1.18.1;Pilot - Dell BIOS Optiplex 7000 1.18.1', 
'Dell BIOS Optiplex_7040 _1.24.0;Pilot - Dell BIOS Optiplex 7040 1.24.0', 
'Dell BIOS Optiplex_7050_1.24.0;Pilot - Dell BIOS Optiplex 7050 1.24.0', 
'Dell BIOS Optiplex_7070 - 1.22.0;Pilot - Dell BIOS Optiplex 7070 1.22.0', 
'Dell BIOS Optiplex_7090 1.19.0;Pilot - Dell BIOS Optiplex 7090 1.19.0', 
'Dell BIOS Precision 7740_1.29.0;Pilot - Dell BIOS Precision 7740 1.27.0'
#>

####################################################################################################################################################
####################################################################################################################################################
ForEach ($File in $FileInfo)
{   
           $AppName = $File.split(';')[0]
   $SoftwareVersion = $File.split(';')[1]
      $SourceFolder = $File.split(';')[2]
#          $FileName = $File.split(';')[3]
   

    $SourceLocation = "\\DOMAIN.COM\GROUP1\SERVER1\MCM\Packages\Dell_BIOS_Updates\$SourceFolder"
     $InstallSyntax = "Deploy-Application.exe"

###################################################
## APPLICATION
#Set-CMApplication `
#        -Name $Appname `
#        -DistributionPointSetting AutoDownload `
#        -SendToProtectedDistributionPoint $True
#    Write-Host ""
#    Write-Host "Modified SCCM Application named: " -NoNewline
#    Write-Host "$Appname " -ForegroundColor Green
###################################################
# DELETE EXISTING DEPLOYMENT TYPE
Remove-CMDeploymentType -ApplicationName $Appname -DeploymentTypeName $DeploymentTypeName -Force
    Write-Host "Removed `"$DeploymentTypeName`" deployment type for: " -NoNewline
    Write-Host "$Appname " -ForegroundColor Green
Start-Sleep -Milliseconds 500
###################################################
# DETECTION METHOD BASED ON REGKEY
$DMClause = New-CMDetectionClauseRegistryKeyValue -Hive LocalMachine `
                                                  -KeyName 'HARDWARE\DESCRIPTION\System\BIOS' `
                                                  -PropertyType Version `
                                                  -ValueName 'BIOSVersion' `
                                                  -Value `
                                                  -ExpectedValue "$SoftwareVersion" `
                                                  -ExpressionOperator GreaterEquals
Start-Sleep -Milliseconds 500
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
<##################################################
# APPLICATION Content Distribution
    Start-CMContentDistribution -ApplicationName $Appname -DistributionPointGroupName "$DPGroup"
    Write-Host ""
    Write-Host "Created Application Content Distribution for: " -NoNewline
    Write-Host "$Appname " -ForegroundColor Green -NoNewline
    Write-Host "to Distribution Point: " -NoNewline
    Write-Host "$DPGroup" -ForegroundColor Red
##################################################>
# APPLICATION Content Distribution
    Update-CMDistributionPoint -ApplicationName $AppName `
                               -DeploymentTypeName $DeploymentTypeName
    Write-Host "Updated Application Content Distribution for: " -NoNewline
    Write-Host "$Appname " -ForegroundColor Green
}
