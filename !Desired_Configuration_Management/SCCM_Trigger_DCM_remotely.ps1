$Computers = Get-Content "D:\Powershell\!SCCM_PS_scripts\!Desired_Configuration_Management\SCCM_Trigger_DCM_remotely--PCList.txt"

$Computers | ForEach-Object {Invoke-Command -ScriptBlock ${function:Invoke-SccmBaselineEvaluation} -ArgumentList $_}
$Computers = Get-Content "D:\Powershell\!SCCM_PS_scripts\!Desired_Configuration_Management\SCCM_Trigger_DCM_remotely--PCList.txt"


Function Invoke-SccmBaselineEvaluation
{
    param (
        [parameter(Mandatory = $true)]
        $Computer
    )
    # Get a list of baseline objects assigned to the remote computer
    $Baselines = Get-WmiObject -ComputerName $Computer -Namespace root\ccm\dcm -Class SMS_DesiredConfiguration

    # For each (%) baseline object, call SMS_DesiredConfiguration.TriggerEvaluation, passing in the Name and Version as params
    $Baselines | % { ([wmiclass]"\\$Computer\root\ccm\dcm:SMS_DesiredConfiguration").TriggerEvaluation($_.Name, $_.Version) }
}

Clear-Host
#& Invoke-SccmBaselineEvaluation RemoteComputer

$Computers | ForEach-Object {Invoke-Command -ScriptBlock ${function:Invoke-SccmBaselineEvaluation} -ArgumentList $_}

