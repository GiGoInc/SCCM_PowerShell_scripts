<#
}
    }
<#
}
    }
<#
.SYNOPSIS
    Installs SCCM Object Folder Path console tool

.DESCRIPTION
    This file will check to see if the Config Mgr console is installed, and if so
    installs SCCM Object Folder Path tool.

.PARAMETER SiteCode
    Config Mgr three-digit site code

.PARAMETER CMProvider
    Config Mgr Provider, typically your primary site server (or CAS if you have one)

.EXAMPLE
    PS C:\> Install.ps1 -SiteCode ABC -CMProvider Server1

.LINK
    http://www.sysadmintechnotes.com

.NOTES
    Author:  Duncan Russell
    Email:   duncan@sysadmintechnotes.com
    Date:    02/25/2015
    Version: 1.1
    PSVer:   3.0

#>
Param(
      [string] $SiteCode = "*",

      [string] $CMProvider = "*",

      [switch] $Silent
   )

$global:localSiteCode = ""
$global:localCmProvider = ""

if(($SiteCode -eq "*") -or ($CMProvider -eq "*")){
    $global:showDialog = $True
} else {
    $global:showDialog = $false
    $global:localSiteCode = $SiteCode
    $global:localCmProvider = $CMProvider
}


#region Form Info
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Environment Info"
$objForm.Size = New-Object System.Drawing.Size(300,250) 
$objForm.StartPosition = "CenterScreen"

$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$global:localSiteCode=$objSiteCode.Text;$global:localCmProvider=$objCmProvider.Text;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objForm.Close()}})

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(125,180)
$OKButton.Size = New-Object System.Drawing.Size(50,23)
$OKButton.Text = "OK"
$OKButton.Add_Click({$global:localSiteCode=$objSiteCode.Text;$global:localCmProvider=$objCmProvider.Text;$objForm.Close()})
$objForm.Controls.Add($OKButton)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,10) 
$objLabel.Size = New-Object System.Drawing.Size(280,40) 
$objLabel.Text = "Please enter the information in the space below and click OK:"
$objForm.Controls.Add($objLabel) 

$objLabelSiteCode = New-Object System.Windows.Forms.Label
$objLabelSiteCode.Location = New-Object System.Drawing.Size(10,60) 
$objLabelSiteCode.Size = New-Object System.Drawing.Size(75,20) 
$objLabelSiteCode.Text = "Site Code:"
$objForm.Controls.Add($objLabelSiteCode)

$objSiteCode = New-Object System.Windows.Forms.TextBox 
$objSiteCode.Location = New-Object System.Drawing.Size(110,60) 
$objSiteCode.Size = New-Object System.Drawing.Size(80,20) 
$objForm.Controls.Add($objSiteCode)

$objLabelCmProvider = New-Object System.Windows.Forms.Label
$objLabelCmProvider.Location = New-Object System.Drawing.Size(10,100) 
$objLabelCmProvider.Size = New-Object System.Drawing.Size(100,60) 
$objLabelCmProvider.Text = "CM Provider (Primary, CAS):"
$objForm.Controls.Add($objLabelCmProvider)

$objCmProvider = New-Object System.Windows.Forms.TextBox 
$objCmProvider.Location = New-Object System.Drawing.Size(110,110) 
$objCmProvider.Size = New-Object System.Drawing.Size(170,60) 
$objForm.Controls.Add($objCmProvider)

$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate()})


#endregion

#region static info
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
            "Extensions\Actions\f2c07bfb-d83d-4e0b-969b-5da6321c28c2\TaskSequencePackagePath.xml")
#endregion

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

        #Copy the files
        Copy-Item "$PSSCriptRoot\Files\Extensions" "$($consolePath)XmlStorage\" -Recurse -Force
        Copy-Item "$PSSCriptRoot\Files\GetSCCMObjFolderPath" "$($consolePath)XmlStorage\" -Recurse -Force

        if($global:showDialog) {
            [void] $objForm.ShowDialog()
        }

        #Add Site Code and CMProvider to script file
        ((get-content -Path "$($consolePath)XmlStorage\GetSCCMObjFolderPath\Get-SccmObjFolderPath.ps1") -replace '\[MYSITECODE\]', $global:localSiteCode) -replace '\[MYCMPROVIDER\]', $global:localCmProvider | set-content "$($consolePath)XmlStorage\GetSCCMObjFolderPath\Get-SccmObjFolderPath.ps1" -Encoding Ascii -Force
        Unblock-File -Path "$($consolePath)XmlStorage\GetSCCMObjFolderPath\Get-SccmObjFolderPath.ps1"

        #Edit XML files to add Admin UI path
        foreach($file in $filelist){
            #[ADMINUIPATH]
            ((get-content -Path "$($consolePath)XmlStorage\$($file)") -replace '\[ADMINUIPATH\]', $consolePath) | set-content "$($consolePath)XmlStorage\$($file)" -Encoding Ascii -Force
        }
        
        if($global:showDialog) {
            [void][System.Windows.Forms.MessageBox]::Show("Install Complete." , "Task Completed")
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
