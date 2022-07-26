#requires -version 3.0
<#
.Synopsis
   Takes Boundary Objects as input and adds a propety to show the IP range they cover
.DESCRIPTION
   The function takes SMS_Boundary Objects either from a Get-WMIObject or Get-CMBounday cmdlet or simply IPAddress along with mask.
   When the SMS_Boundary Object is an input Note Properties are added for NetworkAddress, BroadCastAddress & IPRange.
   Note - This only works if the Objects have the property Value set something in this format 10.1.1.0/24. Subnet Mask value should be there.

   When the IP Address along with Mask is an input a Custom Object is generated with the information.
.EXAMPLE
    Convert-IPSUbnetToIPRangeBoundary -IP 10.1.1.0 -mask 24

    NetworkIP                           BroadcastIP                         HostMin                             HostMax                            
    ---------                           -----------                         -------                             -------                            
    10.1.1.0                            10.1.1.255                          10.1.1.1                            10.1.1.254                         

    One can use this to generate the standalone data like this

.EXAMPLE
    Convert-IPSUbnetToIPRangeBoundary -IP 10.1.1.0 -mask 255.255.0.0

    NetworkIP                           BroadcastIP                         HostMin                             HostMax                            
    ---------                           -----------                         -------                             -------                            
    10.1.0.0                            10.1.255.255                        10.1.0.1                            10.1.255.254                       

    

.EXAMPLE
   Get-WmiObject  -Class SMS_Boundary -Namespace root\SMS\site_DEX -ComputerName dexsccm | Convert-IPSUbnetToIPRangeBoundary 
   
    NetworkAddress   : 10.1.0.0
    BroadCastAddress : 10.1.255.255
    HostMin          : 10.1.0.1
    HostMax          : 10.1.255.254
    IPRange          : 10.1.0.1  - 10.1.255.254
    __GENUS          : 2
    __CLASS          : SMS_Boundary
    __SUPERCLASS     : SMS_BaseClass
    __DYNASTY        : SMS_BaseClass
    __RELPATH        : SMS_Boundary.BoundaryID=16778244
    __PROPERTY_COUNT : 12
    __DERIVATION     : {SMS_BaseClass}
    __SERVER         : DEXSCCM
    __NAMESPACE      : root\SMS\site_DEX
    __PATH           : \\DEXSCCM\root\SMS\site_DEX:SMS_Boundary.BoundaryID=16778244
    BoundaryFlags    : 0
    BoundaryID       : 16778244
    BoundaryType     : 0
    CreatedBy        : DEXTER\Administrator
    CreatedOn        : 20140624191406.000000+***
    DefaultSiteCode  : 
    DisplayName      : TestBoundary3
    GroupCount       : 0
    ModifiedBy       : DEXTER\Administrator
    ModifiedOn       : 20140705170841.000000+***
    SiteSystems      : 
    Value            : 10.1.1.0/16
    PSComputerName   : DEXSCCM

    One can pipe the result of Get-WMIObject to pipe SMS_Boundary WMI Instances to the function. 
    It will only process the IPSubnet Boundaries and add the 3 new note properties to it.
.EXAMPLE
    Get-CMBoundary | Convert-IPSUbnetToIPRangeBoundary -Verbose
    VERBOSE: [PROCESS] Processing Boundary Dexter AD Site
    VERBOSE: [PROCESS] Dexter AD Site is not a IPSubnet type Boundary.Skipping it
    VERBOSE: [PROCESS] Processing Boundary testBoundary1
    VERBOSE: [PROCESS] testBoundary1 is not a IPSubnet type Boundary.Skipping it
    VERBOSE: [PROCESS] Processing Boundary testBoundary2
    VERBOSE: [PROCESS] testBoundary2 is not a IPSubnet type Boundary.Skipping it
    VERBOSE: [PROCESS] Processing Boundary TestBoundary3
    VERBOSE: [PROCESS] TestBoundary3 is a IPSubnet type Boundary. Processing it
    VERBOSE: Function Starting
    VERBOSE: Inside CIDR Parameter Set
    VERBOSE: Function Ending


    NetworkAddress   : 10.1.0.0
    BroadCastAddress : 10.1.255.255
    HostMin          : 10.1.0.1
    HostMax          : 10.1.255.254
    IPRange          : 10.1.0.1  - 10.1.255.254
    BoundaryFlags    : 0
    BoundaryID       : 16778244
    BoundaryType     : 0
    CreatedBy        : DEXTER\Administrator
    CreatedOn        : 6/24/2014 7:14:06 PM
    DefaultSiteCode  : 
    DisplayName      : TestBoundary3
    GroupCount       : 0
    ModifiedBy       : DEXTER\Administrator
    ModifiedOn       : 7/5/2014 5:08:41 PM
    SiteSystems      : 
    Value            : 10.1.1.0/16

    VERBOSE: [PROCESS] Processing Boundary Overlapping Boundary
    VERBOSE: [PROCESS] Overlapping Boundary is not a IPSubnet type Boundary.Skipping it

    Run the Get-CMBoundary cmdlet and pipe it to the Function it will process the IPSubnet Boundary & add the necessary properties.
.INPUTS
   System.Object[] #But later checked for only SMS_Boundary Objects 
.OUTPUTS
   System.Management.AUtomation.PSCustomObject[]
.NOTES
   The piping of boundary Objects (From the Get-CMBoundary & Get-WMIObject) only works if the Value property has the mask value.
   Author - DexterPOSH
   Idea by - Nickolaj Andersen
.LINK
    http://dexterposh.blogspot.com/2014/07/powershell-sccm-2012-boundaries.html
#>
function Convert-IPSUbnetToIPRangeBoundary
{
    [CmdletBinding(DefaultParameterSetName='Boundary')]
    [OutputType([PSObject[]])]
    Param
    (
        # Pipe in the SMS_Boundary instances
        [Parameter(Mandatory, 
                   ValueFromPipeline,
                   ParameterSetName='Boundary')]
        [ValidateNotNullOrEmpty()]      
        [System.Object[]]$Boundary,

        # Specify the IP Address
        [Parameter(ParameterSetName='IPRange', Mandatory)]
        [string]$IP,

        #Specify the Mask
        [Parameter(ParameterSetName='IPRange',Mandatory)]
        [string]$mask
    )

    Begin
    {
    
    function Get-ValidIPAddressinRange
    {
    <#
    .Synopsis
       Takes the IP Address and the Mask value as input and returns all possible IP
    .DESCRIPTION
       The Function takes the IPAddress and the Subnet mask value to generate list of all possible IP addresses in the Network.
   
    .EXAMPLE
        Specify the IPaddress in the CIDR notation
        PS C:\> Get-IPAddressinNetwork -IP 10.10.10.0/24
    .EXAMPLE
       Specify the IPaddress and mask separately (Non-CIDR notation)
        PS C:\> Get-IPAddressinNetwork -IP 10.10.10.0 -Mask 24
    .EXAMPLE
       Specify the IPaddress and mask separately (Non-CIDR notation)
        PS C:\> Get-IPAddressinNetwork -IP 10.10.10.0 -Mask 255.255.255.0
    .INPUTS
       System.String
    .OUTPUTS
       [System.Net.IPAddress[]]
    .NOTES
       Credits given to the original post in LINK
    .LINK
        http://www.indented.co.uk/index.php/2010/01/23/powershell-subnet-math/

    #>
        [CmdletBinding(DefaultParameterSetName='CIDR', 
                      SupportsShouldProcess=$true, 
                      ConfirmImpact='low')]
        [OutputType([ipaddress[]])]
        Param
        (
            # Param1 help description
            [Parameter(Mandatory=$true, 
                       ValueFromPipeline=$true,
                       ValueFromPipelineByPropertyName=$true, 
                       ValueFromRemainingArguments=$false 
                        )]
            [ValidateScript({
                            if ($_.contains("/"))
                                { # if the specified IP format is -- 10.10.10.0/24
                                    $temp = $_.split('/')   
                                    If (([ValidateRange(0,32)][int]$subnetmask = $temp[1]) -and ([bool]($temp[0] -as [ipaddress])))
                                    {
                                        Return $true
                                    }
                                }                           
                            else
                            {# if the specified IP format is -- 10.10.10.0 (along with this argument to Mask is also provided)
                                if ( [bool]($_ -as [ipaddress]))
                                {
                                    return $true
                                }
                                else
                                {
                                    throw "IP validation failed"
                                }
                            }
                            })]
            [Alias("IPAddress","NetworkRange")] 
            [string]$IP,

            # Param2 help description
            [Parameter(ParameterSetName='Non-CIDR')]
            [ValidateScript({
                            if ($_.contains("."))
                            { #the mask is in the dotted decimal 255.255.255.0 format
                                if (! [bool]($_ -as [ipaddress]))
                                {
                                    throw "Subnet Mask Validation Failed"
                                }
                                else
                                {
                                    return $true 
                                }
                            }
                            else
                            { #the mask is an integer value so must fall inside range [0,32]
                               # use the validate range attribute to verify it falls under the range
                                if ([ValidateRange(0,32)][int]$subnetmask = $_ )
                                {
                                    return $true
                                }
                                else
                                {
                                    throw "Invalid Mask Value"
                                }
                            }
                        
                             })]
            [string]$mask
        )

        Begin
        {
            Write-Verbose "Function Starting"
            #region Function Definitions
        
            Function ConvertTo-DecimalIP {
              <#
                .Synopsis
                  Converts a Decimal IP address into a 32-bit unsigned integer.
                .Description
                  ConvertTo-DecimalIP takes a decimal IP, uses a shift-like operation on each octet and returns a single UInt32 value.
                .Parameter IPAddress
                  An IP Address to convert.
              #>
   
              [CmdLetBinding()]
              [OutputType([UInt32])]
              Param(
                [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
                [Net.IPAddress]$IPAddress
              )
 
              PROCESS 
              {
                $i = 3; $DecimalIP = 0;
                $IPAddress.GetAddressBytes() | ForEach-Object { $DecimalIP += $_ * [Math]::Pow(256, $i); $i-- }
 
                Write-Output $([UInt32]$DecimalIP)
              }
            }

            Function ConvertTo-DottedDecimalIP 
            {
            <#
            .Synopsis
                Returns a dotted decimal IP address from either an unsigned 32-bit integer or a dotted binary string.
            .Description
                ConvertTo-DottedDecimalIP uses a regular expression match on the input string to convert to an IP address.
            .Parameter IPAddress
                A string representation of an IP address from either UInt32 or dotted binary.
            #>
 
            [CmdLetBinding()]
            [OutputType([ipaddress])]
            Param(
            [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True)]
            [String]$IPAddress
                  )
   
                  PROCESS
                  {
                    Switch -RegEx ($IPAddress) 
                    {
                      "([01]{8}\.){3}[01]{8}" 
                      {
                        Return [String]::Join('.', $( $IPAddress.Split('.') | ForEach-Object { [Convert]::ToUInt32($_, 2) } ))
                      }

                      "\d" 
                      {
                        $IPAddress = [UInt32]$IPAddress
                        $DottedIP = $( For ($i = 3; $i -gt -1; $i--) {
                          $Remainder = $IPAddress % [Math]::Pow(256, $i)
                          ($IPAddress - $Remainder) / [Math]::Pow(256, $i)
                          $IPAddress = $Remainder
                         } )
        
                        Write-Output $([ipaddress]([String]::Join('.', $DottedIP)))
                      }

                      default 
                      {
                        Write-Error "Cannot convert this format"
                      }
                    }
                  }
            }
             #endregion Function Definitions
        }

        Process
        {
            Switch($PSCmdlet.ParameterSetName)
            {
                "CIDR"
                {
                    Write-Verbose "Inside CIDR Parameter Set"
                    $temp = $ip.Split("/")
                    $ip = $temp[0]
                     #The validation attribute on the parameter takes care if this is empty
                    $mask = ConvertTo-DottedDecimalIP ([Convert]::ToUInt32($(("1" * $temp[1]).PadRight(32, "0")), 2))                            
                }

                "Non-CIDR"
                {
                    Write-Verbose "Inside Non-CIDR Parameter Set"
                    If (!$Mask.Contains("."))
                      {
                        $mask = ConvertTo-DottedDecimalIP ([Convert]::ToUInt32($(("1" * $mask).PadRight(32, "0")), 2))
                      }

                }
            }
            #now we have appropraite dotted decimal ip's in the $ip and $mask
            $DecimalIP = ConvertTo-DecimalIP -IPAddress $ip
            $DecimalMask = ConvertTo-DecimalIP $Mask

            $Network = $DecimalIP -BAnd $DecimalMask
            $Broadcast = $DecimalIP -BOr ((-BNot $DecimalMask) -BAnd [UInt32]::MaxValue)
            
            [pscustomobject]@{
                                NetworkIP=( ConvertTo-DottedDecimalIP -IPAddress $Network);
                                BroadcastIP=(ConvertTo-DottedDecimalIP -IPAddress $Broadcast);
                                HostMin = (ConvertTo-DottedDecimalIP -IPAddress ($Network + 1));
                                HostMax = (ConvertTo-DottedDecimalIP -IPAddress ($Broadcast -1))
                            }
            <# uncomment the below if you want the all the IP Addresses...I just need Network & Broadcast
            For ($i = $($Network + 1); $i -lt $Broadcast; $i++) {
                ConvertTo-DottedDecimalIP $i
                    }
            #>
             
                       
            
        }
        End
        {
            Write-Verbose "Function Ending"
        }
    }


    }
    Process
    {
        Switch -Exact ($PSCmdlet.ParameterSetName)
        {

            "Boundary"
            {
                foreach ($CMBoundary in $Boundary)
                {
                    #now the input can be piped from either  
                    Write-Verbose -Message "[PROCESS] Processing Boundary $($CMBoundary.DisplayName)"
                    if ((($CMBoundary.__CLASS -eq 'SMS_Boundary') -or ($CMBoundary.ObjectClass -eq 'SMS_Boundary'))-and ($CMBoundary.BoundaryType -eq 0 ))
                    {
                        #All fine if correct instance of the boundary is specified  
                        Write-Verbose -Message "[PROCESS] $($CMBoundary.DisplayName) is a IPSubnet type Boundary. Processing it"
                        #calculate the IP range
                        $Range = Get-ValidIPAddressinRange -IP $CMBoundary.Value 

                        #Add the extra information as a note property and put it in pipeline
                        Add-Member -InputObject $CMBoundary -MemberType NoteProperty -Name NetworkAddress -Value ($Range.NetworkIP) 
                        Add-Member -InputObject $CMBoundary -MemberType NoteProperty -Name BroadCastAddress -Value ($Range.BroadCastIP) 
                        Add-Member -InputObject $CMBoundary -MemberType NoteProperty -Name HostMin -Value ($Range.HostMin) 
                        Add-Member -InputObject $CMBoundary -MemberType NoteProperty -Name HostMax -Value ($Range.HostMax) 
                        Add-Member -InputObject $CMBoundary -MemberType NoteProperty -Name IPRange -Value "$($Range.HostMin)  - $($Range.HostMax)" -PassThru
                    }
                    else
                    {
                        Write-Verbose -Message "[PROCESS] $($CMBoundary.DisplayName) is not a IPSubnet type Boundary.Skipping it"
                    }
                }
                               
            }

            "IPRange"
            {
                Get-ValidIPAddressinRange -IP $IP -mask $mask 

            }

                
        }
    }
    End
    {
    }
}