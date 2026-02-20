# "Overall/Combined Checks" Remediation Script
}
    catch{$_.Exception.Message}
# "Overall/Combined Checks" Remediation Script

$OSArchitecture = Get-WmiObject -Class Win32_OperatingSystem | Select-Object OSArchitecture
$ErrorActionPreference = "Stop"

$list = '{
	"homepage": "http://thesource",
	"homepage_is_newtabpage": false,
	"browser": {
		"show_home_button": true,
		"check_default_browser": false
	},
	"bookmark_bar": {
		"show_on_all_tabs": true
	},
	"distribution": {
		"suppress_first_run_bubble": true,
		"show_welcome_page": false,
		"skip_first_run_ui": true,
		"import_history": false,
		"import_bookmarks": false,
		"import_bookmarks_from_file" : "",
		"import_home_page": true,
		"import_search_engine": false
	},
	"sync_promo": {
		"user_skipped": true
	},
	"first_run_tabs": [
		"http://thesource"
	]
}'

$filex64 = 'C:\Program Files (x86)\Google\Chrome\Application\master_preferences'
$filex86 = 'C:\Program Files\Google\Chrome\Application\master_preferences'

$GUFilex64 = 'C:\Program Files (x86)\Google\Update\GoogleUpdate.exe'
$GUFilex86 = 'C:\Program Files\Google\Update\GoogleUpdate.exe'

$DN1 = 'Google Update Service (gupdate)'
$Name1 = 'gupdate'

$DN2 = 'Google Update Service (gupdatem)'
$Name2 = 'gupdatem'

$RegPath1x64 = "HKLM:\SOFTWARE\Wow6432Node\Policies\Google\Chrome"
$RegPath2x64 = "HKLM:\SOFTWARE\Wow6432Node\Policies\Google\Chrome\Update"
$RegPath3x64 = "HKLM:\SOFTWARE\Wow6432Node\Policies\Google\Update"

$RegPath1x86 = "HKLM:\SOFTWARE\Policies\Google\Chrome"
$RegPath2x86 = "HKLM:\SOFTWARE\Policies\Google\Chrome\Update"
$RegPath3x86 = "HKLM:\SOFTWARE\Policies\Google\Update"

$RegPath4 = "HKLM:\SYSTEM\CurrentControlSet\services\gupdate"
$RegPath5 = "HKLM:\SYSTEM\CurrentControlSet\services\gupdatem"


# SET master_preferences
try
  {
    If (Test-Path 'C:\Program Files (x86)\Google\Chrome\Application')
    {
      New-Item -Path 'C:\Program Files (x86)\Google\Chrome\Application\master_preferences' -Force -ItemType File
      $list | Out-file 'C:\Program Files (x86)\Google\Chrome\Application\master_preferences' -Encoding ASCII -Force
    }
    If (Test-Path 'C:\Program Files\Google\Chrome\Application')
    {
      New-Item -Path 'C:\Program Files\Google\Chrome\Application\master_preferences' -Force -ItemType File
      $list | Out-file 'C:\Program Files\Google\Chrome\Application\master_preferences' -Encoding ASCII -Force
    }
}
catch{$_}


# RENAME GoogleUpdate.exe
if ((Test-Path $GUFilex64) -eq $True)
  {
  try
    {Rename-Item -NewName "$GUFilex64.xxx" -Path $GUFilex64 -Force}
  catch
    { $_.Exception.Message }
  }
else
  {}

if ((Test-Path $GUFilex86) -eq $True)
  {
  try
    {Rename-Item -NewName "$GUFilex86.xxx" -Path $GUFilex86 -Force}
  catch
    { $_.Exception.Message }
  }


# Stop/disable Google services
try
{
    if (Get-Service -DisplayName $DN1 -ErrorAction SilentlyContinue)
    {
        Stop-Service -DisplayName $DN1 -Force
        Set-Service -Name $Name1 -StartupType Disabled -Status Stopped
    }
}
Catch{$_.Exception.Message}

try
{
    if (Get-Service -DisplayName $DN2 -ErrorAction SilentlyContinue)
    {
        Stop-Service -DisplayName $DN2 -Force
        Set-Service -Name $Name2 -StartupType Disabled -Status Stopped
    }
}
Catch{$_.Exception.Message}


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
