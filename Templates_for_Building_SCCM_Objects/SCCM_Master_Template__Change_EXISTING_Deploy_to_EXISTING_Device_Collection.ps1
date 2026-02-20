<#
}
        Write-Host "$DCollName " -ForegroundColor Red
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
$Appnames = 'Hyland Web ActiveX Control',`
            'Adobe Flash Player ActiveX - Latest (v21)',`
            'Adobe Reader 11.10',`
            'AT&T Connect Participant Application',`
            'Avecto Privilege Guard Client 3.8.298',`
            'Citrix Receiver',`
            'CutePDF',`
            'Image Centre 2016',`
            'Office 2010 Pro Plus',`
            'OrgPublisher PluginX 10.1',`
            'Password_Reset_Desktop_Integration',`
            'Printer Logic Client'

$InstallNotification = 'DisplayAll' # HideAll / DisplayAll / DisplaySoftwareCenterOnly

$DCollName = 'SuperUser - Test - Base Workstation Installs'

ForEach ($Appname in $AppNames)
{
    # DEPLOYMENT for DEVICE Collection
        $ADate = $(Get-Date -Format yyyy/MM/dd)
        $ATime = $(Get-Date -Format HH:mm)
        $DDate = $(Get-Date -Format yyyy/MM/dd) + " " + $(Get-Date -Format HH:mm)
        $DAction = "Install"
    	$DComm = "Deployment from POWERSHELL of $AppName to $DCollName"


    ####################################################################################################
    # DEPLOYMENT DEVICE Collection
        $DDeploymentHash = @{
    		                CollectionName = $DCollName
    		                ApplicationName = $AppName
    		                UserNotification = $InstallNotification
                            }
        Set-CMApplicationDeployment @DDeploymentHash

        Write-Host ""
        Write-Host "Set Application Deployment for: " -NoNewline
        Write-Host "$AppName " -ForegroundColor Green -NoNewline
        Write-Host "for DEVICE Collection named " -NoNewline
        Write-Host "$DCollName " -ForegroundColor Red
}
