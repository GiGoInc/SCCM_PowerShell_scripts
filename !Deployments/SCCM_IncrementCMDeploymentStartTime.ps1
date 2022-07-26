Param(            
    [parameter(Mandatory=$true)]            
    $SiteCode
    )

Write-Output "SCCM 2012 SP1 Deadline Time Increment Script"
Write-Output "Version 1.0"
Write-Output "Parameters"
Write-Output "  SiteCode: "$SiteCode -ForegroundColor Green

function GetCMSiteConnection
{
  param ($siteCode)

  $CMModulePath = Join-Path -Path (Split-Path -Path "${Env:SMS_ADMIN_UI_PATH}" -ErrorAction Stop) -ChildPath "ConfigurationManager.psd1"
  Import-Module $CMModulePath -ErrorAction Stop
  $CMProvider = Get-PSDrive -PSProvider CMSite -Name $siteCode -ErrorAction Stop
  CD "$($CMProvider.SiteCode):\"
  return $CMProvider
}

#Main

#Connect to SCCM, must have SCCM Admin Console installed for this to work
#If this fails then connect with the console to the site you want to use, then open PowerShell from that console
$CM = GetCMSiteConnection -siteCode $SiteCode
Write-Output "Connected to:" $CM.SiteServer
Write-Output 
Write-Output "---Updating Deployments---"

foreach ($Deployment in (Get-CMDeployment))
{
  if (($Deployment.EnforcementDeadline -lt (Get-Date).ToUniversalTime()) -and ($Deployment.EnforcementDeadline -ne $null))
  {
    Set-CMApplicationDeployment -Application (Get-CMApplication -Id $Deployment.CI_ID) -CollectionName $Deployment.CollectionName -DeadlineDate ($Deployment.EnforcementDeadline).AddMinutes(1) -DeadlineTime ($Deployment.EnforcementDeadline).AddMinutes(1)
    Write-Output "  "$Deployment.AssignmentID"CI Deadline Updated" -ForegroundColor Green
  }
  else
  {
    Write-Output "  "$Deployment.AssignmentID"CI Skipped, deadline time occurs in the future or not specified" -ForegroundColor Red
  }
}