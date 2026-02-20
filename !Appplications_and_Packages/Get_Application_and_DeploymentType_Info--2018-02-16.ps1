# Add Required Type Libraries
#>

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

$SSDate = Get-Date
. "C:\Scripts\!Modules\GoGo_SCCM_Module.ps1"  
Set-Location XX1:
CD XX1:

$SiteServer = "SERVER"
$SiteCode = "XX1"

# $AppName = 'Five9 Softphone'
# Get-CMApplication -ApplicationName $AppName
# $Deployments = Get-CMDeployment -SoftwareName $AppName
# $Deployments.Count

$ADateStart = $(get-date -format yyyy-MM-dd)+'__'+ $(get-date -UFormat %R).Replace(':','.')

   $Folder = "D:\Powershell\!SCCM_PS_scripts\!Appplications_and_Packages\Get_Application_and_DeploymentType_Info"

$OutputLog = "$Folder\Get_Application_and_DeploymentType_Info--$ADateStart.csv"

'Deployment Count^Application Name^Created By^Created Date^Modified Date^Modified By^Administrative Categories^Administrator Comments^Publisher^Revision^Software Version^Software Icon^DeploymentType 1^DeploymentType Name 1^DeploymentType Contacts 1^DeploymentType Owners 1^DeploymentType ReleaseDate 1^DeploymentType Description 1^DeploymentType Install Command Line 1^DeploymentType Uninstall Command Line 1' | Add-Content $OutputLog

[int]$AppNum = '1'

Get-CMApplication | % {
	$output = @()

	#Application
	
    $Deployments = Get-CMDeployment -SoftwareName $($_.LocalizedDisplayName)
    $DeploymentCount = $Deployments.Count


	$Path = "$Folder\Application--$($_.LocalizedDisplayName)"
	
		# $global:Application = Get-CMApplication -ApplicationName $AppName
		$_ | Out-File "$Path--Get-CMApplication--Results.txt"
	
		$global:CheckApplicationXML = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($_.SDMPackageXML, $True)
		# $CheckApplicationXML | Out-File "$Path--CheckApplicationXML--Results.txt"
	
	# DeploymentType
		# $global:DeploymentTypes = Get-CMDeploymentType -ApplicationName $($_.LocalizedDisplayName)
		# $DeploymentTypes | Out-File "$Path--DeploymentTypes--Get-CMDeploymentType--Results.txt"
		# $global:CheckDeploymentTypesXML = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($DeploymentTypes.SDMPackageXML, $True)
		# $CheckDeploymentTypesXML | Out-File "$Path----CheckDeploymentTypesXML--Results.txt"
		# $global:DeploymentTypesSDMPackageXML = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($DeploymentTypes.SDMPackageXML, $True)
		# $DeploymentTypesSDMPackageXML | Out-File "$Path----DeploymentTypesSDMPackageXML--Results.txt"
	
	# cls
	If (($_.LocalizedDisplayName).Length -eq 0){$AppLocalizedDisplayName = 'N/A'} Else{ $AppLocalizedDisplayName = $_.LocalizedDisplayName}
	If (($_.CreatedBy).Length -eq 0){$AppCreatedBy = 'N/A'} Else{ $AppCreatedBy = $_.CreatedBy}
	If (($_.DateCreated).Length -eq 0){$AppDateCreated = 'N/A'} Else{ $AppDateCreated = $_.DateCreated}
	If (($_.DateLastModified).Length -eq 0){$AppDateLastModified = 'N/A'} Else{ $AppDateLastModified = $_.DateLastModified}
	If (($_.LastModifiedBy).Length -eq 0){$AppLastModifiedBy = 'N/A'} Else{ $AppLastModifiedBy = $_.LastModifiedBy}
	If (($_.LocalizedCategoryInstanceNames).Length -eq 0){$AppLocalizedCategoryInstanceNames = 'N/A'}Else{ $AppLocalizedCategoryInstanceNames = $_.LocalizedCategoryInstanceNames}
	If (($_.LocalizedDescription).Length -eq 0){$AppLocalizedDescription = 'N/A'} Else{ $AppLocalizedDescription = $_.LocalizedDescription}
	If (($_.Manufacturer).Length -eq 0){$AppManufacturer = 'N/A'} Else{ $AppManufacturer = $_.Manufacturer}
	If (($_.SDMPackageVersion).Length -eq 0){$AppSDMPackageVersion = 'N/A'} Else{ $AppSDMPackageVersion = $_.SDMPackageVersion}
	If (($_.SoftwareVersion).Length -eq 0){$AppSoftwareVersion = 'N/A'} Else{ $AppSoftwareVersion = $_.SoftwareVersion}
	If ($CheckApplicationXML.DisplayInfo.Icon.Data){$AppSoftwareIcon = 'Icon set'}Else{$AppSoftwareIcon = 'Icon not set'}
	
	
	Write-Host "Checking app number: $AppNum"
	Write-Host "** Application Information ***`t" $AppLocalizedDisplayName -ForegroundColor Cyan
	# Write-Host "`tCreated By                 :`t" $AppCreatedBy
	# Write-Host "`tCreated Date               :`t" $AppDateCreated
	# Write-Host "`tModified Date              :`t" $AppDateLastModified
	# Write-Host "`tModified By                :`t" $AppLastModifiedBy
	# Write-Host "`tAdministrative Categories  :`t `"" $AppLocalizedCategoryInstanceNames "`""
	# Write-Host "`tAdministrator Comments     :`t" $AppLocalizedDescription
	# Write-Host "`tPublisher                  :`t" $AppManufacturer
	# Write-Host "`tRevision                   :`t" $AppSDMPackageVersion
	# Write-Host "`tSoftware Version           :`t" $AppSoftwareVersion
	# Write-Host "`tSoftware Icon              :`t" $AppSoftwareIcon
	
	$output += [string]$DeploymentCount + '^' + $AppLocalizedDisplayName + '^' + $AppCreatedBy + '^' + $AppDateCreated + '^' + $AppDateLastModified + '^' + $AppLastModifiedBy + '^' + $AppLocalizedCategoryInstanceNames + '^' + $AppLocalizedDescription + '^' + $AppManufacturer + '^' + $AppSDMPackageVersion + '^' + $AppSoftwareVersion + '^' + $AppSoftwareIcon + '^'
    # $output | Add-Content $OutputLog
	
	ForEach ($CheckDeploymentType in $CheckApplicationXML.DeploymentTypes)
	{
		If (($CheckDeploymentType.Title).Length -eq 0){$DTTitle = 'N/A'}Else{$DTTitle = $CheckDeploymentType.Title}
		If ((($CheckApplicationXML.Contacts).ID).Length -eq 0){$DTContacts = 'N/A'}Else{$DTContacts = ($CheckApplicationXML.Contacts).ID}
		If ((($CheckApplicationXML.Owners).ID).Length -eq 0){$DTOwners = 'N/A'}Else{$DTOwners = ($CheckApplicationXML.Owners).ID}
		If (($CheckApplicationXML.ReleaseDate).Length -eq 0){$DTReleaseDate = 'N/A'}Else{$DTReleaseDate = $CheckApplicationXML.ReleaseDate}
		If (($CheckDeploymentType.Description).Length -eq 0){$DTDescription  =  'N/A'}Else{$DTDescription = $CheckDeploymentType.Description}
		If (($CheckDeploymentType.Installer.InstallCommandLine).Length -eq 0){$DTInstallCommandLine  =  'N/A'}Else{$DTInstallCommandLine = $CheckDeploymentType.Installer.InstallCommandLine}
		If (($CheckDeploymentType.Installer.UninstallCommandLine).Length -eq 0){$DTUninstallCommandLine  =  'N/A'}Else{$DTUninstallCommandLine = $CheckDeploymentType.Installer.UninstallCommandLine}
	
		Write-Host "** DeploymentType Information ***`t"  $DTTitle -ForegroundColor Green
		# Write-Host "`tDeploymentType Contacts                :`t" $DTContacts
		# Write-Host "`tDeploymentType Owners                  :`t" $DTOwners
		# Write-Host "`tDeploymentType ReleaseDate             :`t" $DTReleaseDate
		# Write-Host "`tDeploymentType Description             :`t" $DTDescription
		# Write-Host "`tDeploymentType Install Command Line    :`t" $DTInstallCommandLine
		# Write-Host "`tDeploymentType Uninstall Command Line  :`t" $DTUninstallCommandLine
		# Write-Host ""
	
		$output += 'DType:' + '^' + $DTTitle + '^' + $DTContacts + '^' + $DTOwners + '^' + $DTReleaseDate + '^' + $DTDescription + '^' + $DTInstallCommandLine + '^' + $DTUninstallCommandLine + '^'
        # $output | Add-Content $OutputLog
	}
    $AppNum++
	[string] $output | Add-Content $OutputLog
}
    $CheckApplicationXML_Log = "$Folder\CheckApplicationXML" 
$CheckDeploymentTypesXML_Log = "$Folder\CheckDeploymentTypesXML" 
      $Get_CMApplication_Log = "$Folder\Get-CMApplication" 
   $Get_CMDeploymentType_Log = "$Folder\Get_Application_and_DeploymentType_Info" 
$ResultFiles = Get-ChildItem $Folder -Recurse -Depth 0
# ForEach ($File in $ResultFiles)
# {
#     If ($File.Name -like '*Get-CMApplication*')
#     {
#         Move-Item $File.FullName $Get_CMApplication_Log -Force
#     }
# }


######################################################################################################
$SEDate = (GET-DATE)
$Span = NEW-TIMESPAN –Start $SSDate –End $SEDate
$Min = $Span.minutes
$Sec = $Span.Seconds
Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`r`n" -ForegroundColor Cyan


<#
$CheckApplicationXML.DisplayInfo.Icon.Data
$CheckApplicationXML.DisplayInfo.Icon.Id

	if ($CheckApplicationXML.DisplayInfo.Icon.Data)
	{
        'found'
    }
    Else
    {
        'not found'
    }

([Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($DeploymentTypes.SDMPackageXML)).DeploymentTypes[0].Installer.RequiresLogon

and

([xml]($DeploymentTypes.SDMPackageXML)).AppMgmtDigest.DeploymentType.Installer.RequiresLogon




$WMIApp = Get-WmiObject -ComputerName $SiteServer -Namespace root\SMS\site_$SiteCode -class SMS_Application | Where-Object {$_.IsLatest -eq $True -and $_.LocalizedDisplayName -eq $AppName}
# $Applications | Add-Content 'D:\Powershell\!SCCM_PS_scripts\!Appplications_and_Packages\WMI--SMS_Application_Info.txt'

$WMIApp | ForEach-Object {
    $CheckApplication = [wmi]$_.__PATH
    $CheckApplicationXML = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($CheckApplication.SDMPackageXML,$True)
    ForEach ($CheckDeploymentType in $CheckApplicationXML.DeploymentTypes)
    {
    	Write-Host "DeploymentType Title = $($CheckDeploymentType.Title)" -ForegroundColor Green
    	Write-Host "DeploymentType Contacts = $($CheckDeploymentType.Contacts)" -ForegroundColor Green
    	Write-Host "DeploymentType Description = $($CheckDeploymentType.Description)" -ForegroundColor Green
    	Write-Host "DeploymentType Owners = $($CheckDeploymentType.Owners)" -ForegroundColor Green
    	Write-Host "DeploymentType ReleaseDate = $($CheckDeploymentType.ReleaseDate)" -ForegroundColor Green
        Write-Host ""
    }
}










$oOperands = select-object Microsoft.ConfigurationManagement.DesiredConfigurationManagement.CustomCollection``1[[Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.RuleExpression]]
   ####if ($oOperands -ne $null) { Write-Host " oOperands object Created"} else {Write-Host " oOperands object Creation failed"~ exit}
 
 Write-Host Operands = $oOperands










 
#####################################################
# Core Application Details
 
[string]$sPackageDirectory         ="\\sccmserver\Library\7Zip_09.20_86a"
[string]$sApplicationName          = "Test - Fake App"
[string]$sApplicationDestription   = "Fake App Description"
[string]$sApplicationVersion       = "1.0"
[string]$sApplicationPublisher     = "Fake Inc"
[string]$ApplicationOwner          = "SUPERUSER"
 
[string]$sSCCMServerName           = "SERVER"
[string]$sSCCMUsername             = "SUPERUSER"
[string]$sSCCMPassword             = "SCCMPassword"
 
#####################################################
# Functions
 
# WQLConnect
# Purpose: To create a WQL query connection to an SCCM Server
#          This will utilise credentials if script isn't being run on the server itself
#
function WQLConnect($Server, $User, $Password) {
 
  $namedValues              = New-Object Microsoft.ConfigurationManagement.ManagementProvider.SmsNamedValuesDictionary
  if ($namedValues -ne $null) { Write-Host " namedValues object Created"} else {Write-Host " namedValues object Creation failed"~ exit}
 
  $connection               = New-Object Microsoft.ConfigurationManagement.ManagementProvider.WqlQueryEngine.WqlConnectionManager
  if ($connection  -ne $null) { Write-Host " connection  object Created"} else {Write-Host " connection  object Creation failed"~ exit}
 
 
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
											#	                $oApplicationFactory.PrepareResultObject($oAppManWrapper)~
											#	 
											#	                # Save to the database.
											#	                $oAppManWrapper.InnerResultObject.Put()~
											#	}
 
 
#####################################################
# Main
 
#create connection to SCCMServer (not used until the end of the script)
$oServerConnection                       = WQLConnect $sSCCMServerName $sSCCMUsername $sSCCMPassword
$oApplicationFactory                     = New-Object Microsoft.ConfigurationManagement.AdminConsole.AppManFoundation.ApplicationFactory
$oAppManWrapper                          = [Microsoft.ConfigurationManagement.AdminConsole.AppManFoundation.AppManWrapper]::Create( $oServerConnection , $oApplicationFactory)
 
 
Write-Host  "Creating Application Object"
$oApplication                        = New-Object Microsoft.ConfigurationManagement.ApplicationManagement.Application
   if ($oApplication -ne $null) { Write-Host " oApplication object Created"} else {Write-Host " oApplication object Creation failed"~ exit}
 
 
$oApplication.Title                       = $sApplicationName
$oApplication.SoftwareVersion             = $sApplicationVersion
$oApplication.Publisher                   = $sApplicationPublisher
$oApplication.DisplayInfo.DefaultLanguage = "en-US"
 
Write-Host  "Creating Application Display Info"
 
$oApplicationDisplayInfo = New-Object Microsoft.ConfigurationManagement.ApplicationManagement.AppDisplayInfo
  if ($oApplicationDisplayInfo -ne $null) { Write-Host " oApplicationDisplayInfo object Created"} else {Write-Host " oApplicationDisplayInfoo object Creation failed"~ exit}
 
 
$oApplicationDisplayInfo.Title            = $sApplicationName
$oApplicationDisplayInfo.Description      = $sApplicationDestription
$oApplicationDisplayInfo.Language         = "en-US"
$oApplication.DisplayInfo.DefaultLanguage = "en-US"
$oApplication.DisplayInfo.Add($oApplicationDisplayInfo)
 
 
$oAppinstaller = New-Object Microsoft.ConfigurationManagement.ApplicationManagement.ScriptInstaller
  if ($oAppinstaller -ne $null) { Write-Host " oAppinstaller object Created"} else {Write-Host " oAppinstaller object Creation failed"~ exit}
 
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
  if ($oEnhancedDetection -ne $null) { Write-Host " oEnhancedDetection object Created"} else {Write-Host " oEnhancedDetection object Creation failed"~ exit}
 
$oDetectionType              = [Microsoft.ConfigurationManagement.DesiredConfigurationManagement.ConfigurationItemPartType]::File
$oFileSetting                = New-Object Microsoft.ConfigurationManagement.DesiredConfigurationManagement.FileOrFolder( $oDetectionType , $null)
  if ($oFileSetting -ne $null) { Write-Host " oFileSetting object Created"} else {Write-Host " oFileSetting object Creation failed"~ exit}
 
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
if ($oSettingRef -ne $null) { Write-Host " oSettingRef object Created"} else {Write-Host " oSettingRef object Creation failed"~ exit}
 
 
$oSettingRef.MethodType    = [Microsoft.ConfigurationManagement.DesiredConfigurationManagement.ConfigurationItemSettingMethodType]::Value
$oConstValue               = New-Object Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.ConstantValue( 0, 
[Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.DataType]::Int64)
   if ($oConstValue -ne $null) { Write-Host " oConstValue object Created"} else {Write-Host " oConstValue object Creation failed"~ exit}
 
$oFileCheckOperands = new-object Microsoft.ConfigurationManagement.DesiredConfigurationManagement.CustomCollection``1[[Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.ExpressionBase]]
$oFileCheckOperands.Add($oSettingRef)
$oFileCheckOperands.Add($oConstValue)
 
$FileCheckExpression = new-object Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.Expression(
[Microsoft.ConfigurationManagement.DesiredConfigurationManagement.ExpressionOperators.ExpressionOperator]::NotEquals, $oFileCheckOperands)
 
$oRule              = new-object Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Rules.Rule("IsInstalledRule", 
[Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Rules.NoncomplianceSeverity]::None, $null, $FileCheckExpression)
   if ($oRule  -ne $null) { Write-Host " rule object Created"} else {Write-Host " rule object Creation failed"~ exit}
 
 
$oEnhancedDetection.Rule = $oRule 
$oAppinstaller.EnhancedDetectionMethod = $oEnhancedDetection
 
#####################################################
# Add Deployment Type to Application
 
 
Write-Host  "Adding Deployment Type"
$oApplicationDeploymentType = new-object Microsoft.ConfigurationManagement.ApplicationManagement.DeploymentType($oAppinstaller, 
[Microsoft.ConfigurationManagement.ApplicationManagement.ScriptInstaller]::TechnologyId, 
[Microsoft.ConfigurationManagement.ApplicationManagement.NativeHostingTechnology]::TechnologyId)
 
if ($oApplicationDeploymentType -ne $null) { Write-Host " NewApplicationDeploymentType object Created"} else {Write-Host " NewApplicationDeploymentType object Creation failed"~ exit}
 
 
$oApplicationDeploymentType.Title = $oApplication.Title 
 
#####################################################

#Write-Host "Limiting Collections to 64bit workstations"
 
$oOperands = select-object "Microsoft.ConfigurationManagement.DesiredConfigurationManagement.CustomCollection``1[[Microsoft.SystemsManagementServer.DesiredConfigurationManagement.Expressions.RuleExpression]]"
   ####if ($oOperands -ne $null) { Write-Host " oOperands object Created"} else {Write-Host " oOperands object Creation failed"~ exit}
 
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


#>
