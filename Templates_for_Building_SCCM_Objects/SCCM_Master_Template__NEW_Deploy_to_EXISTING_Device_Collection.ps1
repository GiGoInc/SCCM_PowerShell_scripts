<#
C:

<#
.Synopsis
This script is intended to build the AD-Groups,  by another script with a list of machine names, which will add a header and build a CSV file.
The output is required to be a single line of information per computername, so it can be passed as an object to Invoke-Parallel.ps1

The data follows comma separated order:
PC Name,Online,BPApplID String

.Example
PS C:\> .\Read_Part2pro--bsub.ps1 -computer 'Computer1'
	Computer1,Yes,	BPApplID="XAMS1"


    It's assumed that the tech:
        ....is using a PowerShell install file named "install.ps1"
        ...created a folder named the same as "$SourceFolder" in \\SERVER\PACKAGES
        ...populated that folder with the install contents

To Be Done
    Create piece to move Device Collection to correct subfolder in SCCM
#>


<#
[CmdletBinding()]
param(
    # Support for multiple computers from the pipeline
    [Parameter(Mandatory=$True,
                ValueFromPipeline=$True,
                ValueFromPipelineByPropertyName=$True,
                HelpMessage='Type in application name, this will also be the name of the AD "SDG-" group name, the SCOrch collection Name, and Application Name.')]
    [string]$Appnames,
    [Parameter(Mandatory=$True,
                ValueFromPipeline=$True,
                ValueFromPipelineByPropertyName=$True,
                HelpMessage='Type in the assumed runtime for the application install.')]
    [string]$DTRunTime,
    [Parameter(Mandatory=$True,
                ValueFromPipeline=$True,
                ValueFromPipelineByPropertyName=$True,
                HelpMessage='Type in the maximum runtime for the application install.')]
    [string]$DTMaxRunTime,
    [Parameter(Mandatory=$True,
                ValueFromPipeline=$True,
                ValueFromPipelineByPropertyName=$True,
                HelpMessage='Type in the PREVIOUS application version for building the Device collection query.')]
    [string]$QDAVersion,
    # Switch to turn on Error Logging
    [Switch]$ErrorLog,
    [String]$LogFile = 'C:\Temp\errorlog.txt'
    )
#>


# Load SCCM Module
    C:
    CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
    Import-Module ".\ConfigurationManager.psd1"
    Set-Location XX1:
    CD XX1:


# User Input Variables
$InstallNotification = 'HideAll' # HideAll / DisplayAll / DisplaySoftwareCenterOnly


$Appname = 'Marketing Office Templates'

# $DCollnames = Collection Name ;  Deadline DateTime
$DCollNames = 'Workstations - Non-RemoteLocale - Group 03;2016/10/19 19:00', `
              'Workstations - Non-RemoteLocale - Group 04;2016/10/19 19:00', `
              'Workstations - Non-RemoteLocale - Group 05;2016/10/20 19:00', `
              'Workstations - Non-RemoteLocale - Group 06;2016/10/20 19:00', `
              'Workstations - Non-RemoteLocale - Group 07;2016/10/24 19:00', `
              'Workstations - Non-RemoteLocale - Group 08;2016/10/24 19:00', `
              'Workstations - Non-RemoteLocale - Group 09;2016/10/25 19:00', `
              'Workstations - Non-RemoteLocale - Group 10;2016/10/25 19:00', `
              'Workstations - Non-RemoteLocale - Group 11;2016/10/26 19:00', `
              'Workstations - Non-RemoteLocale - Group 12;2016/10/26 19:00', `
              'Workstations - Non-RemoteLocale - Group 13;2016/10/27 19:00', `
              'Workstations - Non-RemoteLocale - Group 14;2016/10/27 19:00', `
              'Workstations - Non-RemoteLocale - Group 15;2016/10/31 19:00', `
              'Workstations - Non-RemoteLocale - Group 16;2016/10/31 19:00', `
              'Workstations - Non-RemoteLocale - Group 17;2016/11/01 19:00', `
              'Workstations - Non-RemoteLocale - Group 18;2016/11/01 19:00', `
              'Workstations - Non-RemoteLocale - Group 19;2016/11/02 19:00', `
              'Workstations - Non-RemoteLocale - Group 20;2016/11/02 19:00', `
              'Workstations - Non-RemoteLocale - Group 21;2016/11/03 19:00', `
              'Workstations - Non-RemoteLocale - Group 22;2016/11/03 19:00', `
              'Workstations - Non-RemoteLocale - Group 23;2016/11/07 19:00', `
              'Workstations - Non-RemoteLocale - Group 24;2016/11/07 19:00', `
              'Workstations - Non-RemoteLocale - Group 25;2016/11/08 19:00', `
              'Workstations - Non-RemoteLocale - Group 26;2016/11/08 19:00', `
              'Workstations - Non-RemoteLocale - Group 27;2016/11/08 19:00'

ForEach ($item in $DCollNames)
#ForEach ($Appname in $AppNames)
{
    $DCollName = $item.split(';')[0]
    $DDate = $item.split(';')[1]

    Write-Host "Coll: $DCollName`tDate: $DDate"

    # DEPLOYMENT for DEVICE Collection
        $ADate = '2016/10/14 19:00'
        #$DDate = $(Get-Date -Format yyyy/MM/dd) + " " + $(Get-Date -Format HH:mm)
        $DAction = "Install"
    	$DComm = "Deployment from POWERSHELL of $AppName to $DCollName"


    ####################################################################################################
    # DEPLOYMENT DEVICE Collection
        $DDeploymentHash = @{
    		                CollectionName = $DCollName
    		                Name = $AppName
    		                AvailableDateTime = $ADate
    		                Comment = $DComm
    		                DeadlineDate = [DateTime]$DDate
    		                DeployAction = "Install"
    		                DeployPurpose = "Required"
    		                EnableMomAlert = $False
    		                OverrideServiceWindow = $False
    		                PreDeploy = $False
    		                RebootOutsideServiceWindow = $False
    		                SendWakeupPacket = $True
    		                TimeBaseOn = "LocalTime"
    		                UseMeteredNetwork = $True
    		                UserNotification = $InstallNotification
                            }
        Start-CMApplicationDeployment @DDeploymentHash
        Write-Host ""
        Write-Host "Created Application Deployment for: " -NoNewline
        Write-Host "$AppName " -ForegroundColor Green -NoNewline
        Write-Host "for DEVICE Collection named " -NoNewline
        Write-Host "$DCollName " -ForegroundColor Red
}

C:
