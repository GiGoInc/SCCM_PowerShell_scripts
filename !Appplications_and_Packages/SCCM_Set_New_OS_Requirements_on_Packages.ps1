# STATIC INFO
Set-Location c:
}
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
New-PSDrive -name $SiteCode -psprovider CMSite  -Root $SiteServer 
}
Set-Location "$($SiteCode):\"

############################################################################################
############################################################################################
# VARIABLES

$Packages = 'Rename Computer'

$OSReqs = 'All Windows 11 (64-bit) Client'

############################################################################################
############################################################################################

# SET PACKAGE(s)
$Progs = @() 
ForEach ($Prog in Get-CMProgram)
{
    $PackageName = $Prog.PackageName
    ForEach ($PN in $Packages)
    {
        If ($PackageName -eq $PN)
        {
               $ProgName = $Prog.ProgramName
              $PackageID = $Prog.PackageID
                    $SOS = $Prog.SupportedOperatingSystems
                 $SOSMin = $Prog.SupportedOperatingSystems.MinVersion
                 $SOSMax = $Prog.SupportedOperatingSystems.MaxVersion
                $SOSName = $Prog.SupportedOperatingSystems.Name
                $SOSPlat = $Prog.SupportedOperatingSystems.Platform   
                $AllowTs = $Prog.ProgramFlags -band [math]::pow(0,0)

            $OS = Get-CMSupportedPlatform -Name $OSReqs -Fast
            "$PackageID -- $PackageName -- $ProgName -- $($OS.OSMinVersion)"
            Set-CMProgram -PackageID $PackageID -ProgramName $ProgName -AddSupportedOperatingSystemPlatform $OS -StandardProgram
        }
    }
}
Set-Location c:
