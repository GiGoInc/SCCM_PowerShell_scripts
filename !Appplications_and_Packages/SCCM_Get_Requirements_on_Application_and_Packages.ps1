# STATIC INFO
Set-Location C:
Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
# STATIC INFO
$siteCode = "XX1"
$siteServer = "SERVER.DOMAIN.COM"
$OSReqsPairs = 'All Windows 10 (32-bit),Windows/All_x86_Windows_10_and_higher_Clients', `
              'All Windows 10 (64-bit),Windows/All_x64_Windows_10_and_higher_Clients', `
              'All Windows 10 (ARM64),Windows/All_ARM64_Windows_10_and_higher_Clients', `
              'All Windows 10 Enterprise multi-session,Windows/All_MultiSession_Enterprise_Windows_10_higher', `
              'All Windows 11 (64-bit),Windows/All_x64_Windows_11_and_higher_Clients', `
              'All Windows 11 (ARM64),Windows/All_ARM64_Windows_11_and_higher_Clients', `
              'All Windows 11 Enterprise multi-session,Windows/All_MultiSession_Enterprise_Windows_11_higher', `
              'All Windows Server 2003 (Non-R2) (32-bit),Windows/All_x86_Windows_Server_2003_Non_R2', `
              'All Windows Server 2003 (Non-R2) (64-bit),Windows/All_x64_Windows_Server_2003_Non_R2', `
              'All Windows Server 2003 R2 (32-bit),Windows/All_x86_Windows_Server_2003_R2', `
              'All Windows Server 2003 R2 (64-bit),Windows/All_x64_Windows_Server_2003_R2', `
              'All Windows Server 2008 (32-bit),Windows/All_x86_Windows_Server_2008', `
              'All Windows Server 2008 (Non-R2) (64-bit),Windows/All_x64_Windows_Server_2008', `
              'All Windows Server 2008 R2 (64-bit),Windows/All_x64_Windows_Server_2008_R2', `
              'All Windows Server 2012 (64-bit),Windows/All_x64_Windows_Server_8', `
              'All Windows Server 2012 R2 (64-bit),Windows/All_x64_Windows_Server_2012_R2', `
              'All Windows Server 2016 and higher (64-bit),Windows/All_x64_Windows_Server_2016', `
              'All Windows Server 2019 and higher (64-bit),Windows/All_x64_Windows_Server_2019_and_higher', `
              'All Windows Server 2022 and higher (64-bit),Windows/All_x64_Windows_Server_2022_and_higher', `
              'Windows Server 2003 R2 SP2 (32-bit),Windows/x86_Windows_Server_2003_R2_SP2', `
              'Windows Server 2003 R2 SP2 (64-bit),Windows/x64_Windows_Server_2003_R2_SP2', `
              'Windows Server 2003 SP2 (32-bit),Windows/x86_Windows_Server_2003_SP2', `
              'Windows Server 2003 SP2 (64-bit),Windows/x64_Windows_Server_2003_SP2', `
              'Windows Server 2008 R2 (64-bit),Windows/x64_Windows_Server_2008_R2', `
              'Windows Server 2008 R2 Core (64-bit),Windows/x64_Windows_Server_2008_R2_CORE', `
              'Windows Server 2008 R2 SP1 (64-bit),Windows/x64_Windows_Server_2008_R2_SP1', `
              'Windows Server 2008 R2 SP1 Core (64-bit),Windows/x64_Windows_Server_2008_R2_SP1_Core', `
              'Windows Server 2008 SP2 (32-bit),Windows/x86_Windows_Server_2008_SP2', `
              'Windows Server 2008 SP2 (64-bit),Windows/x64_Windows_Server_2008_SP2', `
              'Windows Server 2008 SP2 Core (64-bit),Windows/x64_Windows_Server_2008_SP2_Core'


############################################################################################
############################################################################################

$SiteCode = "XX1"
$SiteServer = "SERVER.DOMAIN.COM"
$SCCMPaths = 'C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin\ConfigurationManager.psd1', "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"            
$SCCMPaths | % { If (Test-Path "$_") { Import-Module "$_"  -Force }}
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
New-PSDrive -name $SiteCode -psprovider CMSite  -Root $SiteServer }
Set-Location "$($SiteCode):\"

$LogFile = "D:\Powershell\!SCCM_PS_scripts\!Appplications_and_Packages\SCCM_Get_New_OS_Requirements_on_Application_DeploymentTypes.csv"
"Count,Application or Package,App/Package Name,App/PKG ID,App DeploymentType Count,Install Name,Application Install Type,Install Requirements,Column2,Column7,Column8" | Set-Content $LogFile
############################################################################################
############################################################################################
# VARIABLES

$OSReqs = 'All Windows 11 (64-bit)'

############################################################################################
############################################################################################

# CHECK APPLICATION(s)
    $SDate = (GET-DATE)
    Write-Host "Reading all Apps to Variable. Wait several minutes to complete..." -ForegroundColor Yellow
    $AApps = Get-CMApplication
    Write-Host "Done..." -ForegroundColor Green
    $EDate = (GET-DATE)
    $Span = NEW-TIMESPAN –Start $SDate –End $EDate
    $Min = $Span.minutes
    $Sec = $Span.Seconds
    Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan

# CHECK PACKAGE(s)
    $SDate = (GET-DATE)
    Write-Host "Reading all Packages to Variable. Wait several minutes to complete..." -ForegroundColor Yellow
    $PApps = Get-CMProgram
    Write-Host "Done..." -ForegroundColor Green
    $EDate = (GET-DATE)
    $Span = NEW-TIMESPAN –Start $SDate –End $EDate
    $Min = $Span.minutes
    $Sec = $Span.Seconds
    Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
############################################################################################

$i = 1
$SDate = (GET-DATE)
Write-Host "Checking $($AApps.count) Applications for Requirements..." -ForegroundColor Yellow
ForEach ($appdt in $AApps)
{ 
      $xml = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($appdt.SDMPackageXML,$True)
    
    $appLDName = $appdt.LocalizedDisplayName
        $appID = $appdt.CI_ID
       $numDTS = $xml.DeploymentTypes.count
     $dtsTitle = $xml.DeploymentTypes.Title
 $dtsInstaller = $xml.DeploymentTypes.Installer.Technology
      $dtsReqs = $xml.DeploymentTypes.Requirements.Name

    [string]$i + ',Application,' + $appLDName + ',' + $appID + ',' + $numDTS + ',"' + $dtsTitle + '",' + $dtsInstaller + ',"' + $dtsReqs + '"' | Add-Content $LogFile
    $i++
}
$EDate = (GET-DATE)
$Span = NEW-TIMESPAN –Start $SDate –End $EDate
$Min = $Span.minutes
$Sec = $Span.Seconds
Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan

############################################################################################
############################################################################################

$Progs = @()
$SDate = (GET-DATE)
Write-Host "Checking $($PApps.count) Packages for Requirements.." -ForegroundColor Yellow
ForEach ($Prog in $PApps)
{

       $ProgName = $Prog.ProgramName
         $PackID = $Prog.PackageID
    $PackageName = $Prog.PackageName
            $SOS = $Prog.SupportedOperatingSystems.Name
         $SOSMin = $Prog.SupportedOperatingSystems.MinVersion
         $SOSMax = $Prog.SupportedOperatingSystems.MaxVersion
        $SOSName = $Prog.SupportedOperatingSystems.Name
        $SOSPlat = $Prog.SupportedOperatingSystems.Platform   
        $AllowTs = $Prog.ProgramFlags -band [math]::pow(0,0)

        If (($SOS -match 'Win NT') -and ($SOSMin -match '6.10.0000.0') -and ($SOSMax -match '6.10.9999.9999') -and ($SOSPlat -match 'x64')) { $SOS += ' All Windows 7 (64-bit)' }
        If (($SOS -match 'Win NT') -and ($SOSMin -match '6.10.7601.0') -and ($SOSMax -match '6.10.9999.9999') -and ($SOSPlat -match 'x64')) { $SOS += ' Windows 7 SP1 (64-bit)' }
        If (($SOS -match 'Win NT') -and ($SOSMin -match '6.10.0000.0') -and ($SOSMax -match '6.10.9999.9999') -and ($SOSPlat -match 'I386')) { $SOS += ' All Windows 7 (32-bit)' }
        If (($SOS -match 'Win NT') -and ($SOSMin -match '6.10.7601.0') -and ($SOSMax -match '6.10.9999.9999') -and ($SOSPlat -match 'I386')) { $SOS += ' Windows 7 SP1 (32-bit)' }
        If (($SOS -match 'Win NT') -and ($SOSMin -match '10.00.0000.0') -and ($SOSMax -match '10.00.19999.9999') -and ($SOSPlat -match 'x64')) { $SOS += ' All Windows 10 (64-bit)' }
        If (($SOS -match 'Win NT') -and ($SOSMin -match '10.00.22000.0') -and ($SOSMax -match '10.00.99999.9999') -and ($SOSPlat -match 'x64')) { $SOS += ' All Windows 11 (64-bit)' }

    If ($SOS -eq '')
    {
        [string]$i + ',Package,' + $PackageName + ',' + $PackID + ',,' + $ProgName + ',,No OS Requirements,,,' + $AllowTs | Add-Content $LogFile
    }
    Else
    {
        [string]$i + ',Package,' + $PackageName + ',' + $PackID + ',,' + $ProgName + ',,' + $SOS + ',' + $SOSMin + ',' + $SOSMax + ',' + $SOSName + ',' + $SOSPlat + ',' + $AllowTs | Add-Content $LogFile
    }
    $i++
}
$EDate = (GET-DATE)
$Span = NEW-TIMESPAN –Start $SDate –End $EDate
$Min = $Span.minutes
$Sec = $Span.Seconds
Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
Set-Location C:
