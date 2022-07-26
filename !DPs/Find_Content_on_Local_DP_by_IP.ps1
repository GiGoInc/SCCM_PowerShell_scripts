Get-Date
# LOAD MODULES
. 'C:\Scripts\!Modules\PackageFromContentLibrary.ps1'
. 'C:\Scripts\!Modules\Invoke-Pingv2.ps1'

########################################################################################
# Functions
    Function Get-ComputerSite($Computer)
    {
       $site = nltest /server:$Computer /dsgetsite 2>$null
       If($LASTEXITCODE -eq 0){ $site[0] }
    }


########################################################################################
# Variables
    $TMPServerList = New-TemporaryFile
    $TMPPingList = New-TemporaryFile
    $TMPUNCOMPLIANTSM01 = New-TemporaryFile
    $DestFolder = 'C:\Temp'
    


########################################################################################
# GET LIST OF SM01 SERVERS
    (Get-ADComputer -Filter {Name -Like "*SM01"}).Name | Set-Content $TMPServerList

# PING LIST OF SM01 SERVERS
    "PC Name,IPv4 Address,Result" | Add-Content $TMPPingList
    Get-Content $TMPServerList | Invoke-Ping | Add-Content $TMPPingList

    $DPIPs | Set-Content 'C:\temp\SCCM_DP_IPs.txt'

Get-Date


########################################################################################
# CHECK CURRENT COMPUTER
    $Computer = 'Computer1'

    $DPIPs = Get-Content $TMPPingList

    # Get only IP enabled adapater
        $NIC = Get-WmiObject -ComputerName $Computer -Class Win32_NetworkAdapterConfiguration -Filter 'ipenabled = "true"' 
        $Index = $NIC.index
        $IPs = $NIC.IPAddress
        ForEach($IP in $IPs)
        {
            $Computer_FirstThree = ($IP.split('.')[0]) + '.' + ($IP.split('.')[1]) + '.' + ($IP.split('.')[2])
            Write-Host "Computer First Three: $Computer_FirstThree" -ForegroundColor Magenta

            # GET LAST OCTET FROM SM01 PING LIST
                ForEach ($Line in $DPIPs)
                {
                    $SM01IP = $Line.split(',')[1]
                    $SM01_FirstThree = ($SM01IP.split('.')[0]) + '.' + ($SM01IP.split('.')[1]) + '.' + ($SM01IP.split('.')[2])
                    Write-Host "SM01 First Three: $SM01_FirstThree" -ForegroundColor Magenta

                    #If ($SM01_FirstThree -eq $Computer_FirstThree)
                    #{
                    #    $Line
                    #}
                }
        }             
    
    
    <#
    Get-CMPackageFromContentLibrary -ContentServer $Server `
                                    -PackageId $PkgID `
                                    -OutputPath $DestFolder
    #>




#$computer = 'G921PC2'
# $Server = 'SCCMSERVER'
# $PkgID = 'SS100043'


########################################################################################
# 
#    Remove-Item $TMPServerList.FullName -Force
#    Remove-Item $TMPPingList.FullName -Force
#   Remove-Item $TMPUNCOMPLIANTSM01.FullName -Force

########################################################################################
$WMIParams = @{
    ComputerName = 'SCCMSERVER'
    Namespace    = 'root\SMS\site_SS1'
}
$Client = Get-WmiObject @WMIParams -Query "select * from sms_r_system where Name='$Computer'"

$Client = Get-WmiObject @WMIParams -Query "SELECT * FROM SMS_R_System WHERE Name='$Computer' AND IPSubnets != ''"
Write-Verbose "Computer '$($Client.Name)', IPSubnets '$($Client.IPSubnets)'"

$Result = Foreach ($S in ($Client.IPSubnets | where {($_ -NE '192.168.1.0') -and ($_ -NE '0.0.0.0') -and ($_ -NE '128.0.0.0') -and ($_ -NE '169.254.0.0') -and ($_ -NE '64.0.0.0')}))
{
    "Check IP '$S'"
    Get-WmiObject @WMIParams -Query "SELECT Displayname, SiteSystems, Value, DefaultSiteCode FROM SMS_Boundary WHERE Value = '$S'"
}

$Result | Select-Object -ExpandProperty SiteSystems -Unique