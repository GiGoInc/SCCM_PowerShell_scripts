Function Get-SCCMClientHasLocalDP
}
    }
Function Get-SCCMClientHasLocalDP
{
    [CmdletBinding()]
    PARAM (
        [Parameter(Mandatory=$true, HelpMessage="SCCM Server")][Alias("Server","SmsServer")][System.Object] $SccmServer,
        [Parameter(Mandatory=$true, HelpMessage="ClientName",ValueFromPipeline=$true)][String] $clientName,
		[Parameter(Mandatory=$false,HelpMessage="Credentials to use" )][System.Management.Automation.PSCredential] $credential = $null
    )
 
    PROCESS
    {
		$DP = $false
		If ($credential -eq $null)
        {
			$client = Get-SCCMObject -sccmServer $SccmServer -class SMS_R_System -Filter "Name = '$($clientName)'"
			If (-not $client)
            {
				throw "Client does not exist in SCCM. Please check your spelling"
			}
			$Filter = "SMS_R_System.ADSiteName = '$($client.ADSiteName)' and Name IN (Select ServerName FROM SMS_DistributionPointInfo)"
        	$DP = Get-SCCMObject -sccmServer $SccmServer -class SMS_R_System -Filter $Filter
		}
        Else
        {
			$client = Get-SCCMObject -sccmServer $SccmServer -class SMS_R_System -Filter "Name = '$($clientName)'" -credential $credential
			If (-not $client)
            {
				throw "Client does not exist in SCCM. Please check your spelling"
			}
			$Filter = "SMS_R_System.ADSiteName = '$($client.ADSiteName)' and Name IN (Select ServerName FROM SMS_DistributionPointInfo)"
        	$DP = Get-SCCMObject -sccmServer $SccmServer -class SMS_R_System -Filter $Filter -credential $credential
		}
 
		If ($DP)
        {
 			return $true
		}
        Else
        {
			return $false
		}
    }
}
