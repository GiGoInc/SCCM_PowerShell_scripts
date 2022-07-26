Write-Host '2017-03-29 --- This script does not work right, possibly needs to be run from the server or in the SCCM space?' -ForegroundColor Red

break

<#
Purpose: Finds out if content has been distributed to DP or DP groups
Author: David O'Brien, david.obrien@gmx.de
#>


<#
[CmdletBinding()]
param
(
[parameter(
	Position = 0, 
	Mandatory=$true )
	] 
	[Alias("SMS")]
    [ValidateScript({
        $ping = New-Object System.Net.NetworkInformation.Ping
        $ping.Send("$_", 5000)})]
	[ValidateNotNullOrEmpty()]
	[string]$SMSProvider = 'SCCMSERVER'
)


Function Get-SiteCode
{
    $wqlQuery = “SELECT * FROM SMS_ProviderLocation”
    $a = Get-WmiObject -Query $wqlQuery -Namespace “root\sms” -ComputerName $SMSProvider
    $a | ForEach-Object {
        if($_.ProviderForLocalSite)
            {
                $script:SiteCode = $_.SiteCode
            }
    }
return $SiteCode
}

$SiteCode = Get-SiteCode

[array]$AssignedToDPGroup = @()
[array]$AssignedToDP = @()
$i = $null
$Content = $null

$Content = Get-WmiObject -Class SMS_PackageContentServerInfo -Namespace Root\SMS\Site_$SiteCode -ComputerName $SMSProvider

foreach ($i in $Content)
{
    if ($i.ContentServerType -eq 2)
        {
           [array]$AssignedToDPGroup += $i
        }
    else 
        {
            [array]$AssignedToDP += $i
        }
}

$Objects = Compare-Object -ReferenceObject $AssignedToDPGroup -DifferenceObject $AssignedToDP -Property ObjectID -PassThru | select -Unique -Property ObjectID, PackageType

if ([string]::IsNullOrEmpty($Objects))
{
    Write-Verbose "No Objects in this site are distributed to DPs only." 
}
else 
{
    Write-Verbose "The following Objects are distributed to DPs only. Consider distributing them to DP Groups."
    foreach ($Object in $Objects)
        {
            switch ($Object.PackageType)
                {
                    0 { 
                        Write-Host "Software Package: " -ForegroundColor Magenta
                        (Get-WmiObject -Class SMS_ObjectName -Namespace root\SMS\Site_$SiteCode -Filter "ObjectKey = '$($Object.ObjectID)'" | Where-Object {$_.ObjectTypeID -ne 9} ).Name
                      }
                    3 {
                        Write-Host "Driver Package: " -ForegroundColor Magenta
                        (Get-WmiObject -Class SMS_ObjectName -Namespace root\SMS\Site_$SiteCode -Filter "ObjectKey = '$($Object.ObjectID)'" | Where-Object {$_.ObjectTypeID -ne 9} ).Name
                        }
                    4 {
                        Write-Host "Task Sequence Package: " -ForegroundColor Magenta
                        (Get-WmiObject -Class SMS_ObjectName -Namespace root\SMS\Site_$SiteCode -Filter "ObjectKey = '$($Object.ObjectID)'" | Where-Object {$_.ObjectTypeID -ne 9} ).Name
                        }
                    5 {
                        Write-Host "Software Update Package: " -ForegroundColor Magenta
                        (Get-WmiObject -Class SMS_ObjectName -Namespace root\SMS\Site_$SiteCode -Filter "ObjectKey = '$($Object.ObjectID)'" | Where-Object {$_.ObjectTypeID -ne 9} ).Name
                        }
                    6 {
                        Write-Host "Content Package: " -ForegroundColor Magenta
                        (Get-WmiObject -Class SMS_ObjectName -Namespace root\SMS\Site_$SiteCode -Filter "ObjectKey = '$($Object.ObjectID)'" | Where-Object {$_.ObjectTypeID -ne 9} ).Name
                        }
                    8 {
                        #Write-Host "Device Setting Package: " -ForegroundColor Magenta
                        #(Get-WmiObject -Class SMS_ObjectName -Namespace root\SMS\Site_$SiteCode -Filter "ObjectKey = '$($Object.ObjectID)'" | Where-Object {$_.ObjectTypeID -ne 9} ).Name
                        }
                    257 {
                        Write-Host "Image Package: " -ForegroundColor Magenta
                        (Get-WmiObject -Class SMS_ObjectName -Namespace root\SMS\Site_$SiteCode -Filter "ObjectKey = '$($Object.ObjectID)'" | Where-Object {$_.ObjectTypeID -ne 9} ).Name
                        }
                    258 {
                        Write-Host "Boot Image Package: " -ForegroundColor Magenta
                        (Get-WmiObject -Class SMS_ObjectName -Namespace root\SMS\Site_$SiteCode -Filter "ObjectKey = '$($Object.ObjectID)'" | Where-Object {$_.ObjectTypeID -ne 9} ).Name
                        }
                    259 {
                        Write-Host "Operating System Package: " -ForegroundColor Magenta
                        (Get-WmiObject -Class SMS_ObjectName -Namespace root\SMS\Site_$SiteCode -Filter "ObjectKey = '$($Object.ObjectID)'" | Where-Object {$_.ObjectTypeID -ne 9} ).Name
                        }
                    512 {
                        Write-Host "Application Package: " -ForegroundColor Magenta
                        (Get-WmiObject -Class SMS_ObjectName -Namespace root\SMS\Site_$SiteCode -Filter "ObjectKey = '$($Object.ObjectID)'" | Where-Object {$_.ObjectTypeID -ne 9} ).Name
                        }
                }

        }
}
#>