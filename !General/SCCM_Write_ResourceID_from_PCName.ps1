#Get current working paths
}
    #Add-CMDeviceCollectionDirectMembershipRule -CollectionId XX100642 -ResourceID 16795598
#Get current working paths
$CurrentDirectory = split-path $MyInvocation.MyCommand.Path

C:
CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location XX1:
CD XX1:


$File = Get-Content ("$CurrentDirectory\!Direct_PC_addition_to_Device_Collection_PCList.txt")
ForEach ($item in $File)
{
    #$CollID = $Item.Split(',')[0]
    $PCName = $Item.Split(',')[1]
    $RES = Get-CMDevice -Name $PCName | Select $_.ResourceID
    $ResourceID = $RES.ResourceID | Add-Content "$CurrentDirectory\ResourceIDs.txt"

    

    #$Comm = "Deployment from POWERSHELL - adding $PCName into $CollID via Direct Membership"


    #$DeploymentHash = @{
    #                    CollectionId = $CollID
    #                    ResourceID = $ResourceID
    #                    }
    #Write-Output "$Comm"
    #Add-CMDeviceCollectionDirectMembershipRule @DeploymentHash
    #Add-CMDeviceCollectionDirectMembershipRule -CollectionId XX100642 -ResourceID 16795598
}
