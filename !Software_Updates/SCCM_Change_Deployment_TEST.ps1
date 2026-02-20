# Set-CMDeploymentDeadlines script
}
    }
# Set-CMDeploymentDeadlines script
#   J. Greg Mackinnon, 2014-02-07
#   Updates all existing software update deployments with a new enforcement deadline.
#   Requires specification of: 
#    -SiteServer (an SCCM Site Server name)
#    -SiteCode   (an SCCM Site Code)
#    -DeadlineDate
#    -DeadlineTime
#

[CmdletBinding()]

param(
    [parameter(Mandatory=$true)]
    [string] $SiteServer,

    [parameter(Mandatory=$true)]
    [string] $SiteCode,

    [parameter(Mandatory=$true)]
    [ValidateScript({
        if (($_.Length -eq 8) -and ($_ -notmatch '[a-zA-Z]+')) {
            $true
        } else {
            Throw '-Deadline must be a date string in the format "YYYYMMDD"'
        }
    })]
    [string] $DeadlineDate,

    [parameter(Mandatory=$true)]
    [ValidateScript({
        if (($_.Length -eq 4) -and ($_ -notmatch '[a-zA-Z]+')) {
            $true
        } else {
            Throw '-DeadlineTime must be a time string in the format "HHMM", using 24-hour syntax' 
        }
    })]
    [string] $DeadlineTime
)

Set-PSDebug -Strict

# WMI Date format is required here.  See:
# http://technet.microsoft.com/en-us/library/ee156576.aspx
# This is the "UTC Date-Time Format", sometimes called "dtm Format", and referenced in .NET as "dmtfDateTime"
#YYYYMMDDHHMMSS.000000+MMM
#The grouping of six zeros represents milliseconds.  The last cluster of MMM is minute offset from GMT.  
#Wildcards can be used to for parts of the date that are not specified.  In this case, we will not specify
#the GMT offset, thus using "local time".

# Build new deadline date in WMI Date format:
[string] $newDeadline = $DeadlineDate + $DeadlineTime + '00.000000+***'
Write-Verbose "Time to be sent to the Deployment Object: $newDeadline"
 

# Get all current Software Update Group Deployments.
# Note: We use the WMI class "SMS_UpdateGroupAssignment", documented here:
# http://msdn.microsoft.com/en-us/library/hh949604.aspx
# Shares many properties with "SMS_CIAssignmentBaseClass", documented here:
# http://msdn.microsoft.com/en-us/library/hh949014.aspx 
$ADRClientDeployment = @()
$ADRClientDeployment = Get-WmiObject -Namespace "root\sms\site_$($SiteCode)" -Class SMS_UpdateGroupAssignment -ComputerName $SiteServer

# Loop through the assignments setting the new EnforcementDeadline, 
# and commit the change with the Put() method common to all WMI Classes:
# http://msdn.microsoft.com/en-us/library/aa391455(v=vs.85).aspx
  
foreach ($Deployment in $ADRClientDeployment) {

    $DeploymentName = $Deployment.AssignmentName

    Write-Output "Deployment to be modified: `n$($DeploymentName)"
    try {
        $Deployment.EnforcementDeadline = "$newDeadline"
        $Deployment.Put() | Out-Null
        if ($?) {
            Write-Output "`nSuccessfully modified deployment`n"
        }
    }
    catch {
        Write-Output "`nERROR: $($_.Exception.Message)"
    }
}
