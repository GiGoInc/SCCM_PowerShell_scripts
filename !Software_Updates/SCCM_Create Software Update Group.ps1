<# Expedited Software updates notes
create-Group
"@
<# Expedited Software updates notes

Items needed to deploy update(s):
Bulletin or Article ID(s)- what updates to be deployed
    I.E. = MS15-078
Software Update Group (SUG) - bucket for updates the "Deployment Package" will deploy
    
Collection - what machines to deploy updates (in SUG) too
    Collection Name = ADR Collection - Manual Approvals
    Collection ID = XX100172
Deployment package - criteria for deployment, you can define when to available/deploy updates and whether to ignore maintenance window or not

Bulletin or Article ID(s)		"MS15-078"
Software Update Group (SUG)		"ADR: Workstations - Expedited deployment + current date"
Collection Name					"ADR Collection - Manual Approvals"
Collection ID					"XX100192.
Deployment package				

#>

<#
Functionality: This script creates a new Software Update Group in Microsoft System Center 2012 Configuration Manager
How does it work: create-SoftwareUpdateGroup.ps1 -UpdateGroupName $Name -KnowledgeBaseIDs $KBID -SiteCode
KnowledgeBaseID can contain comma separated KnowledgeBase IDs like 981852,16795779
Author: David O'Brien, david.obrien@gmx.de
Date: 02.12.2012
#>

$SiteCode = "XX1"
$UpdateGroupName = "
$Description,




param (
[string]$SiteCode,
[string]$UpdateGroupName,
[string]$Description,
[array]$KnowledgeBaseIDs,
[string]$DateUpdatesCreated,
[string]$LogFilePath,
[switch]$UseCSV,
[string]$CSVFilePath
)

Function create-Group {
<#
.SYNOPSIS
    Creates a new Software Update Group in Microsoft System Center 2012 Configuration Manager.
.DESCRIPTION
    Creates a new Software Update Group in Microsoft System Center 2012 Configuration Manager.
.PARAMETER SiteCode
    ConfigMgr SiteCode
.PARAMETER UpdateGroupName
    The name of the new Software Update Group
.PARAMETER Description
    The new Software Upate Group's description
.PARAMETER KnowledgeBaseIDs
    comma-separated list of Microsoft knowledge base IDs for Updates. If you use this, don't use "DateUpdatesCreated" and "UseCSV".
.PARAMETER DateUpdatesCreated
    Date the Updates in the database get filtered by, format: yyyymmdd. If you use this, don't use "KnowledgeBaseIDs" and "UseCSV".
.PARAMETER LogFilePath
    A Logfile will be created in this directory
.PARAMETER UseCSV
    A switch. Use this Parameter if you want to define the updates in a CSV file. If you use this, don't use "KnowledgeBaseIDs" and "DateUpdatesCreated".
.PARAMETER CSVFilePath
    If you use "UseCSV" you have to specify a path to a CSV file.
.EXAMPLE
    .\create-SoftwareUpdateGroup.ps1 -UpdateGroupName NewSoftwareUpdateGroup -Description "This is a new Software Update Group" -KnowledgeBaseIDs 981852,16795779 -SiteCode LAB -LogFilePath C:\temp
.EXAMPLE
    .\create-SoftwareUpdateGroup.ps1 -SiteCode LAB -UpdateGroupName SUG-2012-December -DateUpdatesCreated "20121211" -LogFilePath C:\temp -Description "Microsoft Updates December 2012"
.EXAMPLE
    .\create-SoftwareUpdateGroup.ps1 -SiteCode LAB -UpdateGroupName SUG-2012-December -Description "Microsoft Updates December 2012" -LogFilePath c:\Temp -UseCSV -CSVFilePath "C:\Temp\KBIDs.CSV"
.NOTES
    Author: David O'Brien, david.obrien@gmx.de
    Version: 1.0
    Change history
        02.12.2012: first release
        07.01.2013: Logging, create SUG by Date created, comment-based help for function
        Requirements: none
#>

[array]$CIIDs = @()

if ($UseCSV)
    {
        $KnowledgeBaseIDs = Get-Content $CSVFilePath
        foreach ($CIID in $KnowledgeBaseIDs)
            {
                $CIIDs += $CIID
            }
    }
else
    {
        $KnowledgeBaseIDs = (gwmi -ns root\sms\site_$($SiteCode) -Class SMS_softwareupdate | where {$_.dateposted -like "$($DateUpdatesCreated)*"}).ci_id
    }
<#
foreach ($KBID in $KnowledgeBaseIDs)
    {
        $CIID = (gwmi -ns root\sms\site_$($SiteCode) -class sms_softwareupdate | where {$_.ArticleID -eq $KBID }).CI_ID
        if ($CIID -eq $null)
            {
                Write-Log "The update with KB ID $($KBID) could not be found in the database and will be ignored."
            }
        else
            {
                $CIIDs += $CIID
            }
    }
#>
if (-not $UseCSV)
    {
        foreach ($CIID in $KnowledgeBaseIDs)
            {
                $CIIDs += $CIID
                write-log "The Update with CI_ID $($CIID) has been added to the Update List"
            }
    }

$SMS_CI_LocalizedProperties = "SMS_CI_LocalizedProperties"
$class_Localization = [wmiclass]""
$class_Localization.psbase.Path ="ROOT\SMS\Site_$($SiteCode):$($SMS_CI_LocalizedProperties)"
$Localization = $class_Localization.CreateInstance()
$Localization.DisplayName = $UpdateGroupName
$Localization.Description = $Description
$Localization.LocaleID = 1033
$Information += $Localization
$SMSAuthorizationList = "SMS_AuthorizationList"
$class_AuthList = [wmiclass]""
$class_AuthList.psbase.Path ="ROOT\SMS\Site_$($SiteCode):$($SMSAuthorizationList)"
$AuthList = $class_AuthList.CreateInstance()
$AuthList.Updates = $CIIDs
$AuthList.LocalizedInformation = $Information
$AuthList.Put() |Out-Null
}
function write-log([string]$info){
    if (($loginitialized -eq $false) -and (-not (Test-Path $logfile)))
        {
            $FileHeader > $logfile
           $script:loginitialized = $True
       }
   $time = get-date -format G
   $time + " " + $info | Out-File -FilePath $logfile -Append
}

<#---------Logfile Info----------#>
$script:logfile = "$($LogFilePath)\$($MyInvocation.MyCommand.Name)-$(get-date -format ddMMyy).log"
$script:Seperator = @"
$("-" * 25)
"@
$script:loginitialized = $false
$script:FileHeader = @"
$seperator
***Application Information***
Filename:  $($MyInvocation.MyCommand.Name)
Created by:  David O'Brien
Last Modified:  $(Get-Date -Date (get-item .\$($MyInvocation.MyCommand.Name)).LastWriteTime -f dd/MM/yyyy)
"@
create-Group
