cls
Start-Sleep -Seconds 5
Write-Host "done." -ForegroundColor Green
cls
write-host "Working on it..." -f Yellow -NoNewline
$ApplicationName = "Printer Installer Client" # Enter the Application Name


##################################################################################
$ADate = Get-Date -Format "yyyy_MM-dd_hh-mm-ss"
$AppName = $ApplicationName.Replace(' ','_')
$SCCMFile = "D:\Powershell\!SCCM_PS_scripts\!Deployments\$ADate--Deployment_Status_$ApplicationName.csv"
'ApplicationName,AssignmentID,Target Collection,Deployment Type Name,Computer Name,LastComplianceMessageTime,AppEnforcementState,State Message' | Set-Content $SCCMFile
##################################################################################
##################################################################################
      $SQL_DB = 'CM_XX1'
  $SQL_Server = 'SERVER'
$SQL_Instance = 'SERVER'
#########################################
$SQL_Query = "
select distinct
aa.ApplicationName,
ae.AssignmentID,
aa.CollectionName as 'Target Collection',
ae.descript as 'Deployment Type Name',
s1.netbios_name0 as 'Computer Name',
ci2.LastComplianceMessageTime,
ae.AppEnforcementState,
case when ae.AppEnforcementState = 1000 then 'Success'
when ae.AppEnforcementState = 1001 then 'Already Compliant'
when ae.AppEnforcementState = 1002 then 'Simulate Success'
when ae.AppEnforcementState = 2000 then 'In Progress'
when ae.AppEnforcementState = 2001 then 'Waiting for Content'
when ae.AppEnforcementState = 2002 then 'Installing'
when ae.AppEnforcementState = 2003 then 'Restart to Continue'
when ae.AppEnforcementState = 2004 then 'Waiting for maintenance window'
when ae.AppEnforcementState = 2005 then 'Waiting for schedule'
when ae.AppEnforcementState = 2006 then 'Downloading dependent content'
when ae.AppEnforcementState = 2007 then 'Installing dependent content'
when ae.AppEnforcementState = 2008 then 'Restart to complete'
when ae.AppEnforcementState = 2009 then 'Content downloaded'
when ae.AppEnforcementState = 2010 then 'Waiting for update'
when ae.AppEnforcementState = 2011 then 'Waiting for user session reconnect'
when ae.AppEnforcementState = 2012 then 'Waiting for user logoff'
when ae.AppEnforcementState = 2013 then 'Waiting for user logon'
when ae.AppEnforcementState = 2014 then 'Waiting to install'
when ae.AppEnforcementState = 2015 then 'Waiting retry'
when ae.AppEnforcementState = 2016 then 'Waiting for presentation mode'
when ae.AppEnforcementState = 2017 then 'Waiting for Orchestration'
when ae.AppEnforcementState = 2018 then 'Waiting for network'
when ae.AppEnforcementState = 2019 then 'Pending App-V Virtual Environment'
when ae.AppEnforcementState = 2020 then 'Updating App-V Virtual Environment'
when ae.AppEnforcementState = 3000 then 'Requirements not met'
when ae.AppEnforcementState = 3001 then 'Host platform not applicable'
when ae.AppEnforcementState = 4000 then 'Unknown'
when ae.AppEnforcementState = 5000 then 'Deployment failed'
when ae.AppEnforcementState = 5001 then 'Evaluation failed'
when ae.AppEnforcementState = 5002 then 'Deployment failed'
when ae.AppEnforcementState = 5003 then 'Failed to locate content'
when ae.AppEnforcementState = 5004 then 'Dependency installation failed'
when ae.AppEnforcementState = 5005 then 'Failed to download dependent content'
when ae.AppEnforcementState = 5006 then 'Conflicts with another application deployment'
when ae.AppEnforcementState = 5007 then 'Waiting retry'
when ae.AppEnforcementState = 5008 then 'Failed to uninstall superseded deployment type'
when ae.AppEnforcementState = 5009 then 'Failed to download superseded deployment type'
when ae.AppEnforcementState = 5010 then 'Failed to updating App-V Virtual Environment'
End as 'State Message'
from v_R_System_Valid s1
join vAppDTDeploymentResultsPerClient ae on ae.ResourceID=s1.ResourceID
join v_CICurrentComplianceStatus ci2 on ci2.CI_ID=ae.CI_ID AND
ci2.ResourceID=s1.ResourceID
join v_ApplicationAssignment aa on ae.AssignmentID = aa.AssignmentID
where ae.AppEnforcementState is not null and aa.ApplicationName='$ApplicationName'
order by LastComplianceMessageTime Desc"
##################################################################################
##################################################################################
$SQL_Check = Invoke-Sqlcmd -AbortOnError `
                           -ConnectionTimeout 60 `
                           -Database $SQL_DB  `
                           -HostName $SQL_Server  `
                           -Query $SQL_Query `
                           -QueryTimeout 600 `
                           -ServerInstance $SQL_Instance
#########################################
$output = @()
ForEach ($Check in $SQL_Check)
{
        [string]$ApplicationName           = $Check.ApplicationName           
        [string]$AssignmentID              = $Check.AssignmentID              
        [string]$TargetCollection          = $Check.'Target Collection'         
        [string]$DeploymentTypeName        = $Check.'Deployment Type Name '     
        [string]$ComputerName              = $Check.'Computer Name'             
        [string]$LastComplianceMessageTime = $Check.LastComplianceMessageTime 
        [string]$AppEnforcementState       = $Check.AppEnforcementState       
        [string]$StateMessage              = $Check.'State Message'   

#########################################################
    $output += '"' + $ApplicationName           + '","' + `
                     $AssignmentID              + '","' + `
                     $TargetCollection          + '","' + `
                     $DeploymentTypeName        + '","' + `
                     $ComputerName              + '","' + `
                     $LastComplianceMessageTime + '","' + `
                     $AppEnforcementState       + '","' + `
                     $StateMessage               + '"'
}
$output | Add-Content $SCCMFile
Write-Host "done." -ForegroundColor Green
Start-Sleep -Seconds 5
