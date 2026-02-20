Function Remove-SCCMDPContent


Function Remove-SCCMDPContent
{
<#
.Synopsis
    Function to Remove Packages from the DP
.DESCRIPTION
    THis Function will connect to the SCCM Server SMS namespace and then remove the Package IDs
    passed to the Function from the specified DP name.
.EXAMPLE
    PS> Remove-SCCMDPContent -PackageID DEX123AB,DEX145CD -DPname DexDP -Computername DexSCCMServer  

    This will remove the Packages with Package IDs [ DEX123AB,DEX145CD] from the Distribution Point "DexDP".
.INPUTS
    System.String[]
.OUTPUTS
    System.Management.Automation.PSCustomObject
.NOTES
    Author - DexterPOSH (Deepak Singh Dhami)

#>

    [CmdletBinding()]
    [OutputType([PSObject])]
    Param
    (
        # Specify the Package IDs which need to be removed from the DP
        [Parameter(Mandatory,
                   ValueFromPipelineByPropertyName,
                   Position=0)]
        [string[]]$PackageID,

        # Pass the DP name where cleanup is to be done
        [Parameter(Mandatory=$true)]
        [String]$DPName,

        #Supply the SCCM Site Server hosting SMS Namespace Provider
        [Parameter()]
        [Alias("SCCMServer")]
        [String]$ComputerName
    )

    Begin
    {
        Write-Verbose -Message "[BEGIN]"
        try
        {
           
            $sccmProvider = Get-WmiObject -query "select * from SMS_ProviderLocation where ProviderForLocalSite = true" -Namespace "root\sms" -computername $ComputerName -errorAction Stop
            # Split up the namespace path
            $Splits = $sccmProvider.NamespacePath -split "\\", 4
            Write-Verbose "Provider is located on $($sccmProvider.Machine) in namespace $($splits[3])"
 
            # Create a new hash to be passed on later
            $hash= @{"ComputerName"=$ComputerName;"NameSpace"=$Splits[3];"Class"="SMS_DistributionPoint";"ErrorAction"="Stop"}
            
            #add the filter to get the packages there in the DP only
            $hash.Add("Filter","ServerNALPath LIKE '%$DPname%'")

            
        }
        catch
        {
            Write-Warning "Something went wrong while getting the SMS ProviderLocation"
            throw $_.Exception
        }
    }
    Process
    {
        
            
            Write-Verbose -Message "[PROCESS] Working to remove packages from DP --> $DPName  "
            
            #get all the packages in the Distribution Point
            $PackagesINDP = Get-WmiObject @hash
            
            #Filter the packages based on the PackageID
            $RemovePackages = $PackagesINDP | where {$PackageID -contains $_.packageid   }
            
            
            $Removepackages | ForEach-Object -Process { 
                try 
                {
                    Remove-WmiObject  -InputObject $_  -ErrorAction Stop -ErrorVariable WMIRemoveError 
                    Write-Verbose -Message "Removed $($_.PackageID) from $DPname"
                    [pscustomobject]@{"DP"=$DPname;"PackageId"=$($_.PackageID);"Action"="Removed"}
                                                                 
                }
                catch
                {
                    Write-Warning "[PROCESS] Something went wrong while removing the Package  from $DPname"
                    throw $_.exception
                }
            }#End Foreach-Object
            
        }#End Process
    End
    {
        Write-Verbose "[END] Ending the Function"
    }
}

# UPDATE THESE VARIABLES FOR YOUR ENVIRONMENT
[string]$SiteServer = "SERVER.DOMAIN.COM"
[string]$SiteCode = "XX1"

# Get all valid packages from the primary site server
$Namespace = "root\SMS\Site_" + $SiteCode

Import-Module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')
Set-Location -Path "$(Get-PSDrive -PSProvider CMSite):\" -ErrorAction Stop

# Get all distribution points
Write-Host "Getting all valid distribution points... " -NoNewline
$DistributionPoints = Get-WMIObject -ComputerName $SiteServer -Namespace $Namespace -Query "select * from SMS_DistributionPointInfo where ResourceType = 'Windows NT Server'"
Write-Host ([string]($DistributionPoints.count) + " distribution points found.")
Write-Host ""



ForEach ($DP in $DistributionPoints.name)
{
    $Failures = Get-WmiObject -ComputerName 'SERVER' -Namespace root\sms\site_$SiteCode -Class sms_packagestatusDistPointsSummarizer | Where-Object {$_.State -EQ 3 -or $_.State -eq 8} | Where-Object SourceNALPath -Match $DP
    Write-Host "Found $($Failures.count) failed packages on $DP"

    Write-Host "`nAre you sure you want to remove " -NoNewline -ForegroundColor Red
    Write-Host "$($Failures.count) " -ForegroundColor Yellow -NoNewline
    Write-Host "failed content items from " -NoNewline -ForegroundColor Red 
    Write-Host "$DP " -NoNewline -ForegroundColor Yellow
    Write-Host "???`n" -ForegroundColor Red
    Read-Host -Prompt "Press any key to continue or CTRL+C to quit"

    ForEach ($Failure in $Failures)
    {
        $FailedPackageID = $Failure.PackageID
        Remove-SCCMDPContent -PackageID $FailedPackageID -DPname $DP -Computername $SiteServer
    }
}




