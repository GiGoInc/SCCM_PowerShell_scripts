<#
#>
}
<#
.Synopsis
   Get deployment status of application
.DESCRIPTION
   By querying the SCCM WMI class of "SMS_AppDeploymentAssetDetails", can obtain the status of a deployment.
   Adding the application name and the collection of which the application was targeted, status results can be obtained.
   A filter is set for the 5 status results which the MSDN documentation stats are avaiable.
.LINK   
   Please see 'https://msdn.microsoft.com/en-us/library/hh948459.aspx' for the class details of "SMS_AppDeploymentAssetDetails"
.EXAMPLES
   5 examples available:
   Get-DeploymentStatus -AppName 'Name of Application' -Collection 'Targeted collection of deployment' -Status Success
   Get-DeploymentStatus -AppName 'Name of Application' -Collection 'Targeted collection of deployment' -Status InProgress
   Get-DeploymentStatus -AppName 'Name of Application' -Collection 'Targeted collection of deployment' -Status RequirementsNotMet
   Get-DeploymentStatus -AppName 'Name of Application' -Collection 'Targeted collection of deployment' -Status Unknown
   Get-DeploymentStatus -AppName 'Name of Application' -Collection 'Targeted collection of deployment' -Status error
.CREATOR
   By Graham Beer
.VERSION
   1.0
#>

$SubScript = {
<#
.Synopsis
This script is intended to be called by another script with a list of machinenames, which will add a header and build a CSV file.
The output is required to be a single line of information per computername, so it can be passed as an object to Invoke-Parallel.ps1

The data follows comma separated order:
PC Name,Online,PC Name,Model Name,Loggedon User,Operating System,OS Type,Serial,Days Up,Hours up,Minutes Up

.Example
PS C:> .\Workstation_LoggedOn_Users--bsub.ps1 -computer Computer1
Computer1,Yes,Computer1,Desktop - Dell Inc. OptiPlex 9020,DOMAIN\user1,Microsoft Windows 7 Enterprise ,x64-based PC,Computer1,3,20,52
#>

[CmdletBinding()]
param(
    # Support for multiple computers from the pipeline
    [Parameter(Mandatory=$True,
    ValueFromPipeline=$True,
    ValueFromPipelineByPropertyName=$True,
    HelpMessage='Type in computer name and press Enter to execute')]
    [string]$computer,

# Switch to turn on Error Logging
[Switch]$ErrorLog,
[String]$LogFile = 'C:\Temp\Workstation_LoggedOn_Users_errorlog.txt',
$command=$nothing
)


If (Test-Connection $computer -count 1 -quiet -BufferSize 16)
{
    #Create an empty dynamic array
    $Output = @()
################################################################################################################
################################################################################################################
    # Try-Catch block starts
    $ErrorActionPreference = 'Stop'
    Try { 
        $IPAddress = ([System.Net.Dns]::GetHostByName($computer).AddressList[0]).IpAddressToString
        $System = gwmi -computer $computer Win32_ComputerSystem  
            $OS = gwmi -computer $computer Win32_OperatingSystem 
           $Enc = gwmi -computer $computer Win32_BIOS            
          $Disk = gwmi -computer $computer Win32_LogicalDisk  
        $MachineType = (gwmi -computer $computer -Class win32_systemenclosure).chassistypes     }
    Catch
    {
        If ( $IPAddress -eq $Null) { $IPAddress = 'N-A' } Else {}
        If ( $System -eq $Null) { $System = 'N-A'} Else {}
        If ( $OS -eq $Null) { $OS = 'N-A'    } Else {}
        If ( $Enc -eq $Null) { $Enc = 'N-A'   } Else {}
        If ( $Disk -eq $Null) { $Disk = 'N-A'  } Else {}
        If ( $MachineType -eq $Null) { $MachineType = 'N-A' } Else {}
    }
    Finally { $ErrorActionPreference = 'SilentlyContinue' }
################################################################################################################
################################################################################################################
    $ErrorActionPreference = 'Stop'
    Try { 
        $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computer) 
        $RegKey = $Reg.OpenSubKey("SOFTWARE\Microsoft\Windows NT\CurrentVersion")
    } Catch { $Reg = 'N-A';$RegKey = 'N-A' }
    Finally { $ErrorActionPreference = 'SilentlyContinue' }  
################################################################################################################
################################################################################################################    
          If ($System.Name) { $Name = $System.Name } Else { $Name = 'N-A' }
         If ($System.Model) { $Model = $System.Model } Else { $Model = 'N-A' }
      If ($System.UserName) { $User = $System.UserName } Else { $User = 'N-A' }
           If ($OS.Caption) { $OSName = $OS.Caption } Else { $OSName = 'N-A' }
     If ($Enc.SerialNumber) { $Serial = $Enc.SerialNumber } Else { $Serial = 'N-A' }
If ($Enc.SMBIOSBIOSVersion) { $BIOSVersion = $Enc.SMBIOSBIOSVersion } Else { $BIOSVersion = 'N-A' }                 

If ($User -eq $null){$User = 'No logged on user'}

##############################################################################################################################
##############################################################################################################################
# REPLACE MODEL NUMBERS WITH PROPER NAME
$hash = @{}
      $hash.'20QD000LUS' = 'Laptop - Lenovo ThinkPad X1 Carbon'
      $hash.'20RH000JUS' = 'Laptop - Lenovo ThinkPad P43s'
      $hash.'20RH000PUS' = 'Laptop - Lenovo ThinkPad P43s'
      $hash.'344834U' = 'Laptop - Lenovo ThinkPad X1 Carbon'
      $hash.'4865A17' = 'Desktop - Lenovo ThinkCentre M78'
      $hash.'4865A18' = 'Desktop - Lenovo ThinkCentre M78'
      $hash.'5041A3U' = 'Desktop - Lenovo ThinkCentre M75e'
      $hash.'5054A3U' = 'Desktop - Lenovo ThinkCentre M75e'
      $hash.'HP Z420 Workstation' = 'Desktop - HP Z240 Workstation'
      $hash.'Latitude 5290 2-in-1' = 'Laptop - Dell Inc. Latitude 5290 2-in-1'
      $hash.'Latitude 5480' = 'Laptop - Dell Inc. Latitude 5480'
      $hash.'Latitude 5500' = 'Laptop - Dell Inc. Latitude 5500'
      $hash.'Latitude 5510' = 'Laptop - Dell Inc. Latitude 5510'
      $hash.'Latitude 5520' = 'Laptop - Dell Inc. Latitude 5520'
      $hash.'Latitude 5530' = 'Laptop - Dell Inc. Latitude 5530'
      $hash.'Latitude 5540' = 'Laptop - Dell Inc. Latitude 5540'
      $hash.'Latitude 5580' = 'Laptop - Dell Inc. Latitude 5580'
      $hash.'Latitude 5590' = 'Laptop - Dell Inc. Latitude 5590'
      $hash.'Latitude 7390' = 'Laptop - Dell Inc. Latitude 7390'
      $hash.'Latitude 7400 2-in-1' = 'Laptop - Dell Inc. Latitude 7400 2-in-1'
      $hash.'Latitude 7400' = 'Laptop - Dell Inc. Latitude 7400'
      $hash.'Latitude 7410' = 'Laptop - Dell Inc. Latitude 7410'
      $hash.'Latitude 7420' = 'Laptop - Dell Inc. Latitude 7420'
      $hash.'Latitude 7430' = 'Laptop - Dell Inc. Latitude 7430'
      $hash.'Latitude 7480' = 'Laptop - Dell Inc. Latitude 7480'
      $hash.'Latitude 9510' = 'Laptop - Dell Inc. Latitude 9510'
      $hash.'Latitude E5540' = 'Laptop - Dell Inc. Latitude E5540'	 
      $hash.'Latitude E554063533007A/' = 'Laptop - Dell Inc. Latitude E5540'
      $hash.'Latitude E5550' = 'Laptop - Dell Inc. Latitude E5550'
      $hash.'Latitude E5570' = 'Laptop - Dell Inc. Latitude E5570'
      $hash.'Latitude E7440' = 'Laptop - Dell Inc. Latitude E7440'
      $hash.'Latitude E7470' = 'Laptop - Dell Inc. Latitude E7470'
      $hash.'OptiPlex 7000' = 'Desktop - Dell Inc. Optiplex 7000'
      $hash.'OptiPlex 7010' = 'Desktop - Dell Inc. OptiPlex 7010'
      $hash.'OptiPlex 7020' = 'Desktop - Dell Inc. OptiPlex 7020'
      $hash.'OptiPlex 7040' = 'Desktop - Dell Inc. OptiPlex 7040'
      $hash.'OptiPlex 7050' = 'Desktop - Dell Inc. OptiPlex 7050'
      $hash.'OptiPlex 7060' = 'Desktop - Dell Inc. OptiPlex 7060'
      $hash.'OptiPlex 7070' = 'Desktop - Dell Inc. OptiPlex 7070'
      $hash.'OptiPlex 7080' = 'Desktop - Dell Inc. OptiPlex 7080'
      $hash.'OptiPlex 7090' = 'Desktop - Dell Inc. Optiplex 7090'
      $hash.'OptiPlex 7450 AIO' = 'Desktop - Dell Inc. OptiPlex 7450 AIO'
      $hash.'OptiPlex 9020' = 'Desktop - Dell Inc. OptiPlex 9020'
      $hash.'OptiPlex 90202004CK0002/' = 'Desktop - Dell Inc. OptiPlex 9020'
      $hash.'OptiPlex SFF Plus 7010' = 'Desktop - Dell Inc. Optiplex 7010'
      $hash.'PowerEdge 2950' = 'Server - PowerEdge 2950'
      $hash.'Precision 3551' = 'Desktop - Dell Inc. Precision 3551'
      $hash.'Precision 3630 Tower' = 'Desktop - Dell Inc. Precision 3630 Tower'
      $hash.'Precision 3660' = 'Laptop - Dell Inc. Precision 3660'
      $hash.'Precision 7740' = 'Laptop - Dell Inc. Precision 7740'
      $hash.'ProLiant BL685c G6' = 'Server - ProLiant BL685c G6'
      $hash.'ProLiant DL360 Gen10' = 'Server - ProLiant DL360 Gen10'
      $hash.'S3420GP' = 'Server - S3420GP'
      $hash.'To be filled by O.E.M.' = 'Desktop - NewLine'
      $hash.'VMWare Virtual Machine' = 'VMWare Virtual Machine'
      $hash.'VMware Virtual Platform' = 'VMWare Virtual Machine'
      $hash.'VMware7,1' = 'VMWare Virtual Machine'
      $hash.'X9SAE' = 'Desktop - Air Conditioning'
      $hash.'XPS 13 9365' = 'Laptop - Dell Inc. Latitude XPS 13'
      $hash.'XPS 15 9575' = 'Laptop - Dell Inc. Latitude XPS 15 (9575)'
# Check each item in Array
Foreach ($key in $hash.Keys){If ($Model -eq $key){$NewModel = $Model.Replace($key, $hash.$key)}}
If ($NewModel -eq $Null) { $NewModel = $Model }
################################################################
################################################################        
        $Output += ($IPAddress.Padright(15) + "`t" +  `
                    $BIOSVersion.Padright(10) + "`t" +  `                    
					$NewModel.Padright(40) + "`t" +  `				
					$OSName + "`t" +  `
                    $User + "`t"
                    )	                 			
  $string = "$Output".replace(', ', "`t")
}
ELSE
{
    $Output = @()
    $Output += ($IPAddress+"`t"+"Couldn't ping PC")
    $string = "$Output".replace(', ', "`t")
}
    $object = [pscustomobject] @{
        Computer   = $computer;
        Data       = $($string)
    }
$object.Computer.Padright(15),$object.Data -join "`t"
}
################################################################################################################################################################################################
################################################################################################################################################################################################
cls
##############################
 # Add Required Type Libraries
     [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ManagementProvider.dll")) | Out-Null
     [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.dll")) | Out-Null
     [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.Extender.dll")) | Out-Null
     [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.MsiInstaller.dll")) | Out-Null
##############################
# CD 'C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin'
##############################
CD 'C:\Program Files (x86)\ConfigMgr Console\bin'
##############################
Import-Module ".\ConfigurationManager.psd1"
Start-Sleep -Milliseconds 500
################################################
. 'C:\Scripts\!Modules\Invoke-Parallel.ps1'	#Script to run check concurrently
[int]$Timeout = 120
[int]$Throttle = 250
################################################################################################
################################################################################################


$InfoBlock = 'BIOS_Optiplex_7000_NotLoggedOn;Logged Off - BIOS - Dell Optiplex 7000',
             'BIOS_Optiplex_7010_NotLoggedOn;Logged Off - BIOS - Dell Optiplex 7010 SFF',
             'BIOS_Optiplex_7070_NotLoggedOn;Logged Off - BIOS - Dell Optiplex 7070',
             'BIOS_Optiplex_7090_NotLoggedOn;Logged Off - BIOS - Dell Optiplex 7090'
<#
 $InfoBlock =            'BIOS_Optiplex_7090_NotLoggedOn;Logged Off - BIOS - Dell Optiplex 7090'
   #>               

ForEach ($Block in $InfoBlock)
{
       $Global:AppName = $Block.split(';')[0]
    $Global:Collection = $Block.split(';')[1]

################################################################################################
################################################################################################
$ScriptBlock = {
Function Get-DeploymentStatus {      
        
    [CmdletBinding()]
    
    Param
    (
        #Set application name
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$AppName,
        [string]$Collection,

        [ValidateSet("Success","InProgress","RequirementsNotMet","Unknown","error")]
        [String]$Status 
    )

Begin {
#Set query for 'Get-Ciminstance' search
$query = @{
    Namespace = 'root\SMS\site_XX1'
    ClassName = 'SMS_AppDeploymentAssetDetails'
    Filter = "AppName like '$AppName' and CollectionName like '$Collection'"
    }


#Application Status table 
$AppStatusTypeTable = DATA {ConvertFrom-StringData @'
    1 = Success
    2 = InProgress
    3 = RequirementsNotMet
    4 = Unknown
    5 = Error
'@}
}

process {
#Run get-ciminstance with query
Get-CimInstance @query |
    select AppName,Machinename,
    @{Name="StatusOfApplication";Expression={$AppStatusTypeTable["$($PSItem.AppStatusType)"]}} -OutVariable Countcheck      
#If 0 count display a message
if([int]($countcheck).count-le 0){write-host -foreground Cyan "No Data found with the Status of `"$status"" "}
}}

Get-DeploymentStatus -AppName "$using:AppName" -Collection "$using:Collection"
}
"Checking `"$collection`" for deployment status of `"$AppName`"..."
$RResults = Invoke-Command -ComputerName 'SERVER' -ScriptBlock $ScriptBlock
$RResults = $RResults | sort machinename
# $RResults | % { $_.Machinename.Padright(15) + "`t" + $_.StatusOfApplication.Padright(15) }
$DeployResults = $RResults.Machinename

################################################################################################
Set-Location XX1:
CD XX1:
################################################
$CollMembers = $(Get-CMCollectionMember -CollectionName $Collection).name
$Missing = $CollMembers | ?{$DeployResults -notcontains $_}
C:
"`n##################################################`n"
Write-host "These machines were not part of the deployment results:`n" -ForegroundColor Green
"##################################################`n"
$Missing | Sort
Write-host "`n" -ForegroundColor Green
"##################################################`n"
Write-host "Getting logon results from Collection members...`n" -ForegroundColor yellow
"##################################################`n"
################################################################################################

$CResults = Invoke-Parallel -scriptblock $SubScript -inputobject $CollMembers -runspaceTimeout $Timeout -throttle $Throttle
$LogedOnResults = $CResults | ForEach-Object {[pscustomobject]@{Computer = $_.split("`t")[0]; IPAddress = $_.split("`t")[1]; BIOSVer = $_.split("`t")[2]; Model = $_.split("`t")[3]; OS = $_.split("`t")[4]; LoggedOnUser = $_.split("`t")[5]}}

################################################
$GoodR = @()
$BadR = @()
$RResults | % { If ($_ -match 'Success') { $GoodR += $_ } Else { $BadR += $_ }}
###########################
$GoodC = @()
$BadC = @()
$CResults | % { If ((($_ -match '7000') -and 
                     ($_ -match '1.22.0')) -or
                    (($_ -match '7010') -and 
                     ($_ -match '1.14.0')) -or
                    (($_ -match '7070') -and 
                     ($_ -match '1.27.0')) -or
                    (($_ -match '7090') -and 
                     ($_ -match '1.25.0')))
                { $GoodC += $_ } Else { $BadC += $_ }}
$GoodC | sort
""
$BadC | sort
#########################
""
Write-Host "Total collection members: " $CollMembers.count -ForegroundColor Cyan
Write-Host "   Total systems checked: " $DeployResults.count -ForegroundColor Cyan
""
Write-Host "          Deploy Success: " $GoodR.Count -ForegroundColor Green
Write-Host "        Upgraded systems: " $GoodC.Count -ForegroundColor Green
""
Write-Host "    Non-upgraded systems: " $BadC.Count -ForegroundColor Yellow
Write-Host "            Deploy Other: " $BadR.Count -ForegroundColor Yellow
}
Read-Host -Prompt "Press any key to continue or CTRL+C to quit" 


<################################################

cls
######################
ForEach ($Machine in $CollMembers)
{
    # "Checking $machine..."
    ############################################
    ForEach ($Item in $RResults)
    {
                $Machinename = $Item.Machinename    
        $StatusOfApplication = $Item.StatusOfApplication
        
        #"Looking at $Machinename..."
        ##################################################################
            ForEach ($Thing in $LogedOnResults)
            {
                 $Computer = $Thing.Computer
                $IPAddress = $Thing.IPAddress
                  $BIOSVer = $Thing.BIOSVer
                    $Model = $Thing.Model
                       $OS = $Thing.OS
             $LoggedOnUser = $Thing.LoggedOnUser
           # "and looking at $Computer..."

                    If ($Machine -eq $Computer)
                    {
                        Write-Host "Match found for $machine.." -ForegroundColor Green
                        $output = $Machinename + "`t" + `
                                  $StatusOfApplication + "`t" + `
                                  $IPAddress + "`t" + `
                                  $BIOSVer + "`t" + `
                                  $Model + "`t" + `
                                  $OS + "`t" + `
                                  $LoggedOnUser
                        $output
                     }
##################################################################
}}}

      $RResults = $RResults | sort machinename
   $CollMembers = $CollMembers | sort
$LogedOnResults = $LogedOnResults | sort Computer

$Output1 = @()
$output2 = @()
ForEach ($Result in $RResults)
{
    $MachineName = $Result.machinename
    ForEach ($Member in $CollMembers)
    {  
        If ($MachineName -eq $Member)
        {
            $Output1 += $Member + ',' + $Result.StatusofApplication
        }
        Else
        {
            $Output1 += $Member + ',' + 'No Status' 
        }                       
    }
}
$output1 = $output1 | sort -Unique
# $Missing = (Compare-Object $RResults.Machinename $CollMembers).InputObject 
# $Missing | % { $Output1 += $_ + ',' +'No Result' }

########################################################
########################################################
$erroractionpreference = 'SilentlyContinue'
ForEach ($LogOn in $LogedOnResults)
{
    $Computer = $Item.Computer.trim()
          $IP = $Item.IPAddress.trim()    
        $BIOS = $Item.BIOSVer.trim()      
       $Model = $Item.Model.trim()        
          $OS = $Item.OS.trim()           
        $User = $Item.LoggedOnUser.trim()
    ForEach ($Thing in $Output1)
    {
        $PC = $Thing.split(',')[0]
        If ($Computer -eq $PC)
        {
            $Output2 += $Thing + ',' + $IP  + ',' + $BIOS + ',' + $Model + ',' + $OS + ',' + $User
        }
        Else
        {
            $Output2 += $Computer + ',' + 'No IP,No BIOS,No Model,No OS,No User'
        }                          
    }
}
$output2 = $output2 | sort -Unique
# $Missing = (Compare-Object $LogedOnResults.Computer $CollMembers).InputObject 
# $Missing | % { $Output2 += $_. + ',' +'No Result' }

########################################################
########################################################

    ForEach ($LogOn in $LogedOnResults)
    {
        $Computer = $Item.Computer     
           $IP = $Item.IPAddress    
         $BIOS = $Item.BIOSVer      
        $Model = $Item.Model        
           $OS = $Item.OS           
         $User = $Item.LoggedOnUser
        
        If ($IP -eq $null) { $IP = 'N~A' }    
        If ($BIOS -eq $null) { $BIOS = 'N~A' }   
        If ($Model -eq $null) { $Model = 'N~A' }   
        If ($OS -eq $null) { $OS = 'N~A' }   
        If ($User -eq $null) { $User = 'N~A' }   

        If ($PC -eq $Computer)
        {
            $Output2 += $PC + ',' + $IP + ',' + $BIOS + ',' + $Model + ',' + $OS + ',' + $User
        }
        Else
        {
            $Output2 += $Computer + ',' + $IP + ',' + $BIOS + ',' + $Model + ',' + $OS + ',' + $User
        }
    }
}

$Missing = (Compare-Object $RResults.Machinename $CollMembers).InputObject 
$Missing | % { $Output1 += $_ + ',' +'No Result' }


If ($RResults -match $Machine) { $Machinename + "`t" + $StatusOfApplication }
If ($CResults -match $Machine) { $Machine + "`t" + `
                                 $StatusOfApplication + "`t" + `
                                 $IPAddress + "`t" + `
                                 $BIOSVer + "`t" + `
                                 $Model + "`t" + `
                                 $OS + "`t" + `
                                 $LoggedOnUser }



foreach ($oldName in 0..$arrOldNames.GetUpperBound(0))
{
  if ($arrFullNames -like "*$oldName*")
  {
    Write-Output "Full OLD name is $($arrFullNames[$line])"
    #Write-Output "OLD name is $($arrOldNames[$line])"

    Write-Output "NEW name is $($arrNewNames[$line])"
    #Write-Host "$oldName exists"
  }
}
#>
