cls

# Add Required Type Libraries
    [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ManagementProvider.dll")) | Out-Null
    [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.dll")) | Out-Null
    [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.Extender.dll")) | Out-Null
    [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.MsiInstaller.dll")) | Out-Null


# Used for creating rules
    # Add-Type -Path "D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\DcmObjectModel.dll"
    [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "DcmObjectModel.dll")) | Out-Null
# WQL Connection to Server
    # Add-Type -Path "D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\AdminUI.WqlQueryEngine.dll"
    [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "AdminUI.WqlQueryEngine.dll")) | Out-Null
# Application Wrapper and Factory
    # Add-Type -Path "D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin\AdminUI.AppManFoundation.dll"
    [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "AdminUI.AppManFoundation.dll")) | Out-Null
 
Set-Location SS1:
CD SS1:

$DeploymentTypes = Get-CMDeploymentType -ApplicationName "Test - Fake App"

Write-Host $DeploymentTypes


$oOperands = select-object Microsoft.ConfigurationManagement.DesiredConfigurationManagement.CustomCollection``1[[Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.RuleExpression]]
   ####if ($oOperands -ne $null) { Write-Host " oOperands object Created"} else {Write-Host " oOperands object Creation failed"; exit}
 
 Write-Host Operands = $oOperands










 
#####################################################
# Core Application Details
 
[string]$sPackageDirectory         ="\\sccmserver\Library\7Zip_09.20_86a"
[string]$sApplicationName          = "Test - Fake App"
[string]$sApplicationDestription   = "Fake App Description"
[string]$sApplicationVersion       = "1.0"
[string]$sApplicationPublisher     = "Fake Inc"
[string]$ApplicationOwner          = "user1"
 
[string]$sSCCMServerName           = "SCCMSERVER"
[string]$sSCCMUsername             = "user1"
[string]$sSCCMPassword             = "SCCMPassword"
 
#####################################################
# Functions
 
# WQLConnect
# Purpose: To create a WQL query connection to an SCCM Server
#          This will utilise credentials if script isn't being run on the server itself
#
function WQLConnect($Server, $User, $Password) {
 
  $namedValues              = New-Object Microsoft.ConfigurationManagement.ManagementProvider.SmsNamedValuesDictionary
  if ($namedValues -ne $null) { Write-Host " namedValues object Created"} else {Write-Host " namedValues object Creation failed"; exit}
 
  $connection               = New-Object Microsoft.ConfigurationManagement.ManagementProvider.WqlQueryEngine.WqlConnectionManager
  if ($connection  -ne $null) { Write-Host " connection  object Created"} else {Write-Host " connection  object Creation failed"; exit}
 
 
  # Connect with credentials if not running on the server itself
  if ($env:computername.ToUpper() -eq $Server.ToUpper()){
     Write-Host  "Local WQL Connection Made"
     [void]$connection.Connect($Server)
  }
  else
  {
     Write-Host  "Remote WQL Connection Made: " + $sSCCMServerName
     [void]$connection.Connect($Server, $User, $Password)
 
  }
  return $connection
 
}
											
											#	# Store
											#	# Purpose: To commit the completed application to SCCM
											#	#
											#	function store ($Application){
											#	 
											#	                # Set the application into the provider object.
											#	                $oAppManWrapper.InnerAppManObject = $Application
											#	 
											#	                # "Initializing the SMS_Application object with the model."
											#	                $oApplicationFactory.PrepareResultObject($oAppManWrapper);
											#	 
											#	                # Save to the database.
											#	                $oAppManWrapper.InnerResultObject.Put();
											#	}
 
 
#####################################################
# Main
 
#create connection to SCCMServer (not used until the end of the script)
$oServerConnection                       = WQLConnect $sSCCMServerName $sSCCMUsername $sSCCMPassword
$oApplicationFactory                     = New-Object Microsoft.ConfigurationManagement.AdminConsole.AppManFoundation.ApplicationFactory
$oAppManWrapper                          = [Microsoft.ConfigurationManagement.AdminConsole.AppManFoundation.AppManWrapper]::Create( $oServerConnection , $oApplicationFactory)
 
 
Write-Host  "Creating Application Object"
$oApplication                        = New-Object Microsoft.ConfigurationManagement.ApplicationManagement.Application
   if ($oApplication -ne $null) { Write-Host " oApplication object Created"} else {Write-Host " oApplication object Creation failed"; exit}
 
 
$oApplication.Title                       = $sApplicationName
$oApplication.SoftwareVersion             = $sApplicationVersion
$oApplication.Publisher                   = $sApplicationPublisher
$oApplication.DisplayInfo.DefaultLanguage = "en-US"
 
Write-Host  "Creating Application Display Info"
 
$oApplicationDisplayInfo = New-Object Microsoft.ConfigurationManagement.ApplicationManagement.AppDisplayInfo
  if ($oApplicationDisplayInfo -ne $null) { Write-Host " oApplicationDisplayInfo object Created"} else {Write-Host " oApplicationDisplayInfoo object Creation failed"; exit}
 
 
$oApplicationDisplayInfo.Title            = $sApplicationName
$oApplicationDisplayInfo.Description      = $sApplicationDestription
$oApplicationDisplayInfo.Language         = "en-US"
$oApplication.DisplayInfo.DefaultLanguage = "en-US"
$oApplication.DisplayInfo.Add($oApplicationDisplayInfo)
 
 
$oAppinstaller = New-Object Microsoft.ConfigurationManagement.ApplicationManagement.ScriptInstaller
  if ($oAppinstaller -ne $null) { Write-Host " oAppinstaller object Created"} else {Write-Host " oAppinstaller object Creation failed"; exit}
 
#Note that this example hardcodes install and remove syntax by using
#a launcher for all applications
 
$oAppinstaller.InstallCommandLine          = '"Launcher.exe"'
$oAppinstaller.UninstallCommandLine        = '"Launcher.exe" /Remove'
 
#####################################################
# Upload File Content to Server
 
Write-Host  "Upload Content"
 
$oContent                                   = [Microsoft.ConfigurationManagement.ApplicationManagement.ContentImporter]::CreateContentFromFolder($sPackageDirectory)
$oContent.OnSlowNetwork                     = "Download"
$oAppinstaller.Contents.Add($oContent)
 
 
#####################################################
# Main Creating Enhanced File Detection Method (file based)
# This uses a standard Package signature file under c:\windows\logs
# to determine if the package is installed
 
Write-Host  "Enabling Enhanced File Detection"
$oAppinstaller.DetectionMethod = [Microsoft.ConfigurationManagement.ApplicationManagement.DetectionMethod]::Enhanced
$oEnhancedDetection = New-Object Microsoft.ConfigurationManagement.ApplicationManagement.EnhancedDetectionMethod
  if ($oEnhancedDetection -ne $null) { Write-Host " oEnhancedDetection object Created"} else {Write-Host " oEnhancedDetection object Creation failed"; exit}
 
$oDetectionType              = [Microsoft.ConfigurationManagement.DesiredConfigurationManagement.ConfigurationItemPartType]::File
$oFileSetting                = New-Object Microsoft.ConfigurationManagement.DesiredConfigurationManagement.FileOrFolder( $oDetectionType , $null)
  if ($oFileSetting -ne $null) { Write-Host " oFileSetting object Created"} else {Write-Host " oFileSetting object Creation failed"; exit}
 
$oFileSetting.FileOrFolderName = $sApplicationName + ".sig"
$oFileSetting.Path             = "%Windir%\Logs"
$oFileSetting.Is64Bit          = 1
$oFileSetting.SettingDataType  = [Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.DataType]::Int64
 
$oEnhancedDetection.Settings.Add($oFileSetting)
 
 
Write-Host  "Settings Reference"
$oSettingRef                  = New-Object Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.SettingReference(
$oApplication.Scope,
$oApplication.Name,
$oApplication.Version,
$oFileSetting.LogicalName,
$oFileSetting.SettingDataType,
$oFileSetting.SourceType,
[bool]0 )
# setting bool 0 as false
if ($oSettingRef -ne $null) { Write-Host " oSettingRef object Created"} else {Write-Host " oSettingRef object Creation failed"; exit}
 
 
$oSettingRef.MethodType    = [Microsoft.ConfigurationManagement.DesiredConfigurationManagement.ConfigurationItemSettingMethodType]::Value
$oConstValue               = New-Object Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.ConstantValue( 0, 
[Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.DataType]::Int64)
   if ($oConstValue -ne $null) { Write-Host " oConstValue object Created"} else {Write-Host " oConstValue object Creation failed"; exit}
 
$oFileCheckOperands = new-object Microsoft.ConfigurationManagement.DesiredConfigurationManagement.CustomCollection``1[[Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.ExpressionBase]]
$oFileCheckOperands.Add($oSettingRef)
$oFileCheckOperands.Add($oConstValue)
 
$FileCheckExpression = new-object Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.Expression(
[Microsoft.ConfigurationManagement.DesiredConfigurationManagement.ExpressionOperators.ExpressionOperator]::NotEquals, $oFileCheckOperands)
 
$oRule              = new-object Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Rules.Rule("IsInstalledRule", 
[Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Rules.NoncomplianceSeverity]::None, $null, $FileCheckExpression)
   if ($oRule  -ne $null) { Write-Host " rule object Created"} else {Write-Host " rule object Creation failed"; exit}
 
 
$oEnhancedDetection.Rule = $oRule 
$oAppinstaller.EnhancedDetectionMethod = $oEnhancedDetection
 
#####################################################
# Add Deployment Type to Application
 
 
Write-Host  "Adding Deployment Type"
$oApplicationDeploymentType = new-object Microsoft.ConfigurationManagement.ApplicationManagement.DeploymentType($oAppinstaller, 
[Microsoft.ConfigurationManagement.ApplicationManagement.ScriptInstaller]::TechnologyId, 
[Microsoft.ConfigurationManagement.ApplicationManagement.NativeHostingTechnology]::TechnologyId)
 
if ($oApplicationDeploymentType -ne $null) { Write-Host " NewApplicationDeploymentType object Created"} else {Write-Host " NewApplicationDeploymentType object Creation failed"; exit}
 
 
$oApplicationDeploymentType.Title = $oApplication.Title 
 
#####################################################

#Write-Host "Limiting Collections to 64bit workstations"
 
$oOperands = select-object "Microsoft.ConfigurationManagement.DesiredConfigurationManagement.CustomCollection``1[[Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.RuleExpression]]"
   ####if ($oOperands -ne $null) { Write-Host " oOperands object Created"} else {Write-Host " oOperands object Creation failed"; exit}
 
 Write-Host $oOperands
 
# Its possible to limit the deployment of application to specific operating systems
# A current list of possible values may be found t:
# <a href="http://www.laurierhodes.info/?q=node/60">http://www.laurierhodes.info/?q=node/60</a>

#		$oOperands.Add("Windows/All_x64_Windows_XP_Professional")
#		$oOperands.Add("Windows/All_x64_Windows_7_Client")
#		$oOperands.Add("Windows/All_x64_Windows_8_Client")
#		$oOperands.Add("Windows/All_x64_Windows_8.1_Client")
#		 
#		$oOSExpression           = new-object Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.OperatingSystemExpression -ArgumentList ([Microsoft.ConfigurationManagement.DesiredConfigurationManagement.ExpressionOperators.ExpressionOperator]::OneOf), $oOperands    
#		$oAnnotation             = new-object Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Rules.Annotation      
#		$oAnnotation.DisplayName = new-object Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Rules.LocalizableString -ArgumentList "DisplayName", "Operating system One of {All x86 Windows XP (64bit)}", $null
#		 
#		$oDTRule = new-object "Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Rules.Rule" -ArgumentList ("Rule_" + [Guid]::NewGuid().ToString()), 
#		            ([Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Rules.NoncomplianceSeverity]::None), 
#		             $oAnnotation, 
#		             $oOSExpression
#		 
#		Write-Host "Adding Deployment Type rule to Application"     
#		$oApplicationDeploymentType.Requirements.Add($oDTRule)
#		 
#		############################################