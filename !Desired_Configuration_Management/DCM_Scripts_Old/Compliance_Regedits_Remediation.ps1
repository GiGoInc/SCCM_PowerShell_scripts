# "Registry" Remediation Script
}
    catch{$_.Exception.Message}
# "Registry" Remediation Script

$OSArchitecture = Get-WmiObject -Class Win32_OperatingSystem | Select-Object OSArchitecture

$RegPath1x64 = "HKLM:\SOFTWARE\Wow6432Node\Policies\Google\Chrome"
$RegPath2x64 = "HKLM:\SOFTWARE\Wow6432Node\Policies\Google\Chrome\Update"
$RegPath3x64 = "HKLM:\SOFTWARE\Wow6432Node\Policies\Google\Update"

$RegPath1x86 = "HKLM:\SOFTWARE\Policies\Google\Chrome"
$RegPath2x86 = "HKLM:\SOFTWARE\Policies\Google\Chrome\Update"
$RegPath3x86 = "HKLM:\SOFTWARE\Policies\Google\Update"

$RegPath4 = "HKLM:\SYSTEM\CurrentControlSet\services\gupdate"
$RegPath5 = "HKLM:\SYSTEM\CurrentControlSet\services\gupdatem"




# SET REGISTRY
If($OSArchitecture.OSArchitecture -eq "64-bit")
{
    try
    {
        If (((Test-Path 'C:\Program Files (x86)\Google\Chrome\Application') -and (!(Test-Path $RegPath1x64)))){New-Item $RegPath1x64 -Force}
        If (((Test-Path 'C:\Program Files (x86)\Google\Chrome\Application') -and (!(Test-Path $RegPath2x64)))){New-Item $RegPath2x64 -Force}
        If (((Test-Path 'C:\Program Files (x86)\Google\Chrome\Application') -and (!(Test-Path $RegPath3x64)))){New-Item $RegPath3x64 -Force}
		If ((test-path $RegPath1x64) -eq $true)
			{
				Set-ItemProperty $RegPath1x64 -Name 'BookmarkBarEnabled' -Type DWORD -Value '1' -Force
				Set-ItemProperty $RegPath1x64 -Name 'DefaultBrowserSettingEnabled' -Type DWORD -Value '0' -Force
				Set-ItemProperty $RegPath1x64 -Name 'DefaultGeolocationSetting' -Type DWORD -Value '2' -Force
				Set-ItemProperty $RegPath1x64 -Name 'DnsPrefetchingEnabled' -Type DWORD -Value '0' -Force
				Set-ItemProperty $RegPath1x64 -Name 'HomepageLocation' -Type String -Value 'http://thesource/' -Force
				Set-ItemProperty $RegPath1x64 -Name 'MetricsReportingEnabled' -Type DWORD -Value '0' -Force
				Set-ItemProperty $RegPath1x64 -Name 'RestoreOnStartupURLs\' -Type STRING -Value 'http://thesource/' -Force
				Set-ItemProperty $RegPath1x64 -Name 'SearchSuggestEnabled' -Type DWORD -Value '0' -Force
				Set-ItemProperty $RegPath1x64 -Name 'ShowHomeButton' -Type DWORD -Value '1' -Force
				Set-ItemProperty $RegPath1x64 -Name 'SyncDisabled' -Type DWORD -Value '1' -Force
			}
		if ((test-path $RegPath2x64) -eq $true)
		{
			Set-ItemProperty $RegPath2x64 -Name 'UpdateDefault' -Type DWORD -Value '0' -Force
		}
		if ((test-path $RegPath3x64) -eq $true)
		{
			Set-ItemProperty $RegPath3x64 -Name 'AutoUpdateCheckPeriodMinutes' -Type DWORD -Value '0' -Force	
		}
		if ((test-path $RegPath4) -eq $true)
		{
			Set-ItemProperty $RegPath4 -Name 'Start' -Type DWORD -Value '4'
		}
		if ((test-path $RegPath5) -eq $true)
		{
			Set-ItemProperty $RegPath5 -Name 'Start' -Type DWORD -Value '4'	
		}
	}
    Catch{$_.Exception.Message}
}
ElseIf($OSArchitecture.OSArchitecture -eq "32-bit")
{
    try
    {
        If (((Test-Path 'C:\Program Files\Google\Chrome\Application') -and (!(Test-Path $RegPath1x86)))){New-Item $RegPath1x86 -Force}
        If (((Test-Path 'C:\Program Files\Google\Chrome\Application') -and (!(Test-Path $RegPath2x86)))){New-Item $RegPath2x86 -Force}
        If (((Test-Path 'C:\Program Files\Google\Chrome\Application') -and (!(Test-Path $RegPath3x86)))){New-Item $RegPath3x86 -Force}
		if ((test-path $RegPath1x86) -eq $true)
			{
				Set-ItemProperty $RegPath1x86 -Name 'BookmarkBarEnabled' -Type DWORD -Value '1' -Force
				Set-ItemProperty $RegPath1x86 -Name 'DefaultBrowserSettingEnabled' -Type DWORD -Value '0' -Force
				Set-ItemProperty $RegPath1x86 -Name 'DefaultGeolocationSetting' -Type DWORD -Value '2' -Force
				Set-ItemProperty $RegPath1x86 -Name 'DnsPrefetchingEnabled' -Type DWORD -Value '0' -Force
				Set-ItemProperty $RegPath1x86 -Name 'HomepageLocation' -Type String -Value 'http://thesource/' -Force
				Set-ItemProperty $RegPath1x86 -Name 'MetricsReportingEnabled' -Type DWORD -Value '0' -Force
				Set-ItemProperty $RegPath1x86 -Name 'RestoreOnStartupURLs\' -Type STRING -Value 'http://thesource/' -Force
				Set-ItemProperty $RegPath1x86 -Name 'SearchSuggestEnabled' -Type DWORD -Value '0' -Force
				Set-ItemProperty $RegPath1x86 -Name 'ShowHomeButton' -Type DWORD -Value '1' -Force
				Set-ItemProperty $RegPath1x86 -Name 'SyncDisabled' -Type DWORD -Value '1' -Force
			}
		if ((test-path $RegPath2x86) -eq $true)
		{
			Set-ItemProperty $RegPath2x86 -Name 'UpdateDefault' -Type DWORD -Value '0' -Force
		}
		if ((test-path $RegPath3x86) -eq $true)
		{
			Set-ItemProperty $RegPath3x64 -Name 'AutoUpdateCheckPeriodMinutes' -Type DWORD -Value '0' -Force	
		}
		if ((test-path $RegPath4) -eq $true)
		{
			Set-ItemProperty $RegPath4 -Name 'Start' -Type DWORD -Value '4'
		}
		if ((test-path $RegPath5) -eq $true)
		{
			Set-ItemProperty $RegPath5 -Name 'Start' -Type DWORD -Value '4'	
		}
    }
    catch{$_.Exception.Message}
}
