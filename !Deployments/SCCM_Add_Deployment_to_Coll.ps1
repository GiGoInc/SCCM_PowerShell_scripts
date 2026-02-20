D:
# UserNotification = DisplaySoftwareCenterOnly
# UseMeteredNetwork = $True
D:
CD 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location XX1:
CD XX1:

$File = "E:\Packages\applist.txt"

function AppDeploy ($AppName)
{
	Write-Output $AppName
	$ADate = Get-Date -UFormat "%Y/%m/%d"
	$ATime = Get-Date -UFormat "%R"
	$CollName = "Test - SuperUser's VMs"
	$CollID = "XX100176"
	# $AppName = "FileMaker Pro 12"
	$DAction = "Install"
	$Comm = "Deployment from POWERSHELL to $CollName of $AppName"


	Start-CMApplicationDeployment -CollectionName $CollName -Name $AppName -AvaliableDate $ADate -AvaliableTime $ATime -Comment $Comm -DeployAction $DAction -EnableMomAlert $True -FailParameterValue 40 -OverrideServiceWindow $True -PersistOnWriteFilterDevice $False -PreDeploy $True -RaiseMomAlertsOnFailure $True -RebootOutsideServiceWindow $True -SendWakeUpPacket $True -UseMeteredNetwork $True -UserNotification "DisplaySoftwareCenterOnly"
}					
# Get-Content $File | foreach-Object {invoke-command -ScriptBlock ${function:Install-MissingUpdate} -ArgumentList $_}

(Get-Content $File) | foreach-Object {invoke-command -ScriptBlock ${function:AppDeploy} -ArgumentList $_}

CD E:

#  $DeploymentHash = @{	
# 						CollectionName = $CollName
# 						Name = $AppName
# 						AvaliableDate = $ADate
# 						AvaliableTime = $ATime
# 						Comment = $Comm
# 						DeployAction = $DAction
# 						EnableMomAlert = $True
# 						FailParameterValue = 40
# 						OverrideServiceWindow = $True
# 						PersistOnWriteFilterDevice = $False
# 						PreDeploy = $True
# 						RaiseMomAlertsOnFailure = $True
# 						RebootOutsideServiceWindow = $True
# 						SendWakeUpPacket = $True
# 						UseMeteredNetwork = $True
# 						UserNotification = "DisplaySoftwareCenterOnly"
#                     }


# CollectionName = $CollName
# Name = $AppName
# AvaliableDate = $ADate
# AvaliableTime = $ATime
# Comment = $Comm
# DeployAction = $DAction
# EnableMomAlert = $True
# FailParameterValue = 40
# OverrideServiceWindow = $True
# PersistOnWriteFilterDevice = $False
# PreDeploy = $True
# RaiseMomAlertsOnFailure = $True
# RebootOutsideServiceWindow = $True
# SendWakeUpPacket = $True
# SuccessParameterValue 30
# UseMeteredNetwork = $True
# UserNotification = DisplaySoftwareCenterOnly
