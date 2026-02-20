$ApplicationName = 'IBM DB2'

}
$ApplicationName = 'IBM DB2'



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
$App = Get-CMApplication -Name $ApplicationName
# $App = Get-CMApplication -Name 'IBM DB2'
$AppName =  $App.LocalizedDisplayName
$PackageID =  $App.PackageID
Write-Host "Checking $AppNum - $AppName" -ForegroundColor Cyan

$output = @()
# $App = Get-CMApplication -ApplicationName $AppName
$CheckApplicationXML = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($App.SDMPackageXML, $True)
ForEach ($DM in $CheckApplicationXML.DeploymentTypes)
{
    # $DM = ([Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($AppXML)).DeploymentTypes
    # $EnhancedDetectionMethod = [xml] $AppXML.DeploymentTypes[0].installer.EnhancedDetectionMethod.xml
    $DTTitle = $DM.Title
    $DTSettings = $DM.Installer.EnhancedDetectionMethod.Settings
    ForEach ($Setting in $DTSettings)
    {
        $SettingType = $Setting.Type
        # $Setting
        # $SettingType
        # $output += "$AppName,$PackageID,$DTTitle,"
        If ($SettingType -eq 'MSI')
        {
            $ProdCode = $Setting.ProductCode
               $OName = $DM.Installer.EnhancedDetectionMethod.Rule.Expression.Operator.OperatorName
              $OValue = $DM.Installer.EnhancedDetectionMethod.Rule.Expression.Operands.value
            $output += "$SettingType,$ProdCode,$OName,$OValue"
        }
        If ($SettingType -eq 'Folder')
        {
            $FilePath = $Setting.Location
               $OName = $DM.Installer.EnhancedDetectionMethod.Rule.Expression.Operator.OperatorName
              $OValue = $DM.Installer.EnhancedDetectionMethod.Rule.Expression.Operands.value
            $output += "$SettingType,$FilePath,$OName,$OValue"
        }
        If ($SettingType -eq 'File')
        {
            $FilePath = $Setting.Location
               $OName = $DM.Installer.EnhancedDetectionMethod.Rule.Expression.Operator.OperatorName
              $OValue = $DM.Installer.EnhancedDetectionMethod.Rule.Expression.Operands.value
            $output += "$SettingType,$FilePath,$OName,$OValue"

        }
    }
    ForEach ($DMType2 in $DMTypes2)
    {
        If ($DMType2 -eq 'Registry')
        {
             $Location = $Setting.Location
            $ValueName = $Setting.ValueName
             $OName = $DM.Installer.EnhancedDetectionMethod.Rule.Expression.Operator.OperatorName
            $OValue = $DM.Installer.EnhancedDetectionMethod.Rule.Expression.Operands.value
            $output += "$SettingType,$Location | $ValueName,$OName,$OValue"
        }
    }
}
[string]$string = $output -join ','
$string

$Rule = $DM.Installer.EnhancedDetectionMethod.Rule.Expression
ForEach ($item in $Rule)
{
  $Oper0 = $item.Operator
  $Oper1 = $item.Operands
  $Oper2 = $item.Operands.Operands
  $Oper3 = $item.Operands.Operands.Operands
  $Oper4 = $item.Operands.Operands.Operands
  $Oper1 | Out-File 'D:\Powershell\!SCCM_PS_scripts\!Appplications_and_Packages\Operands1.txt'
  $Oper2 | Out-File 'D:\Powershell\!SCCM_PS_scripts\!Appplications_and_Packages\Operands2.txt'
  $Oper3 | Out-File 'D:\Powershell\!SCCM_PS_scripts\!Appplications_and_Packages\Operands3.txt'
  $Oper4 | Out-File 'D:\Powershell\!SCCM_PS_scripts\!Appplications_and_Packages\Operands4.txt'
  
  If ($Oper1 -ne $null)
  {
    ForEach ($OName in $oper1.Operator)
    {
      $OName.OperatorName
    }
  }
}



# Rules
$Oper1.Operator.OperatorName # Multiple
    Write-Host "`n`n"
$Oper2.SettingLogicalName # Single
$Oper2.SettingSourceType # Single
$Oper2.Value
    Write-Host "`n`n"
$Oper3.SettingLogicalName # Multiple
$Oper3.SettingSourceType # Multiple
$Oper3.Value
    Write-Host "`n`n"
$Oper4.SettingLogicalName # Multiple
$Oper4.SettingSourceType # Multiple
$Oper4.Value


#############################################################
# Settings

# Clause 01
$Oper2[0].SettingSourceType      # File
$Oper2[0].SettingLogicalName     # File_ae5777ff-6b06-4424-8456-7bed9f91bef0
$Oper1.Operator[0].OperatorName  # NotEquals
$Oper2.Value[0]                  # 0
    Write-Host "`n`n"

# Connector 01
$Oper0.OperatorName             # Or
    Write-Host "`n`n"

# Clause 02
$Oper3[0].SettingSourceType      # File
$Oper3[0].SettingLogicalName     # File_2d2e7541-d897-40f3-8556-f1d5c0db9d03
$Oper1.Operator[0].OperatorName  # NotEquals
$Oper3[1].Value                  # 0
    Write-Host "`n`n"

# Connector 02
$Oper1.Operator[1].OperatorName  # And
    Write-Host "`n`n"

# Clause 03
$Oper3[2].SettingSourceType      # MSI
$Oper3[2].SettingLogicalName     # MSI_349c20d7-14f0-4b88-865c-9f404e7c934b
$Oper1.Operator[0].OperatorName  # NotEquals
$Oper3[3].Value[0]               # 0
    Write-Host "`n`n"


#############################################################
# RULES
# Clause 01
$DTSettings[0].Type             # File
$DTSettings[0].LogicalName      # File_ae5777ff-6b06-4424-8456-7bed9f91bef0
$DTSettings[0].Location         # %ProgramFiles(x86)%\IBM\SQLLIB\BIN\db2cmd.exe
    Write-Host "`n`n"

# Clause 02
$DTSettings[1].Type             # File
$DTSettings[1].LogicalName      # File_2d2e7541-d897-40f3-8556-f1d5c0db9d03
$DTSettings[1].Location         # %ProgramFiles%\IBM\SQLLIB\BIN\db2cmd.exe
    Write-Host "`n`n"

# Clause 03
$DTSettings[2].Type             # MSI
$DTSettings[2].LogicalName      # MSI_349c20d7-14f0-4b88-865c-9f404e7c934b
$DTSettings[2].Location         # {ABD23811-AA8F-416B-9EF6-E54D62F21A49}
    Write-Host "`n`n"


$Oper1[0]
$Oper1[1]

$Oper2[0]
$Oper2[1]
$Oper2[2]
$Oper2[3]

$Oper3[0]
$Oper3[1]
$Oper3[2]
$Oper3[3]





# Rules

$Types = $Oper2.SettingSourceType # Multiple

$LogicalNames = $Oper2.SettingLogicalName # Multiple

$Values = $Oper2.Value

$Presences = $Oper1.Operator.OperatorName # Multiple

ForEach ($thing in $oper2)
{
    $thing
    Write-Host "`n`n"
    #$Type = $thing.SettingSourceType
    #$LName = $thing.SettingLogicalName
    #$Value = $thing.Value
    #"$Type,$LName,$Value" -join ','
}

