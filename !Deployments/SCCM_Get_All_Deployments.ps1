cls
#>
SummaryType           : 1
cls
#>
SummaryType           : 1
cls
C:
CD 'C:\Program Files (x86)\ConfigMgr Console\bin'
Import-Module ".\ConfigurationManager.psd1"
Start-Sleep -Milliseconds 500
## Connect to ConfigMgr Site 
Set-Location XX1:
CD XX1:
############################################################
############################################################
$ADate = Get-Date -Format "yyyy_MM-dd_hh-mm-ss"
$Log = "H:\Powershell\!SCCM_PS_scripts\!Deployments\$ADate--Deployments.csv"
'DeploymentID,ApplicationName,CollectionName,CreationTime,DeploymentTime,Enabled,EnforcementDeadline,FeatureType,NumberTargeted,SoftwareName' | Set-Content $Log

$output = @()
$Deployments = Get-CMDeployment

$Deployments | % {
$output += '"' +
$_.DeploymentID + '","' + `
$_.ApplicationName + '","' + `
$_.CollectionName + '","' + `
$_.CreationTime + '","' + `
$_.DeploymentTime + '","' + `
$_.Enabled + '","' + `
$_.EnforcementDeadline + '","' + `
$_.FeatureType + '","' + `
$_.NumberTargeted + '","' + `
$_.SoftwareName + '"' 
}
$output | Add-Content $Log

<#
SmsProviderObjectPath : SMS_DeploymentSummary.DeploymentID="{3ADCB1C2-6FF3-4EF6-9FE0-A66D3D463CAA}"
ApplicationName       : WMI Framework For Local Groups with Logging
AssignmentID          : 16777467
CI_ID                 : 16852341
CollectionID          : XX100010
CollectionName        : All Windows Workstation or Professional Systems (DC0)
CollectionType        : 2
CreationTime          : 3/14/2014 9:10:19 PM
DeploymentID          : {3ADCB1C2-6FF3-4EF6-9FE0-A66D3D463CAA}
DeploymentIntent      : 1
DeploymentTime        : 3/14/2014 4:10:00 PM
DesiredConfigType     : 3
Enabled               : True
EnforcementDeadline   : 
FeatureType           : 6
ModelName             : ScopeId_EAE80406-A68B-4F32-8601-002228FC18D9/Baseline_4373ff68-250e-451c-a55f-8c2472da5b29
ModificationTime      : 3/14/2014 9:10:19 PM
NumberErrors          : 1
NumberInProgress      : 0
NumberOther           : 0
NumberSuccess         : 4704
NumberTargeted        : 4711
NumberUnknown         : 6
ObjectTypeID          : 200
PackageID             : 
PolicyModelID         : 16848012
ProgramName           : 
RequireApproval       : 
SecuredObjectId       : {3ADCB1C2-6FF3-4EF6-9FE0-A66D3D463CAA}
SoftwareName          : WMI Framework For Local Groups with Logging
SummarizationTime     : 6/20/2024 5:57:03 AM
SummaryType           : 1
#>
