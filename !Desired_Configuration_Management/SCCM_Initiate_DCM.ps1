function Invoke-SCCMDCMEvaluation
{
    param (
        [Parameter(Mandatory=$true, HelpMessage="Computer Name",ValueFromPipeline=$true)] $ComputerName
           )
    $Baselines = Get-WmiObject -ComputerName $ComputerName -Namespace root\ccm\dcm -Class SMS_DesiredConfiguration
    $Baselines | % { ([wmiclass]"\\$ComputerName\root\ccm\dcm:SMS_DesiredConfiguration").TriggerEvaluation($_.Name, $_.Version) }
}
# Invoke-SccmBaselineEvaluation localhost 