$computer = "nutxtst01"
$SCCMshare = "\\SCCMSERVER\Packages\2012_R2_SP1_SCCM_Client"
$destshare = "\\"+ $computer +"\C$\Windows\ccmsetup"

# Test if computer is online
$alive = Test-Connection -ComputerName $computer -Quiet

If ($alive)
{
    # Copy CCMSETUP folder
    Copy-Item -Path $SCCMshare -Destination $destshare -Recurse
    start-sleep 15
    
    # Get Operating System Type - 32 or 64 bit
    $System = gwmi -computer $computer Win32_ComputerSystem # normally non-terminating
    $Type = $System.SystemType


    # Create PSSession to computer
    $wsman = New-PSSession -ComputerName $computer

        # 64-bit OS check
        If ($Type -eq "x64-based PC")
        {
            #Install x64 Client
            Invoke-Command -ScriptBlock {Start-Process -FilePath 'C:\windows\ccmsetup\ccmsetup.exe' -ArgumentList ('/forceinstall /mp:SCCMSERVER.Domain.Com FSP=SCCMSERVER.Domain.Com SMSSLP=SCCMSERVER.Domain.Com SMSCACHESIZE=5240 PATCH=`"C:\Windows\ccmsetup\x64\ClientPatch\configmgr2012ac-sp2r2sp1-kb3135680-x64.msp`"') -Wait} -Session $wsman
        }
        
        # 86-bit OS check
        If ($Type -eq "x86-based PC")
        {
            #Install x86 Client
            Invoke-Command -ScriptBlock {Start-Process -FilePath 'C:\windows\ccmsetup\ccmsetup.exe' -ArgumentList ('/forceinstall /mp:SCCMSERVER.Domain.Com FSP=SCCMSERVER.Domain.Com SMSSLP=SCCMSERVER.Domain.Com SMSCACHESIZE=5240 PATCH=`"C:\Windows\ccmsetup\i386\ClientPatch\configmgr2012ac-sp2r2sp1-kb3135680-i386.msp`"') -Wait} -Session $wsman 
        }  
}
else
{
    $poweredoff = $computer
}