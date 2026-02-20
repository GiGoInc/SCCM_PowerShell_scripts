Function Get-IPAddressBoundary 
Get-IPAddressBoundary -SiteServer SERVER -IPAddress 10.194.2.202

Function Get-IPAddressBoundary 
{
<#
.Synopsis
    Gets which Boundary an IP Address belongs to in ConfigMgr.
.DESCRIPTION
    The Function will iterate over the boundaries and get which particular Boundary that falls in.
.EXAMPLE
    Get-IPAddressBoundary -SiteServer dexsccm -IPAddress 10.1.1.110


    IPAddress     : 10.1.1.110
    BoundaryFlags : 0
    BoundaryID    : 16778243
    BoundaryType  : 3
    DisplayName   : testBoundary2
    CreatedBy     : DEXTER\Administrator
    ModifiedBy    : DEXTER\Administrator
    Date Created  : 6/24/2014 7:14:05 PM
    Date Modified : 6/24/2014 7:14:05 PM
.EXAMPLE
    Get-IPAddressBoundary -SiteServer dexsccm -IPAddress 10.1.1.99 


    IPAddress     : 10.1.1.99
    BoundaryFlags : 0
    BoundaryID    : 16778242
    BoundaryType  : 3
    DisplayName   : testBoundary1
    CreatedBy     : DEXTER\Administrator
    ModifiedBy    : DEXTER\SMSadmin
    Date Created  : 6/24/2014 7:14:05 PM
    Date Modified : 6/25/2014 3:48:15 AM

    IPAddress     : 10.1.1.99
    BoundaryFlags : 0
    BoundaryID    : 16778245
    BoundaryType  : 3
    DisplayName   : Overlapping Boundary
    CreatedBy     : DEXTER\SMSadmin
    ModifiedBy    : DEXTER\SMSadmin
    Date Created  : 6/26/2014 5:18:25 PM
    Date Modified : 6/26/2014 5:18:25 PM

    In this example the Boundary 10.1.1.99 falls under two boundaries
.LINK
    http://www.scconfigmgr.com/2014/04/15/check-if-an-ip-address-is-within-an-ip-range-boundary-in-configmgr-2012/
.NOTES
    Author - Nickolaj Andersen
    Modified by - DexterPOSH
#>
[CmdletBinding()]
param(
    #specify the SCCM server with SMS namespace provider installed
    [parameter(Mandatory=$true)]
    $SiteServer,

    #Input the IPAddresses to check 
    [parameter(Mandatory=$true)]
    [string[]]$IPAddress
)

BEGIN 
{
    Write-Verbose -Message "[BEGIN] Starting the Function"
    TRY
    {
        Write-Verbose -Message "[BEGIN] checking if the $SiteServer has SMS Provider for local site"
        #Query if the SiteServer specifed has the SMS Provider for the local site on it
        $sccmProvider = Get-CimInstance -query "select * from SMS_ProviderLocation where ProviderForLocalSite = true" -Namespace "root\sms" -ComputerName $SiteServer -ErrorAction Stop
        $Splits = $sccmProvider.NamespacePath -split "\\", 4

        Write-Verbose -Message "[BEGIN] Trying to get the IP Range Boundaries"
        #get the Boundaries
        $Boundaries = Get-WmiObject -Namespace ($Splits[3]) -Class SMS_Boundary -Filter "BoundaryType = 3" -ComputerName $SiteServer -ErrorAction stop
        #Closure / Lambda in PowerShell
        $parse = {param($IP) $temp= [System.Net.IPAddress]::Parse($IP).GetAddressBytes();[Array]::Reverse($temp) ; [System.BitConverter]::ToUInt32($temp,0) }
    }
    CATCH
    {
        Write-Warning -Message "[BEGIN] Something went wrong"
        throw $_.Exception
    }
    
}
PROCESS
{
    foreach ($IP in $IPAddress)
    {
        Write-Verbose -Message "[PROCESS] Processing the IPAddress $IP"
        $Boundaries | ForEach-Object {
            
            Write-Verbose -Message "[PROCESS] Processing the Boundary $($_.DisplayName)"
            $IPStartRange,$IPEndRange = $_.Value.Split("-") 
        
            $ParseIP = & $parse $IP
      
            $ParseStartIP = & $parse $IPStartRange
        
            $ParseEndIP = & $parse $IPEndRange
               
            if (($ParseStartIP -le $ParseIP) -and ($ParseIP -le $ParseEndIP)) 
            {
                Write-Verbose -Message "$IP falls in the boundary $($_.DisplayName)"
                Add-Member -InputObject $_ -MemberType NoteProperty -Name IPAddress -Value $IP -PassThru |
                     select -Property IPAddress,Boundary*,DisplayName,*by,
                                @{Name="Date Created";E={[System.Management.ManagementDateTimeConverter]::ToDateTime($_.createdon)}},
                                @{Name="Date Modified";E={[System.Management.ManagementDateTimeConverter]::ToDateTime($_.ModifiedOn)}} 
                            
            } #end if
        }#end Foreach-Object Boundaries
    
    }#end Foreach IP address

}#end PROCESS

END
{
    Write-Verbose -Message "[END] Ending the Function"
}

}



Get-IPAddressBoundary -SiteServer SERVER -IPAddress 10.194.2.202
