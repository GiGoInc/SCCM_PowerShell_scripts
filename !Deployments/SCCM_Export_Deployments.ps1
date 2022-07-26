$Log = "D:\Powershell\!SCCM_PS_scripts\!Deployments\Deployments_2017-06-27.csv"
"SmsProviderObjectPath,AssignmentID,CI_ID,CollectionID,CollectionName,CreationTime,DeploymentID,DeploymentIntent,DeploymentTime,DesiredConfigType,EnforcementDeadline,FeatureType,ModelName,ModificationTime,NumberErrors,NumberInProgress,NumberOther,NumberSuccess,NumberTargeted,NumberUnknown,ObjectTypeID,PackageID,PolicyModelID,ProgramName,SecuredObjectId,SoftwareName,SummarizationTime,SummaryType" | Set-Content $Log

$A = Get-CMDeployment
ForEach ($B in $A)
{
    $SmsProviderObjectPath = $B.SmsProviderObjectPath 
    $AssignmentID = $B.AssignmentID          
    $CI_ID = $B.CI_ID                 
    $CollectionID = $B.CollectionID          
    $CollectionName = $B.CollectionName        
    $CreationTime = $B.CreationTime          
    $DeploymentID = $B.DeploymentID          
    $DeploymentIntent = $B.DeploymentIntent      
    $DeploymentTime = $B.DeploymentTime        
    $DesiredConfigType = $B.DesiredConfigType     
    $EnforcementDeadline = $B.EnforcementDeadline   
    $FeatureType = $B.FeatureType           
    $ModelName = $B.ModelName             
    $ModificationTime = $B.ModificationTime      
    $NumberErrors = $B.NumberErrors          
    $NumberInProgress = $B.NumberInProgress      
    $NumberOther = $B.NumberOther           
    $NumberSuccess = $B.NumberSuccess         
    $NumberTargeted = $B.NumberTargeted        
    $NumberUnknown = $B.NumberUnknown         
    $ObjectTypeID = $B.ObjectTypeID          
    $PackageID = $B.PackageID             
    $PolicyModelID = $B.PolicyModelID         
    $ProgramName = $B.ProgramName           
    $SecuredObjectId = $B.SecuredObjectId       
    $SoftwareName = $B.SoftwareName          
    $SummarizationTime = $B.SummarizationTime     
    $SummaryType = $B.SummaryType    

"$SmsProviderObjectPath,$AssignmentID,$CI_ID,$CollectionID,$CollectionName,$CreationTime,$DeploymentID,$DeploymentIntent,$DeploymentTime,$DesiredConfigType,$EnforcementDeadline,$FeatureType,$ModelName,$ModificationTime,$NumberErrors,$NumberInProgress,$NumberOther,$NumberSuccess,$NumberTargeted,$NumberUnknown,$ObjectTypeID,$PackageID,$PolicyModelID,$ProgramName,$SecuredObjectId,$SoftwareName,$SummarizationTime,$SummaryType" | Add-Content $Log
}