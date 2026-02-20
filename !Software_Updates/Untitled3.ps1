$DownloadPath = "D:\Projects\SCCM_Stuff\SCCM_Monthly_Application_Update_from_SoftwareUpdates"
Set-CMDeploymentType -ApplicationName <String> -InputObject <IResultObject> [-Priority <PriorityChangeType> {Decrease | Increase} ] [-Confirm] [-WhatIf] [ <CommonParameters>]
Parameter Set: SetByValuePriority
$DownloadPath = "D:\Projects\SCCM_Stuff\SCCM_Monthly_Application_Update_from_SoftwareUpdates"
$FolderLog = "$DownloadPath\Dirs.txt"
$NewFolders = Get-Content $FolderLog

$NewFolders = $NewFolders | sort -Unique



$File2 = Get-ChildItem "C:\Program Files (x86)\Adobe\*Reader*\Reader\AcroRd32.exe"
$File2.VersionInfo.ProductVersion


Remove-CMDeploymentType -ApplicationName "a_Fake_Application" -DeploymentTypeName 'Fake Install' -Force


$clause1 = New-CMDetectionClauseFile -ExpectedValue '17.011.30105' -ExpressionOperator 'GreaterEquals' -FileName 'AcroRd32.exe' -Path "%ProgramFiles%\Adobe\Acrobat Reader 2017\Reader" -PropertyType 'Version' -Value
Add-CMDeploymentType -ApplicationName "a_Fake_Application" `
-ContentLocation "\\SERVER\packages\Adobe_Acrobat\2017_Std\" `
-DeploymentTypeName "Fake Install" `
-InstallCommand "msiexec /i `"acropro.msi`" TRANSFORMS=AcroPro.mst ALLUSERS=1 REBOOT=REALLYSUPPRESS /l C:\Windows\Logs\Software\Acrobat2017Std.log /qn" `
-RebootBehavior "BasedOnExitCode" `
-UninstallCommand "msiexec /x {AC76BA86-1033-FFFF-7760-0E1108756300} /q" `
-AddDetectionClause ($clause1)


Add-CMDeploymentType -DeploymentTypeName "Fake Installer" -InstallationProgram "msiexec /i `"acropro.msi`" TRANSFORMS=AcroPro.mst ALLUSERS=1 REBOOT=REALLYSUPPRESS /l C:\Windows\Logs\Software\Acrobat2017Std.log /qn" -ApplicationName a_Fake_Application -ContentLocation \\SERVER\packages\Adobe_Acrobat\2017_Std\


$clause1 = New-CMDetectionClauseFile -ExpectedValue '17.011.30105' -ExpressionOperator 'GreaterEquals' -FileName 'AcroRd32.exe' -Path "%ProgramFiles%\Adobe\Acrobat Reader 2017\Reader" -PropertyType 'Version' -Value
# $app | Add-CMMsiDeploymentType -ContentLocation "\\myserver\mypath\mymsi.msi" -Force -AddDetectionClause ($clause1)


Add-CMDeploymentType -ContentLocation \\SERVER\packages\fake_Install_for_Testing\ -ApplicationName a_Fake_Application -DeploymentTypeName "Fake Install" -add

Set-CMDeploymentType -ApplicationName a_Fake_Application -DeploymentTypeName "Fake Install" -AdministratorComment "Fake Install for TS Testing" -ContentLocation \\SERVER\packages\fake_Install_for_Testing\ -NewDeploymentTypeName "Fakey Fake Install"


$clause1 = New-CMDetectionClauseFile -ExpectedValue '17.011.30105' -ExpressionOperator 'GreaterEquals' -FileName 'AcroRd32.exe' -Path "%ProgramFiles%\Adobe\Acrobat Reader 2017\Reader" -PropertyType 'Version' -Value
$app | Add-CMMsiDeploymentType -ContentLocation "\\myserver\mypath\mymsi.msi" -Force -AddDetectionClause ($clause1)


gwmi -computer $computer Win32_ComputerSystem
$BIOS = Get-WmiObject -ComputerName $Computer -Class Win32_BIOS


($BIOS.ConvertToDateTime($BIOS.releasedate).ToShortDateString())


Parameter Set: SetByIdPriority
Set-CMDeploymentType -ApplicationName <String> -DeploymentTypeId <String> [-Priority <PriorityChangeType> {Decrease | Increase} ] [-Confirm] [-WhatIf] [ <CommonParameters>]

Parameter Set: SetByNamePriority
Set-CMDeploymentType -ApplicationName <String> -DeploymentTypeName <String> [-Priority <PriorityChangeType> {Decrease | Increase} ] [-Confirm] [-WhatIf] [ <CommonParameters>]

Parameter Set: SetByNamePropertyAppV5xInstaller
Set-CMDeploymentType -ApplicationName <String> -AppV5xInstaller -DeploymentTypeName <String> [-AdministratorComment <String> ] [-AllowClientsToUseFallbackSourceLocationForContent <Boolean> ] [-ContentLocation <String> ] [-EnablePeertoPeerContentDistribution <Boolean> ] [-Language <String[]> ] [-NewDeploymentTypeName <String> ] [-OnFastNetworkMode <OnFastNetworkMode> {RunFromNetwork | RunLocal} ] [-OnSlowNetworkMode <ContentHandlingMode> {DoNothing | Download | DownloadContentForStreaming} ] [-PersistContentInClientCache <Boolean> ] [-Confirm] [-WhatIf] [ <CommonParameters>]

Parameter Set: SetByNamePropertyAppVInstaller
Set-CMDeploymentType -ApplicationName <String> -AppVInstaller -DeploymentTypeName <String> [-AdministratorComment <String> ] [-AllowClientsToUseFallbackSourceLocationForContent <Boolean> ] [-ContentLocation <String> ] [-EnablePeertoPeerContentDistribution <Boolean> ] [-Language <String[]> ] [-LoadContentIntoAppVcacheBeforelaunch <Boolean> ] [-NewDeploymentTypeName <String> ] [-OnFastNetworkMode <OnFastNetworkMode> {RunFromNetwork | RunLocal} ] [-OnSlowNetworkMode <ContentHandlingMode> {DoNothing | Download | DownloadContentForStreaming} ] [-PersistContentInClientCache <Boolean> ] [-Confirm] [-WhatIf] [ <CommonParameters>]

Parameter Set: SetByNamePropertyDeepLinkInstaller
Set-CMDeploymentType -ApplicationName <String> -DeepLinkInstaller -DeploymentTypeName <String> [-AdministratorComment <String> ] [-ApplicationNameInWindowsStore <String> ] [-Language <String[]> ] [-NewDeploymentTypeName <String> ] [-RemoteComputerName <String> ] [-Confirm] [-WhatIf] [ <CommonParameters>]

Parameter Set: SetByNamePropertyMacInstaller
Set-CMDeploymentType -ApplicationName <String> -DeploymentTypeName <String> -MacInstaller [-AdministratorComment <String> ] [-ContentLocation <String> ] [-InstallationProgram <String> ] [-Language <String[]> ] [-MacRebootBehavior <MacRebootBehavior> {ForceReboot | NoAction} ] [-NewDeploymentTypeName <String> ] [-Confirm] [-WhatIf] [ <CommonParameters>]

Parameter Set: SetByNamePropertyMsiConfigureRule
Set-CMDeploymentType -ApplicationName <String> -DeploymentTypeName <String> -MsiOrScriptInstaller [-AdministratorComment <String> ] [-AllowClientsToShareContentOnSameSubnet <Boolean> ] [-AllowClientsToUseFallbackSourceLocationForContent <Boolean> ] [-ContentLocation <String> ] [-DetectDeploymentTypeByCustomScript] [-EstimatedInstallationTimeMinutes <Int32> ] [-InstallationBehaviorType <InstallationBehaviorType> {InstallForSystem | InstallForSystemIfResourceIsDeviceOtherwiseInstallForUser | InstallForUser} ] [-InstallationProgram <String> ] [-InstallationProgramVisibility <UserInteractionMode> {Normal | Minimized | Maximized | Hidden} ] [-InstallationStartIn <String> ] [-Language <String[]> ] [-LogonRequirementType <LogonRequirementType> {OnlyWhenNoUserLoggedOn | OnlyWhenUserLoggedOn | WhereOrNotUserLoggedOn | WhetherOrNotUserLoggedOn} ] [-MaximumAllowedRunTimeMinutes <Int32> ] [-NewDeploymentTypeName <String> ] [-OnSlowNetworkMode <ContentHandlingMode> {DoNothing | Download | DownloadContentForStreaming} ] [-PersistContentInClientCache <Boolean> ] [-ProductCode <String> ] [-RebootBehavior <RebootBehavior> {BasedOnExitCode | ForceReboot | NoAction | ProgramReboot} ] [-RequiresUserInteraction <Boolean> ] [-RunInstallationAndUninstallProgramAs32bitProcessOn64bitClient <Boolean> ] [-RunScriptAs32bitProcessOn64bitClient <Boolean> ] [-ScriptContent <String> ] [-ScriptType <ScriptLanguage> ] [-UninstallProgram <String> ] [-UninstallStartIn <String> ] [-Confirm] [-WhatIf] [ <CommonParameters>]

Parameter Set: SetByNamePropertyOtherInstaller
Set-CMDeploymentType -ApplicationName <String> -DeploymentTypeName <String> [-AdministratorComment <String> ] [-ContentLocation <String> ] [-Language <String[]> ] [-NewDeploymentTypeName <String> ] [-Confirm] [-WhatIf] [ <CommonParameters>]

Parameter Set: SetByNamePropertyWebAppInstaller
Set-CMDeploymentType -ApplicationName <String> -DeploymentTypeName <String> -WebAppInstaller [-AdministratorComment <String> ] [-Language <String[]> ] [-NewDeploymentTypeName <String> ] [-Confirm] [-WhatIf] [ <CommonParameters>]

Parameter Set: SetByNamePropertyWindows8Installer
Set-CMDeploymentType -ApplicationName <String> -DeploymentTypeName <String> -Windows8AppInstaller [-AdministratorComment <String> ] [-AllowClientsToShareContentOnSameSubnet <Boolean> ] [-AllowClientsToUseFallbackSourceLocationForContent <Boolean> ] [-ContentLocation <String> ] [-Language <String[]> ] [-MaximumAllowedRunTimeMinutes <Int32> ] [-NewDeploymentTypeName <String> ] [-OnSlowNetworkMode <ContentHandlingMode> {DoNothing | Download | DownloadContentForStreaming} ] [-PersistContentInClientCache <Boolean> ] [-TriggerVPN <Boolean> ] [-Confirm] [-WhatIf] [ <CommonParameters>]

Parameter Set: SetByNamePropertyWmInstaller
Set-CMDeploymentType -ApplicationName <String> -DeploymentTypeName <String> -WMInstaller [-AdministratorComment <String> ] [-AllowUserToUninstall <Boolean> ] [-ContentLocation <String> ] [-Language <String[]> ] [-NewDeploymentTypeName <String> ] [-Confirm] [-WhatIf] [ <CommonParameters>]

Parameter Set: SetByValuePriority
Set-CMDeploymentType -ApplicationName <String> -InputObject <IResultObject> [-Priority <PriorityChangeType> {Decrease | Increase} ] [-Confirm] [-WhatIf] [ <CommonParameters>]
