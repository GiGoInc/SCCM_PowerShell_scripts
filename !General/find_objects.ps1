cls
#>

cls
##############################
# Add Required Type Libraries
    [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ManagementProvider.dll")) | Out-Null
    [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.dll")) | Out-Null
    [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.Extender.dll")) | Out-Null
    [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.MsiInstaller.dll")) | Out-Null
############################

C:
CD 'C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Start-Sleep -Milliseconds 500
Set-Location XX1:
CD XX1:

##############################
. "D:\Powershell\!SCCM_PS_scripts\!General\SCCM_Get_ObjectLocation_version2.ps1"



$FolderLog = 'C:\Temp\SCCM_FolderLog.txt'
$Log2 = 'C:\Temp\Folder_Parents---Applications.csv'

"Name,FolderGuid" | Set-Content $FolderLog

$X = Get-CMFolder -Name *

ForEach ($item in $X)
{
	$Name = $item.Name
    $FolderGuid = $item.FolderGuid

	"$Name,$FolderGuid" | Add-Content $FolderLog
}

Get-SCCMObjectLocation -SMSId "16777975" -SiteCode 'XX1' -SiteServerName 'SERVER.DOMAIN.COM'

<#
__GENUS                               : 2
__CLASS                               : SMS_Collection
__SUPERCLASS                          : SMS_BaseClass
__DYNASTY                             : SMS_BaseClass
__RELPATH                             : SMS_Collection.CollectionID="XX1008B2"
__PROPERTY_COUNT                      : 42
__DERIVATION                          : {SMS_BaseClass}
__SERVER                              : SERVER
__NAMESPACE                           : root\sms\Site_XX1
__PATH                                : \\SERVER\root\sms\Site_XX1:SMS_Collection.CollectionID="XX1008B2"
CloudSyncCount                        : 0
CollectionID                          : XX1008B2
CollectionRules                       : 
CollectionType                        : 1
CollectionVariablesCount              : 0
Comment                               : 
CurrentStatus                         : 1
FullEvaluationLastRefreshTime         : 20240405182024.567000+***
FullEvaluationMemberChanges           : 0
FullEvaluationMemberChangeTime        : 20240111154726.063000+***
FullEvaluationNextRefreshTime         : 20240405200400.000000+***
FullEvaluationRunTime                 : 1187
HasProvisionedMember                  : False
IncludeExcludeCollectionsCount        : 0
IncrementalEvaluationLastRefreshTime  : 20240405181427.570000+***
IncrementalEvaluationMemberChanges    : 0
IncrementalEvaluationMemberChangeTime : 20240111154726.063000+***
IncrementalEvaluationRunTime          : 1141
IsBuiltIn                             : False
IsReferenceCollection                 : False
ISVData                               : 
ISVDataSize                           : 0
ISVString                             : 
LastChangeTime                        : 20240111154713.000000+***
LastMemberChangeTime                  : 20240111154726.063000+***
LastRefreshTime                       : 20240405182024.567000+***
LimitToCollectionID                   : SMS00004
LimitToCollectionName                 : All Users and User Groups
LocalMemberCount                      : 47
MemberClassName                       : SMS_CM_RES_COLL_XX1008B2
MemberCount                           : 47
MonitoringFlags                       : 0
Name                                  : SDG-SCCM Console Users
ObjectPath                            : /[Software Distribution]/Active Directory Software Groups
OwnedByThisSite                       : True
PowerConfigsCount                     : 0
RefreshSchedule                       : 
RefreshType                           : 6
ReplicateToSubSites                   : True
ServicePartners                       : 0
ServiceWindowsCount                   : 0
UseCluster                            : False
PSComputerName                        : SERVER




$SiteCode="XX1"
$SiteServer = "SERVER"
$AllCollections = Get-WmiObject -Namespace "root\sms\Site_$SiteCode" -Class SMS_Collection -ComputerName $SiteServer
# $AllCollections.objectpath

"Name,MemberCount,CollectionID,ObjectPath,LimitToCollectionName,LimitToCollectionID,IsBuiltIn" | set-Content $FolderLog

ForEach ($Collection in $AllCollections)
{
    $Name                  = $Collection.Name
    $MemberCount           = $Collection.MemberCount
    $CollectionID          = $Collection.CollectionID
    $ObjectPath            = $Collection.ObjectPath
    $LimitToCollectionName = $Collection.LimitToCollectionName
    $LimitToCollectionID   = $Collection.LimitToCollectionID
    $IsBuiltIn             = $Collection.IsBuiltIn
    
    "`"$Name`",`"$MemberCount`",`"$CollectionID`",`"$ObjectPath`",`"$LimitToCollectionName`",`"$LimitToCollectionID`",`"$IsBuiltIn`"" | add-content $FolderLog
}
#######################################################################################
#######################################################################################

# Get-CMFolder -Guid $item.FolderGuid

SmsProviderObjectPath : SMS_ObjectContainerNode.ContainerNodeID=16777999
ContainerNodeID       : 16777999
FolderFlags           : 0
FolderGuid            : 72418BEE-6D0B-472F-A2E2-C61E37B5A545
IsEmpty               : False
Name                  : OS Update Deployments
ObjectType            : 5000
ObjectTypeName        : SMS_Collection_Device
ParentContainerNodeID : 16777975
SearchFolder          : False
SearchString          : 
SourceSite            : XX1

#>
