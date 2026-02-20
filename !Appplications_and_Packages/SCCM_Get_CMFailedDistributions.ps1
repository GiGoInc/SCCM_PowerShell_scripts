<#
    } 
        Else {Write-Warning "No results were returned!"}
<#
    } 
        Else {Write-Warning "No results were returned!"}
<#

.SYNOPSIS
    Checks for failed or incomplete package distributions in ConfigMgr

.DESCRIPTION
    This script checks for any package distributions that are not in the successful state, and return the results either into the console window or by email in an HTML table.
    The following fields are returned:
    - Package Name
    - PackageID
    - Package Type
    - Distribution Point Name
    - Distribution State
    - Status Message
    - Last Update Time
    It can be run as a scheduled task to monitor for failed distributions.  Data is retrieved from WMI on the Site Server.

.PARAMETER SiteCode
    Your ConfigMgr SiteCode

.PARAMETER SiteServer
    Your ConfigMgr Site Server

.PARAMETER SendEmail
    Use this switch to send results by email.  Console output is the default.

.PARAMETER GridView
    Use this switch to output results to Powershell's GridView. Console output is the default.

.PARAMETER From
    If sending email, the From address

.PARAMETER To
    If sending email, the To address

.PARAMETER SmtpServer
    If sending email, the Smtp server name

.PARAMETER Subject
    If sending email, the email subject

.EXAMPLE
    .\Get-CMFailedDistributions.ps1
    Checks for unsuccesful package distributions and returns the results to the console window.

.EXAMPLE
    .\Get-CMFailedDistributions.ps1 -SendEmail
    Checks for unsuccesful package distributions and sends the results by email using the default parameters.

.EXAMPLE
    .\Get-CMFailedDistributions.ps1 -SiteCode XYZ -SiteServer sccmserver02 -SendEmail -To bill.gates@microsoft.com
    Checks for unsuccesful package distributions and sends the results by email using specified parameters.

.NOTES
    Script name: Get-CMFailedDistributions.ps1
    Author:      Trevor Jones
    Contact:     @trevor_smsagent
    DateCreated: 2015-05-12
    Link:        https://smsagent.wordpress.com
    Credits:     MessageIDs from Dan Richings http://www.danrichings.com/?p=166

#>

[CmdletBinding()]
    param
        (
        [Parameter(Mandatory=$False)]
            [string]$SiteCode = 'XX1',
        [Parameter(Mandatory=$False)]
            [string]$SiteServer = 'SERVER',
        [parameter(Mandatory=$False)]
            [switch]$SendEmail,
        [parameter(Mandatory=$False)]
            [switch]$GridView,
        [parameter(Mandatory=$False)]
            [string]$From = "no_reply@DOMAIN.COM",
        [parameter(Mandatory=$False)]
            [string]$To = "SuperUser.LASTNAME@DOMAIN.COM",
        [parameter(Mandatory=$False)]
            [string]$SmtpServer = "XXXXCAS1.DOMAIN.COM",
        [parameter(Mandatory=$False)]
            [string]$Subject = "SCCM DP Report"
        )

#region Functions
function New-Table (
$Title,
$Topic1,
$Topic2,
$Topic3,
$Topic4,
$Topic5,
$Topic6,
$Topic7
)
    {
       Add-Content $msgfile "<style>table {border-collapse: collapse;font-family: ""Trebuchet MS"", Arial, Helvetica, sans-serif;}"
       Add-Content $msgfile "h2 {font-family: ""Trebuchet MS"", Arial, Helvetica, sans-serif;}"
       Add-Content $msgfile "th, td {font-size: 1em;border: 1px solid #1FE093;padding: 3px 7px 2px 7px;}"
       Add-Content $msgfile "th {font-size: 1.2em;text-align: left;padding-top: 5px;padding-bottom: 4px;background-color: #1FE093;color: #ffffff;}</style>"
       Add-Content $msgfile "<h2>$Title</h2>"
       Add-Content $msgfile "<p><table>"
       Add-Content $msgfile "<tr><th>$Topic1</th><th>$Topic2</th><th>$Topic3</th><th>$Topic4</th><th>$Topic5</th><th>$Topic6</th><th>$Topic7</th></tr>"
    }
function New-TableRow (
$col1,
$col2,
$col3,
$col4,
$col5,
$col6,
$col7
)
    {
        Add-Content $msgfile "<tr><td>$col1</td><td>$col2</td><td>$col3</td><td>$col4</td><td>$col5</td><td>$col6</td><td>$col7</td></tr>"
    }
function New-TableEnd {
    Add-Content $msgfile "</table></p>"}
#endregion

# Set WQL Query
$packages = @()
$Query = "
Select PackageID,Name,MessageState,ObjectTypeID,MessageID,LastUpdateDate
from SMS_DistributionDPStatus
where MessageState<>1
order by LastUpdateDate Desc
"

# Get unsuccessful distributions
$Distributions = Get-WmiObject -ComputerName $SiteServer -Namespace root\SMS\site_$SiteCode -Query $Query
foreach ($Distribution in $Distributions)
    {
        # Translate Package Type
        if ($Distribution.ObjectTypeID -eq "2")
            {$Type = "Standard Package"}
        if ($Distribution.ObjectTypeID -eq "14")
            {$Type = "OS Install Package"}
        if ($Distribution.ObjectTypeID -eq "18")
            {$Type = "OS Image Package"}
        if ($Distribution.ObjectTypeID -eq "19")
            {$Type = "Boot Image Package"}
        if ($Distribution.ObjectTypeID -eq "21")
            {$Type = "Device Setting Package"}
        if ($Distribution.ObjectTypeID -eq "23")
            {$Type = "Driver Package"}
        if ($Distribution.ObjectTypeID -eq "24")
            {$Type = "Software Updates Package"}
        if ($Distribution.ObjectTypeID -eq "31")
            {$Type = "Application Content Package"}

        # Translate Distribution State
        if ($Distribution.MessageState -eq "2")
            {$Status = "In Progress"}
        if ($Distribution.MessageState -eq "3")
            {$Status = "Error"}
        if ($Distribution.MessageState -eq "4")
            {$Status = "Failed"}

        # Translate Common MessageIDs
        if ($Distribution.MessageID -eq "2303")
            {$MSGID = "Content was successfully refreshed"}
        if ($Distribution.MessageID -eq "2324")
            {$MSGID = "Failed to access or create the content share"}
        if ($Distribution.MessageID -eq "2330")
            {$MSGID = "Content was distributed to distribution point"}
        if ($Distribution.MessageID -eq "2384")
            {$MSGID = "Content hash has been successfully verified"}
        if ($Distribution.MessageID -eq "2323")
            {$MSGID = "Failed to initialize NAL"}
        if ($Distribution.MessageID -eq "2354")
            {$MSGID = "Failed to validate content status file"}
        if ($Distribution.MessageID -eq "2357")
            {$MSGID = "Content transfer manager was instructed to send content to the distribution point"}
        if ($Distribution.MessageID -eq "2360")
            {$MSGID = "Status message 2360 unknown"}
        if ($Distribution.MessageID -eq "2370")
            {$MSGID = "Failed to install distribution point"}
        if ($Distribution.MessageID -eq "2371")
            {$MSGID = "Waiting for prestaged content"}
        if ($Distribution.MessageID -eq "2372")
            {$MSGID = "Waiting for content"}
        if ($Distribution.MessageID -eq "2375")
            {$MSGID = "Created virtual directories on the defined share or volume on the distribution point succesfully"}
        if ($Distribution.MessageID -eq "2380")
            {$MSGID = "Content evaluation has started"}
        if ($Distribution.MessageID -eq "2381")
            {$MSGID = "An evaluation task is running. Content was added to the queue"}
        if ($Distribution.MessageID -eq "2382")
            {$MSGID = "Content hash is invalid"}
        if ($Distribution.MessageID -eq "2383")
            {$MSGID = "Failed to validate the package on the distribution point. The package may not be present or may be corrupt. Please redistribute it"}
        if ($Distribution.MessageID -eq "2384")
            {$MSGID = "Package has been successfully verified on the distribution point"}
        if ($Distribution.MessageID -eq "2388")
            {$MSGID = "Failed to retrieve the package list on the distribution point. Or the package list in content library doesn't match the one in WMI. Review smsdpmon.log for more information about this failure."}
        if ($Distribution.MessageID -eq "2391")
            {$MSGID = "Failed to connect to remote distribution point"}
        if ($Distribution.MessageID -eq "2397")
            {$MSGID = "Detail will be available after the server finishes processing the messages."}
        if ($Distribution.MessageID -eq "2398")
            {$MSGID = "Content Status not found"}
        if ($Distribution.MessageID -eq "2399")
            {$MSGID = "Successfully completed the installation or upgrade of the distribution point"}
        if ($Distribution.MessageID -eq "8203")
            {$MSGID = "Failed to update package"}
        if ($Distribution.MessageID -eq "8204")
            {$MSGID = "Content is being distributed to the distribution point"}
        if ($Distribution.MessageID -eq "8211")
            {$MSGID = "Package Transfer Manager failed to update the package on the distribution point. Review PkgXferMgr.log for more information about this failure."}

        # Get / Set Additional info
        $PKGID = $Distribution.PackageID
        $LastUPDTime = [System.Management.ManagementDateTimeconverter]::ToDateTime($Distribution.LastUpdateDate)
        $PKG = Get-WmiObject -ComputerName $SiteServer -Namespace root\SMS\site_$SiteCode -Query "Select * from SMS_PackageBaseclass where PackageID = '$PKGID'"

        # Add to a PS object
        $Package = New-Object psobject
        Add-Member -InputObject $Package -MemberType NoteProperty -Name "Package Name" -Value $PKG.Name
        Add-Member -InputObject $Package -MemberType NoteProperty -Name "PackageID" -Value $Distribution.PackageID
        Add-Member -InputObject $Package -MemberType NoteProperty -Name "Package Type" -Value $Type
        Add-Member -InputObject $Package -MemberType NoteProperty -Name "Distribution Point Name" -Value $Distribution.Name
        Add-Member -InputObject $Package -MemberType NoteProperty -Name "Distribution State" -Value $Status
        Add-Member -InputObject $Package -MemberType NoteProperty -Name "Status Message" -Value $MSGID
        Add-Member -InputObject $Package -MemberType NoteProperty -Name "Last Update Time" -Value $LastUPDTime
        $packages += $package
    }

if ($SendEmail)
    {
        # Create Tempfile to store data
        $msgfile = "$env:TEMP\mailmessage.txt"
        New-Item $msgfile -ItemType file -Force | Out-Null

        # Populate HTML table
        if ($packages -ne $null ) {
            $Params = @{
                Title = "ConfigMgr Failed Package Distributions"
                Topic1 = "Package Name"
                Topic2 = "PackageID"
                Topic3 = "Package Type"
                Topic4 = "Distribution Point Name"
                Topic5 = "Distribution State"
                Topic6 = "Status Message"
                Topic7 = "Last Update Time"
                }
        New-Table @Params
        foreach ($item in $packages )
            {
                $params = @{
                col1 = $item.'Package Name'
                col2 = $item.PackageID
                col3 = $item.'Package Type'
                col4 = $item.'Distribution Point Name'
                col5 = $item.'Distribution State'
                col6 = $item.'Status Message'
                col7 = $item.'Last Update Time'
                }
                New-TableRow @Params
            }
        New-TableEnd

        # Send email or return results
        $mailbody = Get-Content $msgfile
        Send-MailMessage -From $From -To $To -SmtpServer $SmtpServer -Subject $Subject -Body "$mailbody" -BodyAsHtml

        # Delete tempfile
        Remove-Item $msgfile
        }
        Else {Write-Warning "No results were returned!"}
    }

if ($GridView)
    {
        if ($packages -ne $null)
            {$packages | Out-GridView -Title "ConfigMgr Failed Package Distributions"}
        Else {Write-Warning "No results were returned!"}
    }

If (!$GridView -and !$SendEmail)
    {
        if ($packages -ne $null)
            {$packages | ft -AutoSize}
        Else {Write-Warning "No results were returned!"}
    } 
