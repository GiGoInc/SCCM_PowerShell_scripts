############################################################################################
           

############################################################################################
############################################################################################

$SiteCode = "XX1"
$SiteServer = "SERVER.DOMAIN.COM"
$SCCMPaths = 'C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin\ConfigurationManager.psd1', "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"            
$SCCMPaths | % { If (Test-Path "$_") { Import-Module "$_"  -Force }}
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
New-PSDrive -name $SiteCode -psprovider CMSite  -Root $SiteServer }
Set-Location "$($SiteCode):\"

############################################################################################


$Output = @()
$Output += "SmsProviderObjectPath," + `
           "BoundaryFlags," + `
           "BoundaryID," + `
           "BoundaryType," + ` 
           "CreatedBy," + `
           "CreatedOn," + `
           "DefaultSiteCode," + ` 
           "DisplayName," + `
           "GroupCount," + `
           "ModifiedBy," + `
           "ModifiedOn," + `
           "SiteSystems," + `
           "Value"

$Boundaries = Get-CMBoundary
ForEach ($Boundary in $Boundaries)
{
$Output += '"' + $Boundary.SmsProviderObjectPath + '",' + `
           '"' + $Boundary.BoundaryFlags + '",' + ` 
           '"' + $Boundary.BoundaryID + '",' + ` 
           '"' + $Boundary.BoundaryType + '",' + ` 
           '"' + $Boundary.CreatedBy + '",' + ` 
           '"' + $Boundary.CreatedOn + '",' + ` 
           '"' + $Boundary.DefaultSiteCode + '",' + ` 
           '"' + $Boundary.DisplayName + '",' + ` 
           '"' + $Boundary.GroupCount + '",' + ` 
           '"' + $Boundary.ModifiedBy + '",' + ` 
           '"' + $Boundary.ModifiedOn + '",' + ` 
           '"' + $Boundary.SiteSystems + '",' + ` 
           '"' + $Boundary.Value + '"'    
}
$output | Set-Content "D:\Powershell\!SCCM_PS_scripts\!Boundary_Groups\Get_Boundaries_Info--Results.csv"

           
