D:
CD 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:
CD SS1:

$File = "E:\Packages\applist.txt"

	
function AppDeploy ($AppName)
{
	$ADate = Get-Date -UFormat "%Y/%m/%d"
	$ATime = Get-Date -UFormat "%R"
	$CollName = "Test - Isaac's VMs"
	$CollID = "SS100176"
	#$AppName = "Dymo Labels"
	$DAction = "Install"
	$Comm = "Deployment from POWERSHELL to $CollName of $AppName"


$DeploymentHash = @{
					CollectionName = $CollName
					Name = $AppName
					AvaliableDate = $ADate
					AvaliableTime = $ATime
					Comment = $Comm
					DeployAction = $DAction
					EnableMomAlert = $True
					FailParameterValue = 40
					OverrideServiceWindow = $True
					PersistOnWriteFilterDevice = $False
					PreDeploy = $True
					RaiseMomAlertsOnFailure = $True
					RebootOutsideServiceWindow = $True
					SendWakeUpPacket = $True
					UseMeteredNetwork = $True
					UserNotification = "DisplaySoftwareCenterOnly"
                    }
					
Write-Output Collname - $CollName
Write-Output CollID - $CollID
Write-Output AppName - $AppName
Write-Output AvailableDate -  $ADate
Write-Output AvailableTime - $ATime
Write-Output Comment - $Comm
Write-Output DeployAction - $DAction
					
Start-CMApplicationDeployment @DeploymentHash

}					
(Get-Content $File) | foreach-Object {invoke-command -ScriptBlock ${function:AppDeploy} -ArgumentList $_}


#-CollectionName<String>
#-Id<String[]>
#-InputObject<IResultObject>
#-Name<String[]>







































