$AppName = 'IBM DB2'
$App = Get-CMApplication -Name $AppName
$output = @()
        $CheckApplicationXML = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($App.SDMPackageXML, $True)
	    ForEach ($DeploymentType in $CheckApplicationXML.DeploymentTypes)
	    {
            # $DeploymentType = ([Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($AppXML)).DeploymentTypes
            # $EnhancedDetectionMethod = [xml] $AppXML.DeploymentTypes[0].installer.EnhancedDetectionMethod.xml
            $DTTitle = $DeploymentType.Title
            $DeploymentTypeTypes1 = $DeploymentType.Installer.EnhancedDetectionMethod.Settings.type
            $DeploymentTypeTypes2 = $DeploymentType.Installer.EnhancedDetectionMethod.Settings.SourceType
            ForEach ($DeploymentTypeType in $DeploymentTypeTypes1)
            {
                If ($DeploymentTypeType -eq 'MSI')
                {
                    $ProductCode = $($DeploymentType.Installer.EnhancedDetectionMethod.Settings).ProductCode
                    $OName = $DeploymentType.Installer.EnhancedDetectionMethod.Rule.Expression.Operator.OperatorName
                    $OValue = $DeploymentType.Installer.EnhancedDetectionMethod.Rule.Expression.Operands.value
                    $output += "$DeploymentTypeType,$Name,$PackageID,$DTTitle,$ProductCode,$OName,$OValue`n"
                }
                If ($DeploymentTypeType -eq 'Folder')
                {
                    $Location = $($DeploymentType.Installer.EnhancedDetectionMethod.Settings).Location
                    $OName = $DeploymentType.Installer.EnhancedDetectionMethod.Rule.Expression.Operator.OperatorName
                    $OValue = $DeploymentType.Installer.EnhancedDetectionMethod.Rule.Expression.Operands.value
                    $output += "$DeploymentTypeType,$Name,$PackageID,$DTTitle,$Location,$OName,$OValue`n"
                }
                If ($DeploymentTypeType -eq 'File')
                {
                    $Location = $($DeploymentType.Installer.EnhancedDetectionMethod.Settings).Location
                    $OName = $DeploymentType.Installer.EnhancedDetectionMethod.Rule.Expression.Operator.OperatorName
                    $OValue = $DeploymentType.Installer.EnhancedDetectionMethod.Rule.Expression.Operands.value
                    $output += "$DeploymentTypeType,$Name,$PackageID,$DTTitle,$Location,$OName,$OValue`n"
                }
            }
            ForEach ($DeploymentTypeType2 in $DeploymentTypeTypes2)
            {
                If ($DeploymentTypeType2 -eq 'Registry')
                {
                    $Location = $($DeploymentType.Installer.EnhancedDetectionMethod.Settings).Location
                    $ValueName = $($DeploymentType.Installer.EnhancedDetectionMethod.Settings).ValueName
                    $OName = $DeploymentType.Installer.EnhancedDetectionMethod.Rule.Expression.Operator.OperatorName
                    $OValue = $DeploymentType.Installer.EnhancedDetectionMethod.Rule.Expression.Operands.value
                    $output += "$DeploymentTypeType2,$Name,$PackageID,$DTTitle,$Location | $ValueName,$OName,$OValue`n"
                }
            }
        }
$output
###################################################################################################################################
$output = @()
<#
    1 = Application
    x = Deployment Types
        x = Detection Methods
            x = Settings
            x = Rules
#>

        $CheckApplicationXML = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($App.SDMPackageXML, $True)
# x = Deployment Types
        ForEach ($DeploymentType in $CheckApplicationXML.DeploymentTypes)
	    {
            $DeploymentType_Title = $DeploymentType.Title
# x = Deployment Methods
            $DT_DM = $DeploymentType.Installer.EnhancedDetectionMethod
# x = Settings
            $Settings = $DeploymentType.Installer.EnhancedDetectionMethod.Settings
            ForEach ($Setting in $Settings)
            {
                $SetType = $Setting.type
                If ($SetType -eq 'File')
                {
                    $Setting.Location
                }
                If ($SetType -eq 'MSI')
                {
                    $Setting.ProductCode
                }
             }
# x = Rules
            $Rules = $DeploymentType.Installer.EnhancedDetectionMethod

            [xml]$RulesXML = $Rules.Xml
            ForEach ($Line in $RulesXML)
            {
                
            }
            
$RulesXML.InnerXml
$RulesXML.OuterXml | Set-Content 'D:\Powershell\!SCCM_PS_scripts\!Appplications_and_Packages\rules_Outer.xml'


[xml]$global:xmldata = get-content 'D:\Powershell\!SCCM_PS_scripts\!Appplications_and_Packages\rules_Outer.xml'


$xmldata.EnhancedDetectionMethod.Rule.Expression


$xmldata.EnhancedDetectionMethod.Rule.Expression.Operands.Expression | Where-Object {$_.Operands.Expression.Operands.SettingReference.SettingLogicalName -like "File_2d2e7541-d897-40f3-8556-f1d5c0db9d03"}
$xmldata.EnhancedDetectionMethod.Rule.Expression.Operands.Expression | Where-Object {$_.Operands.Expression.Operands.SettingReference.SettingLogicalName -like "MSI_349c20d7-14f0-4b88-865c-9f404e7c934b"}
                                                      
                                                       


;WITH XMLNAMESPACES ( DEFAULT 'http://schemas.microsoft.com/SystemCenterConfigurationManager/2009/AppMgmtDigest') 
SELECT     app.Manufacturer, app.DisplayName, app.SoftwareVersion, dt.DisplayName AS DeploymentTypeName, dt.PriorityInLatestApp,
                      dt.Technology,
                      
 dt.SDMPackageDigest.value('(/AppMgmtDigest/DeploymentType/Installer/CustomData/EnhancedDetectionMethod/Settings)[1]','nvarchar(1000)')[ProductCode]
FROM         dbo.fn_ListDeploymentTypeCIs(1033) AS dt INNER JOIN
                      dbo.fn_ListLatestApplicationCIs(1033) AS app ON dt.AppModelName = app.ModelName
WHERE     (dt.IsLatest = 1)

                                                       
                                                       
                                                       $_.Expression.Operands.Expression.Operands.SettingReference.SettingLogicalName

# LogicalName="File_ae5777ff-6b06-4424-8456-7bed9f91bef0" = %ProgramFiles(x86)%\IBM\SQLLIB\BIN
# LogicalName="File_2d2e7541-d897-40f3-8556-f1d5c0db9d03" = %ProgramFiles%\IBM\SQLLIB\BIN
# LogicalName="MSI_349c20d7-14f0-4b88-865c-9f404e7c934b"  = {ABD23811-AA8F-416B-9EF6-E54D62F21A49}




            $Rules = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($Rule.SDMPackageXML, $True)

            ForEach ($Rule in $Rules)
            {
                $Rule.Rule.Expression.Operands.operator

            }



        }

                    $OName = $DeploymentType.Installer.EnhancedDetectionMethod.Rule.Expression.Operator.OperatorName
                    $OValue = $DeploymentType.Installer.EnhancedDetectionMethod.Rule.Expression.Operands.value
                    $output += "$DeploymentTypeType,$Name,$PackageID,$DTTitle,$Location,$OName,$OValue`n"
                }
            }
        }



            ForEach ($Rule in $DT_DM)
            {
            $Rule.Rule.Ruleid
            }

    $DeploymentType.Installer.EnhancedDetectionMethod.Rule.Expression.Operator.OperatorName
    }


$DT_DM.Rule.Expression.Operator.OperatorName


            $DM_Settings = $DT_DM.Settings
            $DM_Rules = $DeploymentType.Installer.EnhancedDetectionMethod.Rule.Expression.Operator.OperatorName
            ForEach ($Rule in $DM_Rules)
            {
            $Rule
            }
            
            ForEach ($DMSetting in $DM_Settings)
            {
                $DMSetting_Type = $DMSetting.type
                If ($DMSetting_Type -eq 'File')
                {
                    $Location = $DMSetting.Location
                    $OName = $DT_DM.Rule.Expression.Operator.OperatorName
                    $OValue = $DT_DM.Rule.Expression.Operands.value
                    "$DeploymentType_Title,$Location,$OName,$OValue`n"
                }
            }
            Write-Host "`n`n`n"
        }

        $DM_Settings = $DT_DM.Rule
        ForEach ($DMSetting in $DM_Settings)
        {
            $DMSetting_Type = $DMSetting.type
            If ($DMSetting_Type -eq 'File')
            {
                $Location = $DMSetting.Location
                $OName = $DT_DM.Rule.Expression.Operator.OperatorName
                $OValue = $DT_DM.Rule.Expression.Operands.value
                "$DeploymentType_Title,$Location,$OName,$OValue`n"
            }
        }




                If ($DeploymentTypeType -eq 'MSI')
                {
                    $ProductCode = $($DeploymentType.Installer.EnhancedDetectionMethod.Settings).ProductCode
                    $OName = $DeploymentType.Installer.EnhancedDetectionMethod.Rule.Expression.Operator.OperatorName
                    $OValue = $DeploymentType.Installer.EnhancedDetectionMethod.Rule.Expression.Operands.value
                    $output += "$DeploymentTypeType,$Name,$PackageID,$DTTitle,$ProductCode,$OName,$OValue`n"
                }
                If ($DeploymentTypeType -eq 'Folder')
                {
                    $Location = $($DeploymentType.Installer.EnhancedDetectionMethod.Settings).Location
                    $OName = $DeploymentType.Installer.EnhancedDetectionMethod.Rule.Expression.Operator.OperatorName
                    $OValue = $DeploymentType.Installer.EnhancedDetectionMethod.Rule.Expression.Operands.value
                    $output += "$DeploymentTypeType,$Name,$PackageID,$DTTitle,$Location,$OName,$OValue`n"
                }
                If ($DeploymentTypeType -eq 'File')
                {
                    $Location = $($DeploymentType.Installer.EnhancedDetectionMethod.Settings).Location
                    $OName = $DeploymentType.Installer.EnhancedDetectionMethod.Rule.Expression.Operator.OperatorName
                    $OValue = $DeploymentType.Installer.EnhancedDetectionMethod.Rule.Expression.Operands.value
                    $output += "$DeploymentTypeType,$Name,$PackageID,$DTTitle,$Location,$OName,$OValue`n"
                }
            }
            ForEach ($DeploymentTypeType2 in $DeploymentTypeTypes2)
            {
                If ($DeploymentTypeType2 -eq 'Registry')
                {
                    $Location = $($DeploymentType.Installer.EnhancedDetectionMethod.Settings).Location
                    $ValueName = $($DeploymentType.Installer.EnhancedDetectionMethod.Settings).ValueName
                    $OName = $DeploymentType.Installer.EnhancedDetectionMethod.Rule.Expression.Operator.OperatorName
                    $OValue = $DeploymentType.Installer.EnhancedDetectionMethod.Rule.Expression.Operands.value
                    $output += "$DeploymentTypeType2,$Name,$PackageID,$DTTitle,$Location | $ValueName,$OName,$OValue`n"
                }
            }
        }
$output