function Invoke-SCCM-DCM_Evaluation
{
    param (
        [Parameter(Mandatory=$true, HelpMessage="Computer Name",ValueFromPipeline=$true)] $Computer
           )
    $Baselines = Get-WmiObject -ComputerName $Computer -Namespace root\ccm\dcm -Class SMS_DesiredConfiguration
    $Baselines | % { ([wmiclass]"\\$Computer\root\ccm\dcm:SMS_DesiredConfiguration").TriggerEvaluation($_.Name, $_.Version) }
}

$log = '.\Intitiate_All_DCM_Baselines.csv'


$Computers = 'Computer1'

ForEach ($Computer in $Computers)
{
    If(Test-Connection $computer -count 1 -quiet -BufferSize 16)
    {
        Try
        {
            Write-Host "Initiating $computer..."
            Invoke-SCCM-DCM_Evaluation -Computer $Computer
            "$computer,Initiated" | add-content $Log
        }
        Catch
        {
            Write-Host "Couldn't Initiate $computer"
            "$computer,Failed to Intitiate" | add-content $Log
        }
    }
    Else
    {
        Write-Host "Offline: $computer..."
        "$computer,Offline" | add-content $Log
    }
}
