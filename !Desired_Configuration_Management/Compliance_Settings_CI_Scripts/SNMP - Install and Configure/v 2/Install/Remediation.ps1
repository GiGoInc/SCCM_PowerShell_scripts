$OSName = (gwmi Win32_OperatingSystem).Caption
}
    REG ADD "HKLM\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities" /v "hbnet1" /t REG_DWORD /d "4" /f
$OSName = (gwmi Win32_OperatingSystem).Caption
# Windows Server 2003
    If ($OSName -like "*Windows Server*2003*Standard*")
    { 
        Start-Process -FilePath 'C:\Windows\System32\sysocmgr.exe' -ArgumentList '/i:C:\Windows\inf\sysoc.inf /u:"<a href="file://SERVER/d$/Scripts/Orion/snmp.txt">\\SERVER\d$\Scripts\Orion\snmp.txt</a>" /q' -Wait -WindowStyle Hidden
    }
# Windows Server 2008 Standard
    If ($OSName -like "*Windows Server*2008 Standard*")
    {
        Start-Process -FilePath 'C:\Windows\System32\servermanagercmd.exe' -ArgumentList '-install SNMP-Services -allSubFeatures' -Wait -WindowStyle Hidden
    }
# Microsoft Windows Server 2008 R2
    If ($OSName -like "*Windows Server 2008 R2*")
    {
        Import-Module ServerManager
        Add-WindowsFeature SNMP-Services | Out-Null
    }
 # Microsoft Windows Server 2012  
    If (($OSName -like "*Windows Server 2012 R2*") -or `
        ($OSName -like "*Windows Server 2012 Standard"))
    {
        Import-Module ServerManager
        Install-WindowsFeature SNMP-Service
        Install-WindowsFeature RSAT-SNMP
    }

If (($OSName -like "*Windows Server*2003*Standard*") -or `
    ($OSName -like "*Windows Server*2008 Standard*") -or `
    ($OSName -like "*Windows Server 2008 R2*") -or `
    ($OSName -like "*Windows Server 2008 R2*") -or `
    ($OSName -like "*Windows Server 2012 R2*") -or `
    ($OSName -like "*Windows Server 2012 Standard"))
{
    REG DELETE "HKLM\SYSTEM\CurrentControlSet\services\SNMP\Parameters\PermittedManagers" /va /f
    REG ADD "HKLM\SYSTEM\CurrentControlSet\services\SNMP\Parameters\TrapConfiguration\hbnet1" /v '1' /t REG_SZ /d 'XXXXorionp1' /f
    REG ADD "HKLM\SYSTEM\CurrentControlSet\services\SNMP\Parameters\TrapConfiguration\hbnet1" /v '2' /t REG_SZ /d 'XXXXorionapp1' /f
    REG ADD "HKLM\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities" /v "hbnet1" /t REG_DWORD /d "4" /f
}
