C:
CD D:
}
C:
CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location XX1:
CD XX1:

$List = "D:\Powershell\!SCCM_PS_scripts\!Deployments\SCCM--Set_Deployments_on_Device_Collection--PCList.txt"

$CollectionInfo = Get-Content $List

ForEach ($Item in $CollectionInfo)
{
    $CollName = $Item.split(';')[0]
     $AppName = $Item.split(';')[1]
       $ADate = $Item.split(';')[2]
       $DDate = $Item.split(';')[3]
        $Comm = "Deployment from POWERSHELL to $CollName of $AppName"
	 $DAction = "Install"

New-CMApplicationDeployment -Name $AppName `
                            -AvailableDateTime $ADate `
                            -CollectionName $CollName `
                            -Comment $Comm `
                            -DeadlineDateTime $DDate `
                            -DeployPurpose Required `
                            -EnableMomAlert $False `
                            -FailParameterValue 15 `
                            -OverrideServiceWindow $True `
                            -PreDeploy $True `
                            -RebootOutsideServiceWindow $True `
                            -SendWakeupPacket $True `
                            -TimeBaseOn LocalTime `
                            -UserNotification HideAll
}
CD D:
