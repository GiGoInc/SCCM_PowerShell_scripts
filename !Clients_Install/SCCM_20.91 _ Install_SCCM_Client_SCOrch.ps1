Add-PSSnapin VMWare.VimAutomation.Core
}
    $poweredoff = $computer
Add-PSSnapin VMWare.VimAutomation.Core
Connect-VIServer -Server XXXXvc05 -User SVCUSER1 -Password \`d.T.~Vb/{1884042F-0E3D-477D-997C-543B1B5A3CD0}\`d.T.~Vb/

$computer = "\`d.T.~Ed/{39A91BCA-DE07-4C8C-A40B-31E06A6EDDB2}.hostname\`d.T.~Ed/"

## Copy Diskpart Script to New Server
Wait-Tools -VM $computer -TimeoutSeconds 30
Copy-VMGuestFile -Source "D:\Scripts\2012_R2_SP1_SCCM_Client" -Destination c:\Windows\ccmsetup\ -VM $computer -LocalToGuest -GuestUser Administrator -GuestPassword DOMAINPart2123


# Test if computer is online
$alive = Test-Connection -ComputerName $computer -Quiet

If ($alive)
{
    $type = Get-VMGuest -VM $computer
        
    If ($type -like "*32-bit*")
    {
        #Install x86 Client
        Invoke-VMScript -VM $computer -ScriptText "C:\windows\ccmsetup\ccmsetup.exe /forceinstall /mp:SERVER.DOMAIN.COM FSP=SERVER.DOMAIN.COM SMSSLP=SERVER.DOMAIN.COM SMSCACHESIZE=5240 PATCH=`"C:\Windows\ccmsetup\i386\ClientPatch\configmgr2012ac-sp2r2sp1-kb3135680-i386.msp`"" -GuestUser administrator -GuestPassword DOMAINPart2123
        $poweredoff = $null
    }
    
    If ($type -like "*64-bit*")
    {
        #Install x64 Client
        Invoke-VMScript -VM $computer -ScriptText "C:\windows\ccmsetup\ccmsetup.exe /forceinstall /mp:SERVER.DOMAIN.COM FSP=SERVER.DOMAIN.COM SMSSLP=SERVER.DOMAIN.COM SMSCACHESIZE=5240 PATCH=`"C:\Windows\ccmsetup\x64\ClientPatch\configmgr2012ac-sp2r2sp1-kb3135680-x64.msp`"" -GuestUser administrator -GuestPassword DOMAINPart2123
        $poweredoff = $null
    }
}
else
{
    $poweredoff = $computer
}
