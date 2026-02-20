Import-Module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')
#>

Import-Module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')
Set-Location -Path "$(Get-PSDrive -PSProvider CMSite):\" -ErrorAction Stop

# Get all valid packages from the primary site server
$Namespace = "root\SMS\Site_" + $SiteCode

# UPDATE THESE VARIABLES FOR YOUR ENVIRONMENT
[string]$SiteCode = 'XX1'

############################################################################################################################
[string]$SiteServer = 'SERVER.DOMAIN.COM'
############################################################################################################################


$TimeNow = Date
$TimeInTen = $TimeNow.AddMinutes(1)
$ValidationSchedule = New-CMSchedule -Start $TimeInTen -DayOfWeek $($TimeNow.DayOfWeek)
Set-CMDistributionPoint -SiteCode $SiteCode -SiteSystemServerName $SiteServer -ValidateContentSchedule $ValidationSchedule
Write-Host "`nValidation schedule changed to " -NoNewline -ForegroundColor Red
Write-Host "$($ValidationSchedule.StartTime) " -NoNewline -ForegroundColor Yellow
Write-Host "on " -NoNewline -ForegroundColor Red 
Write-Host "$($SiteServer)`n" -ForegroundColor Yellow

<#
	Here’s a quick list of the package status codes when distributing content to Distribution Points.

	0 - PKG_STATUS_NONE
	1 - PKG_STATUS_SENT
	2 - PKG_STATUS_RECEIVED
	3 - PKG_STATUS_INSTALLED
	4 - PKG_STATUS_RETRY
	5 - PKG_STATUS_FAILED
	6 - PKG_STATUS_REMOVED
	7 - PKG_STATUS_PENDING_REMOVE // Not used.
	8 - PKG_STATUS_REMOVE_FAILED
	9 - PKG_STATUS_RETRY_REMOVE
#>


<# RESET TO SUNDAY AT 5AM
    $ValidationSchedule2 = New-CMSchedule -Start '05:00:00' -DayOfWeek Sunday
    Set-CMDistributionPoint -SiteCode $SiteCode -SiteSystemServerName $SiteServer -ValidateContentSchedule $ValidationSchedule2
    Write-Host "`nValidation schedule changed to " -NoNewline -ForegroundColor Red
    Write-Host "$($ValidationSchedule2.StartTime) " -NoNewline -ForegroundColor Yellow
    Write-Host "on " -NoNewline -ForegroundColor Red 
    Write-Host "$($SiteServer)`n" -ForegroundColor Yellow
#>

<#
    D:\Powershell\!SCCM_PS_scripts\!DPs\Repair_DP_Content_Library_Inconsistencies.ps1
        Getting package list from PkgLib on SERVER ... 26 packages found.
        Refreshing WMI package list from SERVER ... 51 packages found.
        Number of invalid packages exceeds threshold [26 invalid].
        Warning: Proceed with removing invalid PkgLib packages on SERVER?
        Yes or No: yes
        Removing invalid package XX100118 from PkgLib on SERVER -Done
        Removing invalid package XX100185 from PkgLib on SERVER -Done
        Removing invalid package XX100200 from PkgLib on SERVER -Done
        Removing invalid package XX1004A1 from PkgLib on SERVER -Done
        Removing invalid package XX1004A2 from PkgLib on SERVER -Done
        Removing invalid package XX100520 from PkgLib on SERVER -Done
        Removing invalid package XX100580 from PkgLib on SERVER -Done
        Removing invalid package XX100581 from PkgLib on SERVER -Done
        Removing invalid package XX1005A0 from PkgLib on SERVER -Done
        Removing invalid package XX1005AD from PkgLib on SERVER -Done
        Removing invalid package XX1005C6 from PkgLib on SERVER -Done
        Removing invalid package XX1005C7 from PkgLib on SERVER -Done
        Removing invalid package XX1005C9 from PkgLib on SERVER -Done
        Removing invalid package XX1005D6 from PkgLib on SERVER -Done
        Removing invalid package XX1005DE from PkgLib on SERVER -Done
        Removing invalid package XX1005FE from PkgLib on SERVER -Done
        Removing invalid package XX100605 from PkgLib on SERVER -Done
        Removing invalid package XX10060A from PkgLib on SERVER -Done
        Removing invalid package XX10060B from PkgLib on SERVER -Done
        Removing invalid package XX10060C from PkgLib on SERVER -Done
        Removing invalid package XX10060D from PkgLib on SERVER -Done
        Removing invalid package XX100611 from PkgLib on SERVER -Done
        Removing invalid package XX100633 from PkgLib on SERVER -Done
        Removing invalid package XX100634 from PkgLib on SERVER -Done
        Removing invalid package XX100638 from PkgLib on SERVER -Done
        Removing invalid package XX10064E from PkgLib on SERVER -Done
Still shows 102 failed 102 packages of 137, 35 ok
    D:\Powershell\!SCCM_PS_scripts\!DPs\Reschedule_Content_Validation_on_DP.ps1
#>

<#################################
    D:\Powershell\!SCCM_PS_scripts\!DPs\Remove_Unknown_Content_from_DP.ps1
        Found 102 failed packages

        DP                      PackageId Action 
        --                      --------- ------ 
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed
        SERVER.DOMAIN.COM XX123456  Removed

Removed 102 failed packages of 137, 35 remaining
    D:\Powershell\!SCCM_PS_scripts\!DPs\Reschedule_Content_Validation_on_DP.ps1
        Validation schedule changed to 06/25/2019 13:46:13 on SERVER.DOMAIN.COM


#>
