 function Invoke-SccmBaselineEvaluation
{
    param (
        [parameter(Mandatory = $true)]
        $ComputerName
    )
    # Get a list of baseline objects assigned to the remote computer
    $Baselines = Get-WmiObject -ComputerName $ComputerName -Namespace root\ccm\dcm -Class SMS_DesiredConfiguration

    # For each (%) baseline object, call SMS_DesiredConfiguration.TriggerEvaluation, passing in the Name and Version as params
    $Baselines | % { ([wmiclass]"\\$ComputerName\root\ccm\dcm:SMS_DesiredConfiguration").TriggerEvaluation($_.Name, $_.Version) }
}


# 1. Replace your SCCM server name (MySccmServer) and SCCM Site Code (LAB) with your own!
# 2. [Optional] Replace the collection ID (SMS00001) with a collection of your choosing

$CompList = Get-WmiObject –ComputerName SCCMSERVER –Namespace root\sms\site_SS1 –Class SMS_CollectionMember_a –Filter "CollectionID = 'SS100695'" -Property Name,ResourceType
# For each computer in the list, filter it for ResourceType 5 (computer resources), and then invoke the function above, passing in the computer name
$CompList | ? { $_.ResourceType -eq 5 } | % { Invoke-SccmBaselineEvaluation $_.Name }


 # 'Test - Isaac's VMs' = SS100176




# Clear-Host
# & Invoke-SccmBaselineEvaluation RemoteComputer
