# $SiteCode = "XX1"
$Deployment.Put()
$Deployment.UseGMTTimes                     = $true
# $SiteCode = "XX1"
$ADate = Get-Date -UFormat "%Y/%m/%d"
$ATime = Get-Date -UFormat "%R"
$CollName = "Test - SuperUser's VMs"
$CollID = "XX100176"
$AppName = "Dymo Labels"
$DAction = "Install"
$Comm = "Deployment from POWERSHELL to $CollName of $AppName"


$DeploymentClass = [wmiclass] "\\localhost\root\sms\site_$($SiteCode):SMS_ApplicationAssignment"

$Deployment = $DeploymentClass.CreateInstance()
$Deployment.ApplicationName                 = $AppName
$Deployment.AssignmentName                  = "Deploy $AppName"
$Deployment.AssignedCIs                     = 16781957
$Deployment.CollectionName                  = $CollName
$Deployment.DesiredConfigType               = 2 # 1 means install, 2 means uninstall
$Deployment.LocaleID                        = 1043
$Deployment.NotifyUser                      = $true
$Deployment.OfferTypeID                     = 2 # 0 means required, 2 means available
$Deployment.OverrideServiceWindows          = $false
$Deployment.RebootOutsideOfServiceWindows   = $false
$Deployment.SourceSite                      = "PRI"
$Deployment.StartTime                       = "20131001120000.000000+***"
$Deployment.SuppressReboot                  = $true
$Deployment.TargetCollectionID              = $CollID   # CollectionID where to deploy it to
$Deployment.WoLEnabled                      = $false
$Deployment.UseGMTTimes                     = $true
$Deployment.Put()
