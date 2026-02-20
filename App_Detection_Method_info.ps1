<#######################################
#>
#################################################################################################
<#######################################
# SQL QUERY
;WITH XMLNAMESPACES ( DEFAULT 'http://schemas.microsoft.com/SystemCenterConfigurationManager/2009/AppMgmtDigest') 
SELECT app.Manufacturer
      ,app.DisplayName
      ,app.SoftwareVersion
      ,dt.DisplayName AS DeploymentTypeName
      ,dt.PriorityInLatestApp
      ,dt.Technology
      ,dt.SDMPackageDigest.value('(/AppMgmtDigest/DeploymentType/Installer/CustomData/EnhancedDetectionMethod/Settings)[1]','nvarchar(1000)')[ProductCode]
FROM dbo.fn_ListDeploymentTypeCIs(1033) AS dt 
INNER JOIN dbo.fn_ListLatestApplicationCIs(1033) AS app ON dt.AppModelName = app.ModelName
WHERE (dt.IsLatest = 1)
order by Technology
#######################################>

GoGo_SCCM_Module.ps1
cls
[int]$AppNum = '1'
$(get-date -format yyyy-MM-dd)+' -- '+ $(get-date -UFormat %R).Replace(':','.')
$ADateS = Get-Date
$ADateStart = $(Get-Date -format yyyy-MM-dd)+'__'+ $(Get-Date -UFormat %R).Replace(':','.')
$OutputLog = "D:\Powershell\!SCCM_PS_scripts\Get_Application_DeploymentType_DetectionMethods--$ADateStart.csv"
'DM Type,Application Name,PackageID,DT Title,Location / Value,DM Name,DM Value' | Add-Content $OutputLog
Write-Host "Scripts should take about 4 minutes...." -ForegroundColor Green
Start-Sleep -seconds 3
Get-CMApplication | % {
$AppName =  $($_.LocalizedDisplayName)
$PackageID =  $($_.PackageID)
Write-Host "Checking $AppNum - $AppName" -ForegroundColor Cyan
    $ErrorActionPreference = 'SilentlyContinue'
    Try
    {
        $output = @()
        # $App = Get-CMApplication -ApplicationName $AppName
        $CheckApplicationXML = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($_.SDMPackageXML, $True)
	    ForEach ($DM in $CheckApplicationXML.DeploymentTypes)
	    {
            # $DM = ([Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($AppXML)).DeploymentTypes
            # $EnhancedDetectionMethod = [xml] $AppXML.DeploymentTypes[0].installer.EnhancedDetectionMethod.xml
            $DTTitle = $DM.Title
            $DMTypes1 = $DM.Installer.EnhancedDetectionMethod.Settings.type
            $DMTypes2 = $DM.Installer.EnhancedDetectionMethod.Settings.SourceType
            ForEach ($DMType in $DMTypes1)
            {
                If ($DMType -eq 'MSI')
                {
                    $ProductCode = $($DM.Installer.EnhancedDetectionMethod.Settings).ProductCode
                     $OName = $DM.Installer.EnhancedDetectionMethod.Rule.Expression.Operator.OperatorName
                    $OValue = $DM.Installer.EnhancedDetectionMethod.Rule.Expression.Operands.value
                    $output += "$DMType,$AppName,$PackageID,$DTTitle,$ProductCode,$OName,$OValue`n"
                }
                If ($DMType -eq 'Folder')
                {
                    $Location = $($DM.Installer.EnhancedDetectionMethod.Settings).Location
                     $OName = $DM.Installer.EnhancedDetectionMethod.Rule.Expression.Operator.OperatorName
                    $OValue = $DM.Installer.EnhancedDetectionMethod.Rule.Expression.Operands.value
                    $output += "$DMType,$AppName,$PackageID,$DTTitle,$Location,$OName,$OValue`n"
                }
                If ($DMType -eq 'File')
                {
                    $Location = $($DM.Installer.EnhancedDetectionMethod.Settings).Location
                     $OName = $DM.Installer.EnhancedDetectionMethod.Rule.Expression.Operator.OperatorName
                    $OValue = $DM.Installer.EnhancedDetectionMethod.Rule.Expression.Operands.value
                    $output += "$DMType,$AppName,$PackageID,$DTTitle,$Location,$OName,$OValue`n"
                }
            }
            ForEach ($DMType2 in $DMTypes2)
            {
                If ($DMType2 -eq 'Registry')
                {
                    $Location = $($DM.Installer.EnhancedDetectionMethod.Settings).Location
                    $ValueName = $($DM.Installer.EnhancedDetectionMethod.Settings).ValueName
                     $OName = $DM.Installer.EnhancedDetectionMethod.Rule.Expression.Operator.OperatorName
                    $OValue = $DM.Installer.EnhancedDetectionMethod.Rule.Expression.Operands.value
                    $output += "$DMType2,$AppName,$PackageID,$DTTitle,$Location | $ValueName,$OName,$OValue`n"
                }
            }
        }
        $output | Add-Content $OutputLog
    }
    Catch
    {
        Write-Host "$AppName,check failed" -ForegroundColor Red
    }
# CheckYoApp -AppName $AppName -Log $OutputLog
$AppNum++
}
# REMOVE BLANK LINES
(gc $OutputLog) | ? {$_.trim() -ne "" } | Set-Content $OutputLog
# END DATE
$ADateE = Get-Date
$t = NEW-TIMESPAN –Start $ADateS –End $ADateE | select Minutes,Seconds
$min = $t.Minutes
$sec = $t.seconds
Write-Host "Script ran: $min minutes and $sec seconds."
<###############################################################################
# Get Application names and PackageIDs
Write-Host "Scripts should take about 4 minutes...." -ForegroundColor Green
Start-Sleep -seconds 3
$ADateS = Get-Date
$AppNames = Get-CMApplication | select LocalizedDisplayName,PackageID
#$($AppNames.LocalizedDisplayName) | Set-Content "D:\Powershell\!SCCM_PS_scripts\Get_Application_DeploymentType_DetectionMethods--ApplicationNames.csv"
# END DATE
$ADateE = Get-Date
$t = NEW-TIMESPAN –Start $ADateS –End $ADateE | select Minutes,Seconds
$min = $t.Minutes
$sec = $t.seconds
cls
Write-Host "`nApp Count:" $AppNames.Length
Write-Host "Script ran: $min minutes and $sec seconds.`n`n"
###############################################################################
###############################################################################
# Get Application Info
[int]$AppNum = '1'
$ADateStart = $(Get-Date -format yyyy-MM-dd)+'__'+ $(Get-Date -UFormat %R).Replace(':','.')
$OutputLog = "D:\Powershell\!SCCM_PS_scripts\Get_Application_DeploymentType_DetectionMethods--$ADateStart.csv"
'DM Type,Application Name,PackageID,DT Title,Location / Value,DM Name,DM Value' | Add-Content $OutputLog
$AppNames = 'Attachmate EXTRA X-treme 9.1 - Host Sessions', `
            'Camtasia Studio Library Modules - SuperCallouts', `
            'Citrix Receiver', `
            'Citrix Receiver 14.1 for DR only', `
            'Citrix VPN', `
            'CMTrace', `
            'CutePDF', `
            'CutePDF (Current)', `
            'CutePDF for TS', `
            'DSS Trips 2018 TEST', `
            'DYMO Label', `
            'Ghostscript for CutePDF 2.71', `
            'IBM DB2', `
            'Office 2013 32bit Rollout', `
            'Noble - Winscrape', `
            'Office 2013 Pro Plus w SP1 64bit', `
            'Micro Focus Reflection Desktop', `
            'Verint Impact 360 for Part2er Solutions', `
            'Microsoft Visual C PlusPlus 2012'           
ForEach ($AppName in $AppNames)
{
    $App = Get-CMApplication -Name $AppName
    $Name =  $($App.LocalizedDisplayName)
    $PackageID =  $($App.PackageID)
    Write-Host "Checking $AppNum - $Name" -ForegroundColor Cyan
    $ErrorActionPreference = 'SilentlyContinue'
    Try
    {
        $output = @()
        # $App = Get-CMApplication -ApplicationName $AppName
        $CheckApplicationXML = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($App.SDMPackageXML, $True)
	    ForEach ($DM in $CheckApplicationXML.DeploymentTypes)
	    {
            # $DM = ([Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($AppXML)).DeploymentTypes
            # $EnhancedDetectionMethod = [xml] $AppXML.DeploymentTypes[0].installer.EnhancedDetectionMethod.xml
            $DTTitle = $DM.Title
            $DMTypes1 = $DM.Installer.EnhancedDetectionMethod.Settings.type
            $DMTypes2 = $DM.Installer.EnhancedDetectionMethod.Settings.SourceType
            ForEach ($DMType in $DMTypes1)
            {
                If ($DMType -eq 'MSI')
                {
                    $ProductCode = $($DM.Installer.EnhancedDetectionMethod.Settings).ProductCode
                    $OName = $DM.Installer.EnhancedDetectionMethod.Rule.Expression.Operator.OperatorName
                    $OValue = $DM.Installer.EnhancedDetectionMethod.Rule.Expression.Operands.value
                    $output += "$DMType,$Name,$PackageID,$DTTitle,$ProductCode,$OName,$OValue`n"
                }
                If ($DMType -eq 'Folder')
                {
                    $Location = $($DM.Installer.EnhancedDetectionMethod.Settings).Location
                    $OName = $DM.Installer.EnhancedDetectionMethod.Rule.Expression.Operator.OperatorName
                    $OValue = $DM.Installer.EnhancedDetectionMethod.Rule.Expression.Operands.value
                    $output += "$DMType,$Name,$PackageID,$DTTitle,$Location,$OName,$OValue`n"
                }
                If ($DMType -eq 'File')
                {
                    $Location = $($DM.Installer.EnhancedDetectionMethod.Settings).Location
                    $OName = $DM.Installer.EnhancedDetectionMethod.Rule.Expression.Operator.OperatorName
                    $OValue = $DM.Installer.EnhancedDetectionMethod.Rule.Expression.Operands.value
                    $output += "$DMType,$Name,$PackageID,$DTTitle,$Location,$OName,$OValue`n"
                }
            }
            ForEach ($DMType2 in $DMTypes2)
            {
                If ($DMType2 -eq 'Registry')
                {
                    $Location = $($DM.Installer.EnhancedDetectionMethod.Settings).Location
                    $ValueName = $($DM.Installer.EnhancedDetectionMethod.Settings).ValueName
                    $OName = $DM.Installer.EnhancedDetectionMethod.Rule.Expression.Operator.OperatorName
                    $OValue = $DM.Installer.EnhancedDetectionMethod.Rule.Expression.Operands.value
                    $output += "$DMType2,$Name,$PackageID,$DTTitle,$Location | $ValueName,$OName,$OValue`n"
                }
            }
        }
        $output | Add-Content $OutputLog
        $output
    }
    Catch
    {
        Write-Host "$Name,check failed" -ForegroundColor Red
    }
    $AppNum++
}
# REMOVE BLANK LINES
(gc $OutputLog) | ? {$_.trim() -ne "" } | Set-Content $OutputLog
#################################################################################################
#################################################################################################
#>
