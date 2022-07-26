$ADateS = Get-Date
$LogFolder = "D:\Powershell\!SCCM_PS_scripts\SCCM_PkgLib_Check_PowerShell7_Parallel"
  $DPsFile = "D:\Powershell\!SCCM_PS_scripts\SCCM_PkgLib_Check_PowerShell7_Parallel\DPs.txt"
 # Create C:\Temp if is doesn't exist
    If (!(Test-Path "$LogFolder")){New-Item -ItemType Directory -Path "$LogFolder" -Force | Out-Null}
#####################################################################################################################################
GoGo_SCCM_Module.ps1
$DPList = Get-CMDistributionPoint | Select-Object NetworkOsPath
$DPList = $DPList.NetworkOsPath | sort
$DPList | Out-File "$DPsFile"
#####################################################################################################################################
# FINALLY - Write Time
$ADateE = Get-Date
$t = NEW-TIMESPAN –Start $ADateS –End $ADateE | select Minutes,Seconds
$min = $t.Minutes
$sec = $t.seconds
Write-Host "`nPart1 ran for:" -nonewline
Write-Host "`t$min minutes and $sec seconds." -ForegroundColor Magenta