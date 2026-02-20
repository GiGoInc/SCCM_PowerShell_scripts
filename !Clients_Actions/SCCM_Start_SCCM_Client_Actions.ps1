Import-Module C:\Scripts\!Modules\CMClient.psm1
#>
Windows Installer Source List Update Cycle' = '{00000000-0000-0000-0000-000000000107}';
Import-Module C:\Scripts\!Modules\CMClient.psm1

$CurrentDirectory = "D:\Powershell\!SCCM_PS_scripts\!Clients_Actions"

$File = Get-Content "$CurrentDirectory\SCCM_Start_SCCM_Client_Actions--PCList.txt"
$ADate = Get-Date -Format "yyyy_MM-dd_hh-mm-ss"
$Log =  "$CurrentDirectory\SCCM_Start_SCCM_Client_Actions--RESULTS_$ADate.csv"

"PC Name,Status" | Add-Content $Log

ForEach ($Computer in $File) 
{
	Write-Output "Pinging...`t$Computer"
    $ping = gwmi Win32_PingStatus -filter "Address='$Computer'"
    if($ping.StatusCode -eq 0)
	{
	    $pcip=$ping.ProtocolAddress;
        Write-Output "Starting SCCM Action - Data Discovery Cycle...."
    Invoke-CMClientDiscoveryDataCycle -Computername $Computer -AsJob
        Start-Sleep -Seconds 2
        Write-Output "Starting SCCM Action - Client Hardware Inventory...."
    Invoke-CMClientHardwareInventory -Computername $Computer  -AsJob
        Write-Output "Starting SCCM Action - Update Deployment Evaluation...."
    Invoke-CMClientUpdateDeploymentEvaluation -Computername $Computer -AsJob
        "$Computer,complete" | Add-Content $Log
	} 
    else
	{
	    Write-Output "$Computer unpingable"
	    "$Computer,unpingable"| Add-Content $Log
	} 
}


<#

Import-Module C:\Scripts\!Modules\CMClient.psm1

$CurrentDirectory = split-path $MyInvocation.MyCommand.Path
$File = Get-Content "$CurrentDirectory\SCCM_Client_Actions_v1_LIST.txt"
$ADate = Get-Date -Format "yyyy_MM-dd_hh-mm-ss"
$Log =  "$CurrentDirectory\SCCM_Client_Actions_v1_RESULTS_$ADate.csv"

"PC Name,Status" | Add-Content $Log

ForEach ($Computer in $File) 
{
	Write-Output "Pinging...`t$Computer"
    $ping = gwmi Win32_PingStatus -filter "Address='$Computer'"
    if($ping.StatusCode -eq 0)
	{
	    $pcip=$ping.ProtocolAddress;
	    # Write-Output "Stopping Windows Update service...."
        # Stop-Service -Name "wuauserv" -Force
        #     if((Test-Path -Path C:\Windows\SoftwareDistribution )){
        #        Remove-Item -Path C:\Windows\SoftwareDistribution -Force -Recurse
        #     }
        #     	    Write-Output "Starting Windows Update service...."
        #             Start-Service "wuauserv"
        #     
        #     	    Write-Output "Stopping Crypt service...."
        #             Stop-Service "CryptSvc" -Force
        #     if((Test-Path -Path C:\Windows\System32\catroot2 )){
        #        Remove-Item -Path C:\Windows\System32\catroot2 -Force -Recurse
        #     }  
	    # Write-Output "Starting Crypt service...."
        # Start-Service "CryptSvc"

        Write-Output "Starting SCCM Action - Data Discovery Cycle...."
    Invoke-CMClientDiscoveryDataCycle -Computername $Computer -AsJob
        Start-Sleep -Seconds 2
        Write-Output "Starting SCCM Action - Client Hardware Inventory...."
    Invoke-CMClientHardwareInventory -Computername $Computer  -AsJob
    #    Write-Output "Starting SCCM Action - Update Deployment Evaluation...."
    #Invoke-CMClientUpdateDeploymentEvaluation -Computername $Computer -AsJob
        "$Computer,complete" | Add-Content $Log
	} 
    else
	{
	    Write-Output "$Computer unpingable"
	    "$Computer,unpingable"| Add-Content $Log
	} 
}



'MachinePolicy' = = = = '{00000000-0000-0000-0000-000000000021}';
'DiscoveryData' = = = = '{00000000-0000-0000-0000-000000000003}';
'ComplianceEvaluation' = = = = '{00000000-0000-0000-0000-000000000071}';
'AppDeployment' = = = = '{00000000-0000-0000-0000-000000000121}';
'HardwareInventory' = = = = '{00000000-0000-0000-0000-000000000001}';
'UpdateDeployment' = = = = '{00000000-0000-0000-0000-000000000108}';
'UpdateScan' = = = = '{00000000-0000-0000-0000-000000000113}';
'SoftwareInventory' = = = = '{00000000-0000-0000-0000-000000000002}';

Machine Policy Retrieval & Evaluation (machine policy assignment request) = = = = '{00000000-0000-0000-0000-000000000021}';
Data Discovery Report	'{00000000-0000-0000-0000-000000000003}';
NAP action	'{00000000-0000-0000-0000-000000000071}';
Application manager policy action	'{00000000-0000-0000-0000-000000000121}';
Hardware Inventory	'{00000000-0000-0000-0000-000000000001}';
Evaluate software update assignment (Software Updates Deployment)	'{00000000-0000-0000-0000-000000000108}';
Software update scan	'{00000000-0000-0000-0000-000000000113}';
Software Inventory	'{00000000-0000-0000-0000-000000000002}';


'RemoteLocale Distribution Point Maintenance Task' = '{00000000-0000-0000-0000-000000000109}';
'Clean state message cache' = '{00000000-0000-0000-0000-000000000112}';
'Client Machine Authentication' = '{00000000-0000-0000-0000-000000000012}';
'DCM policy' = '{00000000-0000-0000-0000-000000000110}';
'Discovery Data Collection Cycle' = '{00000000-0000-0000-0000-000000000103}';
'Endpoint AM policy reevaluate' = '{00000000-0000-0000-0000-000000000222}';
'Endpoint deployment reevaluate' = '{00000000-0000-0000-0000-000000000221}';
'External event detection' = '{00000000-0000-0000-0000-000000000223}';
'File Collection' = '{00000000-0000-0000-0000-000000000010}';
'File Collection Cycle' = '{00000000-0000-0000-0000-000000000104}';
'Hardware Inventory Collection Cycle' = '{00000000-0000-0000-0000-000000000101}';
'IDMIF Collection' = '{00000000-0000-0000-0000-000000000011}';
'IDMIF Collection Cycle' = '{00000000-0000-0000-0000-000000000105}';
'Machine Policy Agent Cleanup' = '{00000000-0000-0000-0000-000000000040}';
'Machine policy evaluation' = '{00000000-0000-0000-0000-000000000022}';
'Out-Of-Band management scheduled event' = '{00000000-0000-0000-0000-000000000120}';
'Peer DP Pending package check schedule' = '{00000000-0000-0000-0000-000000000062}';
'Peer DP Status reporting' = '{00000000-0000-0000-0000-000000000061}';
'Policy Agent Evaluate Assignment (User)' = '{00000000-0000-0000-0000-000000000027}';
'Policy Agent Request Assignment (User)' = '{00000000-0000-0000-0000-000000000026}';
'Policy Agent Validate Machine Policy / Assignment' = '{00000000-0000-0000-0000-000000000042}';
'Policy Agent Validate User Policy / Assignment' = '{00000000-0000-0000-0000-000000000043}';
'Power management start summarizer' = '{00000000-0000-0000-0000-000000000131}';
'Refresh Default MP Task' = '{00000000-0000-0000-0000-000000000023}';
'Refresh location services (Ad site, or subnet)' = '{00000000-0000-0000-0000-000000000024}';
'Refresh proxy manamgement point' = '{00000000-0000-0000-0000-000000000037}';
'Request software update source (Windows Installer Source List)' = '{00000000-0000-0000-0000-000000000032}';
'Request timeout value for tasks' = '{00000000-0000-0000-0000-000000000025}';
'Retrying/Refreshing certificates in AD on MP' = '{00000000-0000-0000-0000-000000000051}';
'Software Inventory Collection Cycle' = '{00000000-0000-0000-0000-000000000102}';
'Software Metering Generating Usage Report' = '{00000000-0000-0000-0000-000000000031}';
'Software Metering Usage Report Cycle' = '{00000000-0000-0000-0000-000000000106}';
'Software update deployment re-eval' = '{00000000-0000-0000-0000-000000000114}';
'State message upload' = '{00000000-0000-0000-0000-000000000111}';
'State system policy bulk send high' = '{00000000-0000-0000-0000-000000000115}';
'State system policy bulk send low' = '{00000000-0000-0000-0000-000000000116}';
'SUM Updates install schedule' = '{00000000-0000-0000-0000-000000000063}';
'User Policy Agent Cleanup' = '{00000000-0000-0000-0000-000000000041}';
'Windows Installer Source List Update Cycle' = '{00000000-0000-0000-0000-000000000107}';
Software update deployment re-eval' = '{00000000-0000-0000-0000-000000000114}';
Software update scan' = '{00000000-0000-0000-0000-000000000113}';
State message upload' = '{00000000-0000-0000-0000-000000000111}';
State system policy bulk send high' = '{00000000-0000-0000-0000-000000000115}';
State system policy bulk send low' = '{00000000-0000-0000-0000-000000000116}';
SUM Updates install schedule' = '{00000000-0000-0000-0000-000000000063}';
User Policy Agent Cleanup' = '{00000000-0000-0000-0000-000000000041}';
Windows Installer Source List Update Cycle' = '{00000000-0000-0000-0000-000000000107}';
#>
