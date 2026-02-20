 #---------------------------------------------------------------------------#
"CCM Installed on $CCMTime" 
$CCMTime = Get-Item -Path C:\Windows\ccmsetup\ccmsetup.cab | Select-Object -Property CreationTime
 #---------------------------------------------------------------------------#
#                           SCCM 2012 Client Repair                         #
# AUTH: David Bennett                                                       #
#                                                                           #
# THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY    #
# KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE       #
# IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR     #
# PURPOSE.                                                                  #
#                                                                           #
# Use : powershell clifixes.ps1                                             #
#       The intent is to be ran from Push.bat to be kicked off remotely     #
#       If it's not kicked off by Push.bat, support files may not be there  #
# Desc: Uninstalls SCCM, Rebuilds the Repository, Runs WMIRepair, and       #
#       Re-installs the client                                              #
# Out : Logs to c:\temp\sccm.log on the remote machine.  Minimal logging in #
#       the local command prompt                                            #
# Ass : The script assumes support files are in c:\ps\push change this      #
#       below to a location of your choice.  Support files are the script   #
#       itself, UnlockPowerShell.vbs, and wmirepair.exe                     #
#---------------------------------------------------------------------------#
 
#Running Function
# Input the process you want to monitor, returns when the process is finished
Function Running($proc)
{
    $Now = "Exists"
    While ($Now -eq "Exists")
    {
        If(Get-Process $proc -ErrorAction silentlycontinue)
        {
            $Now = "Exists"
            "INFO   : $proc is running, waiting 15 seconds" >> $LogFile
            Sleep -Seconds 15
        }
        Else
        {
            $Now = "Nope"
            "INFO   : $proc has finished running" >> $LogFile
        }
    }
}
 
$Error.Clear()
$exe = "C:\Windows\ccmsetup\ccmsetup.exe"
$Uarg = "/uninstall"
$Iarg = "smssitecode=***"
$wmiC = "C:\temp\push\wmirepair.exe"  #*** Change this to where you run from, I use push.bat (later post)
$wmiA = "/CMD"
$strComputer = Get-Content env:computername
 
"Working on $strComputer"
 
If(Test-Path c:\temp\SCCM.log -ErrorAction SilentlyContinue)
{
    Remove-Item c:\temp\sccm.log
    IF (! $?) {"ERROR: Unable to delete old sccm.log"}
    ELSE {"SUCCESS: Removed old sccm.log"}
}
 
$LogFile = "C:\temp\sccm.log"
 
"Working on $strComputer" >> $LogFile
IF (! $?) {"ERROR: Unable to Create sccm.log"}
ELSE {"SUCCESS: Created sccm.log, logging continues there"
      "SUCCESS: Created sccm.log on $strComputer">> $LogFile}
 
If(Test-Path C:\Windows\ccmsetup\ccmsetup.exe -ErrorAction SilentlyContinue)
{
    "SUCCESS: Found existing CCMSetup.exe" >> $LogFile
 
    #Uninstall the Client
    "INFO   : Running $exe $Uarg on system $strComputer" >> $LogFile
    &$exe $Uarg
    Running CCMSetup
    If (! $?) {"ERROR: The ccmsetup /uninstall did not exit cleanly" >> $LogFile
               "    I'm going to continue, the next steps may fix it" >> $LogFile
               $Error.clear}
    Else {"SUCCESS: Completed CCMSETUP.EXE /Uninstall" >> $LogFile }
}
 
#StopWinmgmt
Set-Service Winmgmt -StartupType Disabled -ErrorAction SilentlyContinue
If (! $?) {"ERROR: Could not disable Winmgmt" >> $LogFile
               $Error.clear}
Else {"SUCCESS: Disabled Winmgmt" >> $LogFile }
Stop-Service Winmgmt -Force -ErrorAction SilentlyContinue
If (! $?) {"ERROR: Could not Stop Winmgmt" >> $LogFile
               $Error.clear}
Else {"SUCCESS: Stopped Winmgmt" >> $LogFile }
 
#Sleep 10 for WMI Startup
"INFO   : Sleeping 10 Seconds for WMI Shutdown" >> $LogFile
Sleep -Seconds 10
 
#Rename The Repository
#NO, THIS IS NOT A BEST PRACTICE.  But I have yet to break anything with it so it's how I do
#If I start breaking stuff, I'll fix it then
# Step 1, check to see if there is an old backup repository.  Remove it.
If(Test-Path C:\Windows\System32\wbem\repository.old -ErrorAction SilentlyContinue)
    {
        Remove-Item -Path C:\Windows\System32\wbem\repository.old -Recurse -Force -ErrorAction SilentlyContinue
        If (! $?) {"ERROR: Could not delete the old repository backup, check permissions" >> $LogFile
               $Error.clear}
        Else {"SUCCESS: Removed the old repository back." >> $LogFile
              "    NOTE: You've done this before, there may be deeper system issues" >> $LogFile}
    }
 
# Step 2, rename existing repository directory.
Rename-Item -Path C:\Windows\System32\wbem\repository -NewName 'Repository.old' -Force -ErrorAction SilentlyContinue
If (! $?) {"ERROR: Could not rename the existing repository, check permissions" >> $LogFile
               $Error.clear}
Else {"SUCCESS: SUCCESS: Renamed Repository" >> $LogFile }
#Start WMI back up
Set-Service Winmgmt -StartupType Automatic -ErrorAction SilentlyContinue
If (! $?) {"ERROR: Could not configure WINMGMT, you're screwed" >> $LogFile
               $Error.clear}
Else {"SUCCESS: SUCCESS: Configured WINMGMT" >> $LogFile }   
Start-Service Winmgmt -ErrorAction SilentlyContinue
If (! $?) {"ERROR: Could not start WINMGMT, you're screwed" >> $LogFile
               $Error.clear}
Else {"SUCCESS: SUCCESS: Started WINMGMT" >> $LogFile }   
 
#Sleep 10 for WMI Startup
"Sleeping 10 Seconds for WMI Startup" >> $LogFile
Sleep -Seconds 10
#Start other services that WMI typically takes down with it
Start-Service iphlpsvc -ErrorAction SilentlyContinue
If (! $?) {"ERROR: Could not start IP Helper, might not be needed in this environment" >> $LogFile
               $Error.clear}
Else {"SUCCESS: SUCCESS: Started IP Helper" >> $LogFile }   
      
Start-Service Winmgmt -ErrorAction SilentlyContinue
If (! $?) {"ERROR: Could not configure Security Center, might not be needed in this environment" >> $LogFile
               $Error.clear}
Else {"SUCCESS: SUCCESS: Started Security Center" >> $LogFile }   
 
#Sleep 1 Minute to allow the WMI Repository to Rebuild
"INFO   : Sleep 1 Minute to allow the WMI Repository to Rebuild" >> $LogFile
Sleep -Seconds 60
 
#Run WMIRepair **Credits for WMI Repair: Robert Zander
#              **This comes with SCCM Client Center and I didn't wand to re-create the wheel
#              **You have to extract the Executable by running Client Center WMI Repair on
#              **  a system and finding the exe in the Windows folder (or system32, I forget)
"INFO   : Running WMI Repair" >> $LogFile
&$wmiC $wmiA
Running WMIRepair
If (! $?) {"ERROR: WMIRepair encountered errors, check output" >> $LogFile
               $Error.clear}
Else {"SUCCESS: WMIRepair Success" >> $LogFile }   
 
#Clear ccmsetup folder
#Just something I do, without deleteing ccmsetup.exe I've seen it pull a client from our old site,
# which is still up for 'Just In Case' reasons, if the client was never upgraded correctly
Remove-Item -Path C:\Windows\ccmsetup\* -Recurse -Exclude "logs" -ErrorAction SilentlyContinue
If (! $?) {"ERROR: Could not clean up CCMSETUP folder" >> $LogFile
               $Error.clear}
Else {"SUCCESS: Cleaned up CCMSETUP folder" >> $LogFile }   
 
 
#Get the current ccmsetup.exe
Copy-Item -Path \\***\SCCM_2012_Client\ccmsetup.exe -Destination C:\Windows\ccmsetup -ErrorAction SilentlyContinue
If (! $?) {"ERROR: Could not copy ccmsetup.exe from the server, check paths" >> $LogFile
               $Error.clear}
Else {"SUCCESS: Copied a fresh ccmsetup.exe from the site server" >> $LogFile }   
 
#Sleep 10 just in case WMI is still trashing from WMIRepair; #SeenItOnce
"INFO   : Sleeping 10 Seconds for system stability" >> $LogFile
Sleep -Seconds 10
#Install the client
"Running $exe $Iarg" >> $LogFile
&$exe $Iarg
Running CCMSetup
If (! $?) {"ERROR: CCMSETUP install encountered errors, check ccmsetup.log" >> $LogFile
               $Error.clear}
Else {"SUCCESS: CCMSETUP install completed successfully" >> $LogFile }     
 
#Report Completion back to the command line
$CCMTime = Get-Item -Path C:\Windows\ccmsetup\ccmsetup.cab | Select-Object -Property CreationTime
"CCM Installed on $CCMTime" 
