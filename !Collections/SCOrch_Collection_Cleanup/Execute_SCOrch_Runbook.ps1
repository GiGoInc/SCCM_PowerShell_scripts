# Import the SCORCH module
Import-Module 'D:\Scripts\!Modules\scorchaccountestratorServicePowerShellV1_2\OrchestratorServiceModule.psm1'
 
# Set URL for web service
$scorch_url = "http://scorch_server:81/Orchestrator2012/Orchestrator.svc/"

 
# Set Folder Path for Runbook Folder
$runbook_folder = '\Scheduled Jobs\scorchaccount COllection Cleanup'
 
# Get all runbooks within the Daily folder
$daily_runbooks = Get-OrchestratorRunbook -ServiceUrl $scorch_url -RunbookPath $runbook_folder
 
# Run through them and start each one
foreach ($runbook in $daily_runbooks)
{
    # Get the runbook object
    $runbook_temp = Get-OrchestratorRunbook -ServiceUrl $scorch_url -RunbookId $runbook.Id
 
    # Now start the runbook
    Start-OrchestratorRunbook -Runbook $runbook_temp
}
 
# Output error log
$error | out-file "D:\scripts\Runbooks_Errors.txt"
 
# Output identity
whoami | out-file "D:\scripts\Runbooks_identity.txt"