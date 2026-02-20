<#
}
    }
<#
}
    }
<#
.SYNOPSIS
    Uninstalls SCCM Object Folder Path console tool

.DESCRIPTION
    This file will check to see if the Config Mgr console is installed, and if so
    attempts to uninstall the SCCM Object Folder Path tool.

.EXAMPLE
    PS C:\> Uninstall.ps1

.LINK
    http://www.sysadmintechnotes.com

.NOTES
    Author:  Duncan Russell
    Email:   duncan@sysadmintechnotes.com
    Date:    02/25/2015
    PSVer:   3.0
#>
Param(
    [switch]$Silent
)
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$consoleInstalled = $false
$consolePath = ''
#check for SCCM console installation in registry on 64 bit machine

$regPath = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\ConfigMgr10\Setup'
if (Test-Path $regPath){
    try {
        Get-ItemProperty -Path $regPath | Select-Object -ExpandProperty 'UI Installation Directory' -OutVariable consolePath -ErrorAction Stop | Out-Null
        $consoleInstalled = $true
    }
    catch {
        #try for a 32 bit machine
        try {
            $regPath = $regPath.Replace('\Wow6432Node','')
            Get-ItemProperty -Path $regPath | Select-Object -ExpandProperty 'UI Installation Directory' -OutVariable consolePath -ErrorAction Stop | Out-Null
            $consoleInstalled = $true
        }
        catch {}
    }
}

if ($consoleInstalled){
    if (Test-Path($consolePath)) {

        #Kill the CM console if it is running
        $Processes = Get-Process -Name Microsoft.ConfigurationManagement -ErrorAction SilentlyContinue
        if ($Processes -ne $null) {
            foreach($Process in $Processes){
                $Process.Kill()
            }
        }
        $filelist = @("Extensions\Actions\07620de0-f4c2-40b4-9996-0ef7c1e000bc\DriverPath.xml",
            "Extensions\Actions\186eaf52-8767-4522-aa34-584d0615961f\QueryPath.xml",
            "Extensions\Actions\34446c89-5a0d-4287-88e5-9c87d832a946\UserCollectionPath.xml",
            "Extensions\Actions\4b05362e-3ea4-4931-aa2d-3d889b1d75e4\DriverPackagePath.xml",
            "Extensions\Actions\5360fd7a-a1c4-428f-91c9-89a4c5565ce1\SoftwareUpdatePath.xml",
            "Extensions\Actions\7a5f089c-ea90-4da2-aee9-d6d2673a861f\BootImagePackagePath.xml",
            "Extensions\Actions\7d0f75ec-3502-4b9d-b3ce-7b18b29942e8\OSInstallerPath.xml",
            "Extensions\Actions\828a154e-4c7d-4d7f-ba6c-268443cdb4e8\ImagePackagePath.xml",
            "Extensions\Actions\968164ab-af86-459c-b89e-d3a49c05d367\ApplicationPath.xml",
            "Extensions\Actions\9c69b0aa-a27c-43c9-8c26-5f964106a881\PackagePath.xml",
            "Extensions\Actions\a92615d6-9df3-49ba-a8c9-6ecb0e8b956b\DeviceCollectionPath.xml",
            "Extensions\Actions\f2c07bfb-d83d-4e0b-969b-5da6321c28c2\TaskSequencePackagePath.xml",
            "GetSccmObjFolderPath\Get-SccmObjFolderPath.ps1")

        #Remove the files, and folders if empty
        $filelist | ForEach-Object {
            $file = "$($consolePath)XmlStorage\$($_)"
            if (Test-Path($file)){
                $parent = Split-Path -Path $file
                Remove-Item -Path $file -Force
                if((Get-ChildItem -Path $parent).Count -eq 0){
                    Remove-Item $parent -Force
                }
            }
        }
        if($Silent -eq $false){
            [void][System.Windows.Forms.MessageBox]::Show("Uninstall Complete." , "Task Completed")
        }
    }
    else{
        if($Silent -eq $false){
            [void][System.Windows.Forms.MessageBox]::Show("Console appears to be installed, but path to it is wrong in the registry." , "Error")
        }
    }
}
else {
    if($Silent -eq $false){
        [void][System.Windows.Forms.MessageBox]::Show("Console is not installed." , "Error")
    }
}
