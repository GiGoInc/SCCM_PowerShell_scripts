<#

    This script seems to be incomplete....not sure where the logpath / computername stuff is coming from. 

    Commented out script for your own protection
    - Isaac
#>

<#


##  I've removed most information specific to my environment, this script should get you started, but you'll need to customize it to conform to your log file location
##  and also take a look at line 34-44 to figure out how to parse the computer name from your log files.
##  
##  Set -auto parameter, if used script will run without prompting user to confirm repairs.

Param([switch]$Auto)

##  Declare some variables
[array]$ComputerNames = @()
$LogFilePath = 'C:\Windows\CCM\Logs'
 $SCCMServer = 'SCCMSERVER'

   $ScriptPath = 'C:\Windows\Logs\Software\WMI_Fixes'
    $TimeStamp = (Get-Date -UFormat "%Y-%m-%d-%H%M")
	##  Verify $ScriptPath exists, create if not
	if (!(Test-Path $ScriptPath))
	{
		New-Item -ItemType directory -Path $ScriptPath
	}
	Set-Location $ScriptPath
	$ScriptLogFile = "$ScriptPath\Repair_$TimeStamp.log"
	New-Item $ScriptLogFile -ItemType File

if ($Auto -eq $true)
{
    Add-Content -value "Script was ran in automatic mode!!!" -Path $ScriptLogFile
}


##  Get list of log files from log directory
$LogFiles = Get-ChildItem $LogFilePath

##  Split log file into pieces and get part 12 which is the computer name
foreach ($LogFile in $LogFiles)
{
    [array]$Lines = (Get-Content $LogFilePath$LogFile)
    $Lines = $Lines.split(" ")
    $ComputerName = $Lines[12]
    $ComputerName = $ComputerName.ToString()
    $ComputerNames += $ComputerName
    $Lines = $null
}
Write-Host "Here are the computers we will attempt to fix: `n$ComputerNames `n"
Add-Content -Value $ComputerNames -Path $ScriptLogFile

    
foreach ($ComputerName in $ComputerNames)
{
    $problemcode = $null

    ##  Read the individual computers log file to get the last line containing the error message
    $ComputerLogfile = (Get-Content $LogFilePath*$ComputerName*.log)
    $lastLine = ($computerLogFile)[-1]
 
    ##  Verify Connectivity
    if (Test-Connection -Quiet -Count 1 -ComputerName $ComputerName)
    {
    $ConnectionStatus = "Working"
    	if(Test-Path "\\$ComputerName\c$")
    	{
    		$ConnectionStatus = "Working"
    	}
    	Else
    	{
    		$ConnectionStatus = "Not Working"
    	}
    }
    Else
    {
    	$connectionstatus = "not working"
    }
   
 
    if ($ConnectionStatus -eq "Working")
    {
    Write-Host "Looks like the client $ComputerName is online and accessible, let's proceed. `n" -ForegroundColor Green
    
    Write-Host "The last line of the log file for $ComputerName is: `n `n $lastline `n"
    Add-Content -Value "The last line of the log file for $ComputerName is: `n $lastline"  -Path $ScriptLogFile
 
            if ($lastLine -like "*WMI*")
            {
                    if ($Auto -ne $true)
                    {
                        Write-Host "Based upon the log file, the client needs WMI repair `n"
                        Write-host "Would you like to proceed? `n"
                        Write-host "Y: Yes, proceed with WMI repair"
                        Write-host "N: No, please do not make changes `n"
                        $ConfirmFix = Read-Host "Enter Y or N"
                    }
                    Else
                    {
                        $ConfirmFix = "Y"
                    }

                if ($ConfirmFix -eq "Y")
                {
                    Write-Host "OK! let's try to verify and repair WMI"
                    ##  Log selection
                    Add-Content -Value "$ComputerName needed WMI repair, and user selected to perform repair" -Path $ScriptLogFile
                    
                    ##  Try to query WMI root namespace, if successful move on and query CCM namespace. Query results output to log file.
                    Try
                    {
                        Get-WmiObject -class Win32_Service -namespace "root\cimv2" -ComputerName $ComputerName -ErrorAction Stop | Out-Null
                        Write-Host "WMI looks OK, let's check the CCM namespace" -ForegroundColor Green
                        Add-Content -Value "WMI on $ComputerName looks OK, let's check the CCM namespace" -Path $ScriptLogFile
                    }
                    Catch
                    {
                        Write-Host "WMI looks corrupt, we should probably fix it" -ForegroundColor Red

                        ##  If auto mode parameter isn't enabled, then ask user to confirm before fixing.
                        if ($Auto -ne $true)                                        
                        {
                            $FixIt = Read-Host "Do you want to fix it? Enter Y/N"
                        }

                        ##  If auto mode parameter is true, automatically fix the WMI
                        Else
                        {
                            $FixIt = "y"
                        }

                        if($FixIt -eq "N" )
                        {
                            Exit
                        }
                        Elseif ($FixIt -eq "y")
                        {
                            ##  Stop CCM Services
                            Write-Host "Stopping some SCCM services..." -ForegroundColor Green
                            gsv -c OLT0060497 ccmexec, CASPLiteAgent, smstsmgr | Stop-Service

                            ##  Remove CCM files
                            Write-Host "Removing SCCM client files..." -ForegroundColor Green
                            Remove-Item \\$ComputerName\c$\Windows\CCM -Force -recurse
                            Remove-Item \\$ComputerName\c$\Windows\CCMsetup -Force -recurse

                            ##  Stop WMI service
                            Write-Host "Stopping WMI services..." -ForegroundColor Green
                            gsv -ComputerName $ComputerName winmgmt | Stop-Service -force
                                if (Test-Path -Path \\$ComputerName\c$\windows\system32\wbem\Repository.001)
                                {
                                    Remove-Item \\$ComputerName\c$\windows\system32\wbem\respository.001 -force
                                }

                            ##  Rename the WMI repository
                            Write-Host "Fixing the WMI repository..." -ForegroundColor Green
                            Rename-Item \\$ComputerName\c$\windows\system32\wbem\Repository -newname Repository.001

                            ##  Use psexec to run repository upgrade
                            .\PsExec.exe \\$ComputerName rundll32 wbemupgd, UpgradeRepository

                            ##  Reinstall Client
                            Write-Host "Reinstalling the SCCM client..." -ForegroundColor Green
                            New-Item -Path \\$SCCMServer\ccr.box$\ClientPush.ccr -ItemType file `
                            -Value "[NT Client Configuration Request]
                                    Client Type=1
                                    Forced CCR=TRUE
                                    Machine Name=$ComputerName"
                        
                            Write-Host "`n"
                            Add-Content -Value "WMI on $ComputerName was corrupt, we fixed it and reinstalled the client" -Path $ScriptLogFile
                            continue
                        }
                        Else
                        {
                            Write-Host "invalid entry"
                        }
                    }
                    
                    
                try
                {
                    Get-WmiObject -class ccm_installedcomponent -namespace "root\ccm" -ComputerName $ComputerName -Property DisplayName -ErrorAction Stop |Out-Null
          
                    Write-Host "CCM namespace looks good from here, it's probably safe to delete the log file for $ComputerName and call this one a false positive `n" -ForegroundColor Green
                    Add-Content -value "CCM namespace looks good from here, it's probably safe to delete the log file for $ComputerName and call this one a false positive `n" -Path $ScriptLogFile
                    Write-Host "######################################################################################" -ForegroundColor Yellow
                    Write-host "################ Moving on to next machine in the list: $ComputerName ################" -ForegroundColor Yellow
                    Write-Host "######################################################################################" -ForegroundColor Yellow
                    Continue
                }
                catch
                {
                	Write-Host "CCM Namespace looks corrupt, we should probably fix it" -ForegroundColor Red
                	Add-Content -Value "CCM Namespace is corrupt on $ComputerName, we should probably fix it" -Path $ScriptLogFile
                	if ($Auto -ne $true)
                	{
                		$FixIt = Read-Host "Do you want to fix it? Enter Y/N"
                	}
                	Else
                	{
                		$FixIt = "y"
                	}
                	
                	if ($FixIt -eq "y")
                	{
                		##  Stop CCM Services
                		Write-Host "Stopping some services..." -ForegroundColor Green
                		gsv -c $ComputerName ccmexec, CASPLiteAgent, smstsmgr | Stop-Service

                		##  Remove CCM files
                		Write-Host "deleting some files..." -ForegroundColor Green
                		Remove-Item \\$ComputerName\c$\Windows\CCM -force -recurse
                		Remove-Item \\$ComputerName\c$\Windows\CCMsetup -force -recurse

                		##  Stop WMI service
                		Write-Host "stopping the wmi service..." -ForegroundColor Green
                		Get-Service -ComputerName $ComputerName winmgmt | Stop-Service -force

                		## Test to see a renamed repository file already exists, if so delete it so we can rename the current wmi repository
                		if (Test-Path -Path \\$ComputerName\c$\windows\system32\wbem\Repository.001)
                		{
                			Remove-Item \\$ComputerName\c$\windows\system32\wbem\respository.001 -force
                		}

                		##  Rename the WMI repository
                		Rename-Item \\$ComputerName\c$\windows\system32\wbem\Repository -newname Repository.001

                		##  Use psexec to run repository upgrade
                		.\PsExec.exe \\$ComputerName rundll32 wbemupgd, UpgradeRepository

                		##  Reinstall Client
                		New-Item -Path \\$SCCMServer\ccr.box$\ClientPush.ccr -ItemType file -Value "[NT Client Configuration Request]
                		Client Type=1
                		Forced CCR=TRUE
                		Machine Name=$ComputerName"
                		
                		Write-Host "`n"
                		Add-Content -Value "CCM Namespace was corrupt, we fixed WMI and reinstalled the client" -Path $ScriptLogFile
                	}
                	Elseif($FixIt -eq "N")
                	{
                		Exit
                	}
                }
            }
            Else
            {
                Exit
            }               
        }
        Elseif ($lastLine -like "*Client does not appear to be installed*")
        {
            Write-Host "Based upon the log file, the machine needs the SCCM client installed"
            Write-Host "Would you like to proceed?"
            Write-Host "Y: Yes, proceed with client installation"
            Write-Host "N: No, please do not make changes"
            If ($Auto -ne $True)
            {
              $ConfirmFix = Read-Host "Enter Y or N"
            }
            Else
            {
                $ConfirmFix = "Y"
                Write-Host "Auto mode enabled, no input needed"
            }
            
            
            If ($ConfirmFix -eq "Y")
            {
                Write-Host "OK! let's try to reinstall the client" -ForegroundColor Green
                New-Item -Path \\$SCCMServer\ccr.box$\ClientPush.ccr -ItemType file -Value "[NT Client Configuration Request]
                Client Type=1
                Forced CCR=TRUE
                Machine Name=$ComputerName"
                
                Write-Host "`n"
                Write-Host "We reinstalled the client on $ComputerName" -foregroundcolor Green
                Add-Content -Value "Client was not installed, we pushed the client to $ComputerName" -Path $ScriptLogFile
            }
            Else
            {
                Exit
            }
        }        
    }
    Else
    {
        Write-Host "Looks like $ComputerName is offline, better stop here." -ForegroundColor Red
        Add-Content -Value "Connectivity check to $ComputerName failed. Machine appears to be offline or not able to be connected to."  -Path $ScriptLogFile
        Write-Host "######################################################################################" -ForegroundColor Yellow
        Write-Host "################ Moving on to next machine in the list: $ComputerName ################" -ForegroundColor Yellow
        Write-Host "######################################################################################" -ForegroundColor Yellow
        Write-Host "`n"
        Continue
    }
}

#>