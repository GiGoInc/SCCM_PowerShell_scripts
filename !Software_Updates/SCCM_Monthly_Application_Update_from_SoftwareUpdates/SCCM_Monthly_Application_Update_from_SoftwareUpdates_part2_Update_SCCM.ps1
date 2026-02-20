<#
Remove-PSDrive -Name $SCCMDrive -Force -PSProvider FileSystem
Write-Host $SCCMDrive':' -ForegroundColor Magenta
<#
.Synopsis
This script is intended to be used to download the 3rd party updates from SCCM so they can be used to keep the application packages in SCCM up-to-date.
Specifically it is set to download the download the updates from the Software Update Group 'ADR: 3rd party Updates - Workstations'
It requires no additional parameters, but you may need to change the folder paths to fit your machine or requirements.

.Example
PS C:\> . SCCM_Monthly_Application_Update_from_SoftwareUpdates.ps1
#>
<#
	To be done
	Update Detection method rebuild - update detect method to reflect the new version
    * Adobe Acrobat Pro 2017 - Windows Installer Code
        - {AC76BA86-1033-FFFF-7760-0E1108756300}
        - %ProgramFiles%\Adobe\Acrobat Reader 2017\Reader
            - Greater than or equal to = 17.011.30105
    * Adobe Acrobat Standard 2017 - Windows Installer Code
        - {AC76BA86-1033-FFFF-7760-0E1108756300}
        - %ProgramFiles%\Adobe\Acrobat Reader 2017\Reader
            - Greater than or equal to = 17.011.30105
    * Adobe Reader DC 2017 - Windows Installer Code
        - {AC76BA86-7AD7-FFFF-7B44-AE1108756300}
        - %ProgramFiles%\Adobe\Acrobat Reader 2017\Reader
            - Greater than or equal to = 17.011.30105
    * Flash Installs - all using fileversion check
        - Update filename and version number 
    * Java Updates - product code
        - SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{26A24AE4-039D-4CA4-87B4-2F32180192.0}
        - Greater than or equal to = 8.0.192..11
    * Google Chrome - product code and exe Version
        - {9384EF03-9FE5-3EC9-90EF-D311BEEE71A4}
        - %ProgramFiles(x86)%\Google\Chrome\Application\Chrome.exe
            - Greater than or equal to = 70.0.3538.77
    * Firefox - exe Version
        - %ProgramFiles%\Mozilla Firefox\firefox.exe
            - Greater than or equal to = 61.0.2

#>
$DownloadPath = "D:\Projects\SCCM_Stuff\SCCM_Monthly_Application_Update_from_SoftwareUpdates"
  $FolderLog = "$DownloadPath\Dirs.txt"
cls
# Load SCCM Module
    C:
    CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
    Import-Module ".\ConfigurationManager.psd1"
    CD XX1:
################################################################################################################################
################################################################################################################################
Write-Host "Checking SCCM application versions to be updated..." -ForegroundColor Green
Write-Host ''
Write-Host ''

# Set Mapped Drive to SCCM folder
    $Share = "\\SERVER\Packages"
    $DrivesInUse = (Get-PSDrive -PSProvider FileSystem).Name
    Foreach ($Drives in "MNOPQRSTUVWXYZ".ToCharArray())
    {
        If ($DrivesInUse -notcontains $Drives){$SCCMDrive = New-PSDrive -PSProvider FileSystem -Name $Drives -Root $Share}
        break
    }         
    Write-Host "SCCM Packages folder mapped to: " -NoNewline
    Write-Host $SCCMDrive':' -ForegroundColor Green
####################################################################
#$UpdateFolders = dir -path "$DownloadPath\17008341" -Include @("*.exe","*.msi","*.msp") -Recurse
$Folder        = $null
$UpdateFolders = $null
   $UpdateFile = $null
   $NewFolders = Get-Content $FolderLog
   $NewFolders = $NewFolders | sort -Unique
$UpdateFolders = dir -path $NewFolders -Include @("*.exe","*.msi","*.msp") -Recurse
# Run thru all the update folder with EXE, MSI, or MSP files
ForEach ($Folder in $UpdateFolders)
{
    $UpdateFullPath = $Folder.DirectoryName
    $UpdateFolder = [string]$UpdateFullPath.Replace("$DownloadPath\17008341\",'').split('-')[0] 
    $UpdateVersion = [string]$UpdateFullPath.split('-')[2]
    $UpdateFile = $Folder.Name
    ##################################################################################
    ##################################################################################
    # These update filenames DO NOT change from month to month
    If (($UpdateFolder -eq 'Adobe_Flash_Player_Chrome') -and ($UpdateFile -eq 'install_flash_player_ppapi.exe'))
    {
        $SCCMFolder = "$SCCMDrive"+':\Adobe_Flash\Current\Chrome_PPAPI\'
        $SCCMAppName = 'Adobe Flash Player for Chrome - (Current)'
        [string]$CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
        $CurrentVersion = $CurrentVersion.Split('=')[1].replace('}','')
		If ($CurrentVersion -lt $UpdateVersion)
        {
            Write-Host $CurrentVersion -NoNewline -ForegroundColor Green
            Write-Host ' / ' -NoNewline
            Write-Host $UpdateVersion -NoNewline -ForegroundColor Cyan
            Write-Host " - " -NoNewline
            Write-Host $SCCMAppName -ForegroundColor Magenta
        }
    }
    If (($UpdateFolder -eq 'Adobe_Flash_Player_Firefox') -and ($UpdateFile -eq 'install_flash_player.exe'))
    {
        $SCCMFolder = "$SCCMDrive"+':\Adobe_Flash\Current\Firefox_Plugin\'
        $SCCMAppName = 'Adobe Flash Player for Firefox - (Current)'
        [string]$CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
        $CurrentVersion = $CurrentVersion.Split('=')[1].replace('}','')
		If ($CurrentVersion -lt $UpdateVersion)
        {
            Write-Host $CurrentVersion -NoNewline -ForegroundColor Green
            Write-Host ' / ' -NoNewline
            Write-Host $UpdateVersion -NoNewline -ForegroundColor Cyan
            Write-Host " - " -NoNewline
            Write-Host $SCCMAppName -ForegroundColor Magenta
        }
    }
    If (($UpdateFolder -eq 'Adobe_Flash_Player_Internet_Explorer') -and ($UpdateFile -eq 'install_flash_player_ax.exe'))
    {
        $SCCMFolder = "$SCCMDrive"+':\Adobe_Flash\Current\IE_ActiveX\'
        $SCCMAppName = 'Adobe Flash Player for IE - (Current)'
        [string]$CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
        $CurrentVersion = $CurrentVersion.Split('=')[1].replace('}','')
		If ($CurrentVersion -lt $UpdateVersion)
        {
            Write-Host $CurrentVersion -NoNewline -ForegroundColor Green
            Write-Host ' / ' -NoNewline
            Write-Host $UpdateVersion -NoNewline -ForegroundColor Cyan
            Write-Host " - " -NoNewline
            Write-Host $SCCMAppName -ForegroundColor Magenta
        }
    }
    ##################################################################################
    # These update filenames CHANGE from month to month
    ##################################################################################
    # If (($UpdateFolder -eq 'Adobe_Reader_XI') -and ($UpdateFile -like 'AdbeRdrUpd*.msp'))
    # {
    #     $SCCMFolder = "$SCCMDrive"+':\Adobe_Reader\Current\'
    #     $SCCMAppName = 'Adobe Reader 11 - (Current)'
    #     $Installer = "$SCCMFolder"+"install.ps1"
    #     $CurrentFile = "$SCCMFolder" + 'AdbeRdrUpd*.msp'
    #     $CurrentLine = [regex]'\$Arguments \+\= \"\`\"AdbeRdrUpd[0-9.]+\.msp\`\"\"'
    #     $NewLine = '$Arguments += "`"'+ $UpdateFile+ '`""'
    #     [string]$CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
    #     $CurrentVersion = $CurrentVersion.Split('=')[1].replace('}','')
	# 	If ($CurrentVersion -lt $UpdateVersion)
    #     {
    #         Write-Host $CurrentVersion -NoNewline -ForegroundColor Green
    #         Write-Host ' / ' -NoNewline
    #         Write-Host $UpdateVersion -NoNewline -ForegroundColor Cyan
    #         Write-Host " - " -NoNewline
    #         Write-Host $SCCMAppName -ForegroundColor Magenta
    #     }
    # }
    If ($UpdateFolder -eq 'Firefox_x86')
    {
        Get-ChildItem -Path "$UpdateFolder" -Recurse | Where-Object {($_.Extension -eq ".exe")} | ForEach-Object {
            If ($_.Extension -eq ".exe")
            {
                $File = Get-Item -Path $_.FullName
                $FileName = $File.Name
                Write-Host $FileName
                Rename-Item -Path $File -NewName ("FirefoxSetup_32bit.exe") -PassThru
            }
        }
    }        	
    If (($UpdateFolder -eq 'Firefox_x86') -and ($UpdateFile -like 'FirefoxSetup_32bit.exe'))
    {
        $SCCMFolder = "$SCCMDrive"+':\Firefox\x86\'
        $SCCMAppName = 'Firefox - (Current)'
        [string]$CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
        $CurrentVersion = $CurrentVersion.Split('=')[1].replace('}','')
		If ($CurrentVersion -lt $UpdateVersion)
        {
            Write-Host $CurrentVersion -NoNewline -ForegroundColor Green
            Write-Host ' / ' -NoNewline
            Write-Host $UpdateVersion -NoNewline -ForegroundColor Cyan
            Write-Host " - " -NoNewline
            Write-Host $SCCMAppName -ForegroundColor Magenta
        }
    }
    #If ($UpdateFolder -eq 'Firefox_x64')
    #{
    #    Get-ChildItem -Path "$UpdateFolder" -Recurse | Where-Object {($_.Extension -eq ".exe")} | ForEach-Object {
    #        If ($_.Extension -eq ".exe")
    #        {
    #            $File = Get-Item -Path $_.FullName
    #            $FileName = $File.Name
    #            Write-Host $FileName
    #            Rename-Item -Path $File -NewName ("FirefoxSetup_64bit.exe") -PassThru
    #        }
    #    }
    #}
    #If (($UpdateFolder -eq 'Firefox_x64') -and ($UpdateFile -like 'Firefox Setup*.exe'))
    #{
    #    $SCCMFolder = "$SCCMDrive"+':\Firefox\x64\'
    #    $SCCMAppName = 'Firefox - (Current)'
    #    $Installer = "$SCCMFolder"+"install.ps1"
    #    $CurrentFile = "$SCCMFolder" + "Firefox Setup*.exe"
    #    $CurrentLine = [regex]'Start-Process -Wait -FilePath \"\.\\Firefox Setup [0-9.]+\.exe\" \-ArgumentList \"\-ms\"'
    #    $NewLine = 'Start-Process -Wait -FilePath ".\'+ $UpdateFile+ '" -ArgumentList "-ms"'
    #    [string]$CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
    #    $CurrentVersion = $CurrentVersion.Split('=')[1].replace('}','')
	#	If ($CurrentVersion -lt $UpdateVersion)
    #    {
    #        Write-Host $CurrentVersion -NoNewline -ForegroundColor Green
    #        Write-Host ' / ' -NoNewline
    #        Write-Host $UpdateVersion -NoNewline -ForegroundColor Cyan
    #        Write-Host " - " -NoNewline
    #        Write-Host $SCCMAppName -ForegroundColor Magenta
    #    }
    #}
    If ($UpdateFolder -eq 'Google_Chrome_x86')
    {
        Get-ChildItem -Path "$UpdateFolder" -Recurse | Where-Object {($_.Extension -eq ".msi")} | ForEach-Object {
            If ($_.Extension -eq ".msi")
            {
                $File = Get-Item -Path $_.FullName
                $FileName = $File.Name
                Write-Host $FileName
                Rename-Item -Path $File -NewName ("GoogleChromeStandaloneEnterprise_32bit.msi") -PassThru
            }
        }
    }
    If (($UpdateFolder -eq 'Google_Chrome_x86') -and ($UpdateFile -eq 'GoogleChromeStandaloneEnterprise_32bit.msi'))
    {
        $SCCMFolder = "$SCCMDrive"+':\GoogleChromeEnterprise\'
        $SCCMAppName = 'Google Chrome - (Current)'
        [string]$CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
        $CurrentVersion = $CurrentVersion.Split('=')[1].replace('}','')
		If ($CurrentVersion -lt $UpdateVersion)
        {
            Write-Host $CurrentVersion -NoNewline -ForegroundColor Green
            Write-Host ' / ' -NoNewline
            Write-Host $UpdateVersion -NoNewline -ForegroundColor Cyan
            Write-Host " - " -NoNewline
            Write-Host $SCCMAppName -ForegroundColor Magenta
        }
    }
    #If ($UpdateFolder -eq 'Google_Chrome_x64')
    #{
    #    Get-ChildItem -Path "$UpdateFolder" -Recurse | Where-Object {($_.Extension -eq ".msi")} | ForEach-Object {
    #        If ($_.Extension -eq ".msi")
    #        {
    #            $File = Get-Item -Path $_.FullName
    #            $FileName = $File.Name
    #            Write-Host $FileName
    #            Rename-Item -Path $File -NewName ("GoogleChromeStandaloneEnterprise_64bit.msi") -PassThru
    #        }
    #    }
    #}
    # If (($UpdateFolder -eq 'Google_Chrome_x64') -and ($UpdateFile -eq 'GoogleChromeStandaloneEnterprise_64bit.msi'))
    # {
    #     $SCCMFolder = "$SCCMDrive"+':\GoogleChromeEnterprise\'
    #     $SCCMAppName = 'Google Chrome - (Current)'
    #     [string]$CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
    #     $CurrentVersion = $CurrentVersion.Split('=')[1].replace('}','')
	# 	If ($CurrentVersion -lt $UpdateVersion)
    #     {
    #         Write-Host $CurrentVersion -NoNewline -ForegroundColor Green
    #         Write-Host ' / ' -NoNewline
    #         Write-Host $UpdateVersion -NoNewline -ForegroundColor Cyan
    #         Write-Host " - " -NoNewline
    #         Write-Host $SCCMAppName -ForegroundColor Magenta
    #     }
    # }
    ##If ($UpdateFolder -eq 'Java_Update')
    ##{
    ##    Get-ChildItem -Path "$UpdateFolder" -Recurse | Where-Object {($_.Extension -eq ".exe")} | ForEach-Object {
    ##        If (($_.Extension -eq ".exe") -and ($_.Name -contains "jre-"))
    ##        {
    ##            $File = Get-Item -Path $_.FullName
    ##            $FileName = $File.Name
    ##            Write-Host $FileName
    ##            Rename-Item -Path $File -NewName ("GoogleChromeStandaloneEnterprise_64bit.exe") -PassThru
    ##        }
    ##    }
    ##}
    If (($UpdateFolder -eq 'Java_Update') -and ($UpdateFile -like 'jre-*-windos-i586.exe'))
    {
        $SCCMFolder = "$SCCMDrive"+':\Java\Current\x32\'
        $SCCMAppName = 'Java 8.x 32-bit - (Current)'
        $Installer = "$SCCMFolder"+"install.ps1"
        $CurrentFile = "$SCCMFolder" + 'jre-*-windos-i586.exe'
        $CurrentLine = [regex]'Start-Process -Wait -FilePath \"\.\\jre-8u[0-9.]+-windos-i586\.exe" \-ArgumentList "INSTALLCFG=\$CurrentDirectory\\jre-install-options\.txt" -Wait -WindowStyle Hidden'
        $NewLine = 'Start-Process "$CurrentDirectory\'+ $UpdateFile+ '" -ArgumentList "INSTALLCFG=$CurrentDirectory\jre-install-options.txt" -Wait -WindowStyle Hidden'
        [string]$CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
        $CurrentVersion = $CurrentVersion.Split('=')[1].replace('}','')
		If ($CurrentVersion -lt $UpdateVersion)
        {
            Write-Host $CurrentVersion -NoNewline -ForegroundColor Green
            Write-Host ' / ' -NoNewline
            Write-Host $UpdateVersion -NoNewline -ForegroundColor Cyan
            Write-Host " - " -NoNewline
            Write-Host $SCCMAppName -ForegroundColor Magenta
        }
    } 
    If (($UpdateFolder -eq 'Java_Update_x64') -and ($UpdateFile -like 'jre-*-windos-x64.exe'))
    {
        $SCCMFolder = "$SCCMDrive"+':\Java\Current\x64\'
        $SCCMAppName = 'Java 8.x 64-bit - (Current)'
        $Installer = "$SCCMFolder"+"install.ps1"
        $CurrentFile = "$SCCMFolder" + 'jre-*-windows-x64.exe'
        $CurrentLine = [regex]'Start-Process -Wait -FilePath \"\.\\jre-8u[0-9.]+-windos-x64\.exe" \-ArgumentList "INSTALLCFG=\$CurrentDirectory\\jre-install-options\.txt" -Wait -WindowStyle Hidden'
        $NewLine = 'Start-Process "$CurrentDirectory\'+ $UpdateFile+ '" -ArgumentList "INSTALLCFG=$CurrentDirectory\jre-install-options.txt" -Wait -WindowStyle Hidden'
        [string]$CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
        $CurrentVersion = $CurrentVersion.Split('=')[1].replace('}','')
		If ($CurrentVersion -lt $UpdateVersion)
        {
            Write-Host $CurrentVersion -NoNewline -ForegroundColor Green
            Write-Host ' / ' -NoNewline
            Write-Host $UpdateVersion -NoNewline -ForegroundColor Cyan
            Write-Host " - " -NoNewline
            Write-Host $SCCMAppName -ForegroundColor Magenta
        }
    }
    If (($UpdateFolder -eq 'Notepad++') -and ($UpdateFile -like 'npp.*.Installer.exe'))
    {
        $SCCMFolder = "$SCCMDrive"+':\Notepad++\'
        $SCCMAppName = 'Notepad++ - (Current)'
        $Installer = "$SCCMFolder"+"install.ps1"
        $CurrentFile = "$SCCMFolder" + 'npp*Installer.exe'
        $CurrentLine = [regex]'Start-Process "\$CurrentDirectory\\npp[0-9.]+\.Installer.exe" -ArgumentList "\/S" -Wait -WindowStyle Hidden'
        $NewLine = 'Start-Process "$CurrentDirectory\'+ $UpdateFile+ '" -ArgumentList "/S" -Wait -WindowStyle Hidden'
        [string]$CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
        $CurrentVersion = $CurrentVersion.Split('=')[1].replace('}','')
		If ($CurrentVersion -lt $UpdateVersion)
        {
            Write-Host $CurrentVersion -NoNewline -ForegroundColor Green
            Write-Host ' / ' -NoNewline
            Write-Host $UpdateVersion -NoNewline -ForegroundColor Cyan
            Write-Host " - " -NoNewline
            Write-Host $SCCMAppName -ForegroundColor Magenta
        }
    }
    # # Acrobat update is applied to two installs Pro and Standard
    # ######## Information for ACROBAT PRO
    # If (($UpdateFolder -eq 'Adobe_Acrobat_XI') -and ($UpdateFile -like 'AcrobatUpd*.msp'))
    # {
    #     $SCCMFolder = "$SCCMDrive"+':\Adobe_Acrobat\XI_Pro\'
    #     $SCCMAppName = 'Adobe Acrobat 11 Pro - (Current)'
    #     $Installer = "$SCCMFolder"+"install.ps1"
    #     $CurrentFile = "$SCCMFolder" + 'AcrobatUpd*.msp'
    #     $CurrentLine = [regex]'\$Arguments \+\= \"\`\"AcrobatUpd[0-9.]+\.msp\`\"\"'
    #     $NewLine = '$Arguments += "`"'+ $UpdateFile+ '`""'
    #     [string]$CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
    #     $CurrentVersion = $CurrentVersion.Split('=')[1].replace('}','')
	# 	If ($CurrentVersion -lt $UpdateVersion)
    #     {
    #         Write-Host $CurrentVersion -NoNewline -ForegroundColor Green
    #         Write-Host ' / ' -NoNewline
    #         Write-Host $UpdateVersion -NoNewline -ForegroundColor Cyan
    #         Write-Host " - " -NoNewline
    #         Write-Host $SCCMAppName -ForegroundColor Magenta
    #     }
    # }
    # ######## Information for ACROBAT STANDARD
    # If (($UpdateFolder -eq 'Adobe_Acrobat_XI') -and ($UpdateFile -like 'AcrobatUpd*.msp'))
    # {
    #     $SCCMFolder = "$SCCMDrive"+':\Adobe_Acrobat\XI_Std\'
    #     $SCCMAppName = 'Adobe Acrobat 11 Standard - (Current)'
    #     $Installer = "$SCCMFolder"+"install.ps1"
    #     $CurrentFile = "$SCCMFolder" + 'AcrobatUpd*.msp'
    #     $CurrentLine = [regex]'\$Arguments \+\= \"\`\"AcrobatUpd[0-9.]+\.msp\`\"\"'
    #     $NewLine = '$Arguments += "`"'+ $UpdateFile+ '`""'
    #     [string]$CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
    #     $CurrentVersion = $CurrentVersion.Split('=')[1].replace('}','')
	# 	If ($CurrentVersion -lt $UpdateVersion)
    #     {
    #         Write-Host $CurrentVersion -NoNewline -ForegroundColor Green
    #         Write-Host ' / ' -NoNewline
    #         Write-Host $UpdateVersion -NoNewline -ForegroundColor Cyan
    #         Write-Host " - " -NoNewline
    #         Write-Host $SCCMAppName -ForegroundColor Magenta
    #     }
    # }
    # Acrobat update is applied to two installs Pro and Standard
    ######## Information for ACROBAT PRO
############################    If (($UpdateFolder -eq 'Adobe_Acrobat_DC') -and ($UpdateFile -like 'Acrobat2017Upd*.msp'))
############################    {
############################        $SCCMFolder = "$SCCMDrive"+':\Adobe_Acrobat\2017_Pro\'
############################        $SCCMAppName = 'Adobe Acrobat 2017 Pro'
############################        $Installer = "$SCCMFolder"+"install.ps1"
############################        $CurrentFile = "$SCCMFolder" + 'Acrobat2017Upd*.msp'
############################        $CurrentLine = [regex]'\$Arguments \+\= \"\`\"Acrobat2017Upd[0-9.]+\.msp\`\"\"'
############################        $NewLine = '$Arguments += "`"'+ $UpdateFile+ '`""'
############################        [string]$CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
############################        $CurrentVersion = $CurrentVersion.Split('=')[1].replace('}','')
############################    	If ($CurrentVersion -lt $UpdateVersion)
############################        {
############################            Write-Host $CurrentVersion -NoNewline -ForegroundColor Green
############################            Write-Host ' / ' -NoNewline
############################            Write-Host $UpdateVersion -NoNewline -ForegroundColor Cyan
############################            Write-Host " - " -NoNewline
############################            Write-Host $SCCMAppName -ForegroundColor Magenta
############################        }
############################    }
############################    ######## Information for ACROBAT STANDARD
############################    If (($UpdateFolder -eq 'Adobe_Acrobat_DC') -and ($UpdateFile -like 'Acrobat2017Upd*.msp'))
############################    {
############################        $SCCMFolder = "$SCCMDrive"+':\Adobe_Acrobat\2017_Std\'
############################        $SCCMAppName = 'Adobe Acrobat 2017 Standard'
############################        $Installer = "$SCCMFolder"+"install.ps1"
############################        $CurrentFile = "$SCCMFolder" + 'Acrobat2017Upd*.msp'
############################        $CurrentLine = [regex]'\$Arguments \+\= \"\`\"Acrobat2017Upd[0-9.]+\.msp\`\"\"'
############################        $NewLine = '$Arguments += "`"'+ $UpdateFile+ '`""'
############################        [string]$CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
############################        $CurrentVersion = $CurrentVersion.Split('=')[1].replace('}','')
############################    	If ($CurrentVersion -lt $UpdateVersion)
############################        {
############################            Write-Host $CurrentVersion -NoNewline -ForegroundColor Green
############################            Write-Host ' / ' -NoNewline
############################            Write-Host $UpdateVersion -NoNewline -ForegroundColor Cyan
############################            Write-Host " - " -NoNewline
############################            Write-Host $SCCMAppName -ForegroundColor Magenta
############################        }
############################    }
}
################################################################################################################################
################################################################################################################################
################################################################################################################################
Write-Host ''
Write-Host ''
Write-Host "AAAAANNNNNNDDDDD.....now to update the SCCM application packages!" -ForegroundColor Green
Write-Host ''
Write-Host "ARE YOU READY TO UPDATE THE SCCM PACKAGES TOO???"-ForegroundColor Red
Write-Host ''
Write-Host "If not, then you'll need to run " -NoNewline
Write-Host "D:\Projects\SCCM_Monthly_Application_Update_from_SoftwareUpdates\SCCM_Monthly_Application_Update_from_SoftwareUpdates_part2_Update_SCCM.ps1 " -NoNewline -ForegroundColor Cyan
Write-Host "later."
Write-Host ''
Read-Host -Prompt "Press any key to continue or CTRL+C to quit"


# Run thru all the update folder with EXE, MSI, or MSP files
ForEach ($Folder in $UpdateFolders)
{
    $UpdateFullPath = $Folder.DirectoryName
    $UpdateFolder = [string]$UpdateFullPath.Replace("$DownloadPath\17008341\",'').split('-')[0]
    
    $UpdateVersion = [string]$UpdateFullPath.split('-')[2]
    $UpdateFile = $Folder.Name

    ##################################################################################
    ##################################################################################
    # These update filenames DO NOT change from month to month
    Function StaticUpdates
    {
            Write-Host "Copying: " -NoNewline
            Write-Host "$UpdateFullPath\$UpdateFile " -NoNewline -ForegroundColor Green
            Write-Host "to " -NoNewline
            Write-Host "$SCCMFolder" -ForegroundColor Cyan
                Copy-Item -Path  "$UpdateFullPath\$UpdateFile" -Destination $SCCMFolder
        
            Write-Host "Updating: " -NoNewline
            Write-Host "$SCCMAppName " -NoNewline -ForegroundColor Green
            Write-Host "Software Version to: " -NoNewline
            Write-Host "$UpdateVersion" -ForegroundColor Magenta
                Set-CMApplication -Name $SCCMAppName -SoftwareVersion $UpdateVersion
        
            Write-Host "Updating : " -NoNewline
            Write-Host "$SCCMAppName " -NoNewline -ForegroundColor cyan
            Write-Host "package content on DPs "
            Write-Host ""
                $DeploymentType = Get-CMDeploymentType -ApplicationName $SCCMAppName
                Update-CMDistributionPoint -ApplicationName $SCCMAppName -DeploymentTypeName $DeploymentType.LocalizedDisplayName
    }

    If (($UpdateFolder -eq 'Adobe_Flash_Player_Chrome') -and ($UpdateFile -eq 'install_flash_player_ppapi.exe'))
    {
        $SCCMFolder = "$SCCMDrive"+':\Adobe_Flash\Current\Chrome_PPAPI\'
        $SCCMAppName = 'Adobe Flash Player for Chrome - (Current)'
        $CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
        If ($CurrentVersion -lt $UpdateVersion){StaticUpdates}
    }
    If (($UpdateFolder -eq 'Adobe_Flash_Player_Firefox') -and ($UpdateFile -eq 'install_flash_player.exe'))
    {
        $SCCMFolder = "$SCCMDrive"+':\Adobe_Flash\Current\Firefox_Plugin\'
        $SCCMAppName = 'Adobe Flash Player for Firefox - (Current)'
        $CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
        If ($CurrentVersion -lt $UpdateVersion){StaticUpdates}
    }
    If (($UpdateFolder -eq 'Adobe_Flash_Player_Internet_Explorer') -and ($UpdateFile -eq 'install_flash_player_ax.exe'))
    {
        $SCCMFolder = "$SCCMDrive"+':\Adobe_Flash\Current\IE_ActiveX\'
        $SCCMAppName = 'Adobe Flash Player for IE - (Current)'
        $CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
        If ($CurrentVersion -lt $UpdateVersion){StaticUpdates}
    }
    #If (($UpdateFolder -eq 'Google_Chrome_x64') -and ($UpdateFile -eq 'GoogleChromeStandaloneEnterprise64.msi'))
    #{
    #    $SCCMFolder = "$SCCMDrive"+':\GoogleChromeEnterprise\'
    #    $SCCMAppName = 'Google Chrome - (Current)'
    #    $CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
    #    If ($CurrentVersion -lt $UpdateVersion){StaticUpdates}
    #}
    If (($UpdateFolder -eq 'Google_Chrome_x86') -and ($UpdateFile -eq 'GoogleChromeStandaloneEnterprise.msi'))
    {
        $SCCMFolder = "$SCCMDrive"+':\GoogleChromeEnterprise\'
        $SCCMAppName = 'Google Chrome - (Current)'
        $CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
        If ($CurrentVersion -lt $UpdateVersion){StaticUpdates}
    }
}
<#############################
    ##################################################################################
    ##################################################################################
    # These update filenames CHANGE from month to month
    Function SemiStaticUpdates
    {
        Write-Host "Removing current file from SCCM packages folder: " -NoNewline
        Write-Host $CurrentFile -ForegroundColor Cyan
            Remove-Item $CurrentFile -Force

        Write-Host "Copying: " -NoNewline
        Write-Host "$UpdateFullPath\$UpdateFile " -NoNewline -ForegroundColor Green
        Write-Host "to " -NoNewline
        Write-Host "$SCCMFolder" -ForegroundColor Cyan
            Copy-Item -Path  "$UpdateFullPath\$UpdateFile" -Destination $SCCMFolder
    
        Write-Host "Updating script with new installer line in: " -NoNewline
        Write-Host "$Installer " -ForegroundColor Green
        Write-Host "Updated line will read: " -NoNewline
        Write-Host "$NewLine " -ForegroundColor Magenta
            (Get-Content "$Installer") -replace $CurrentLine, $NewLine | Set-Content "$Installer"
            
        Write-Host "Updating: " -NoNewline
        Write-Host "$SCCMAppName " -NoNewline -ForegroundColor Green
        Write-Host "Software Version to: " -NoNewline
        Write-Host "$UpdateVersion" -ForegroundColor Magenta
            Set-CMApplication -Name $SCCMAppName -SoftwareVersion $UpdateVersion
    
        Write-Host "Updating : " -NoNewline
        Write-Host "$SCCMAppName " -NoNewline -ForegroundColor cyan
        Write-Host "package content on DPs "
        Write-Host ""
            $DeploymentType = Get-CMDeploymentType -ApplicationName $SCCMAppName
            Update-CMDistributionPoint -ApplicationName $SCCMAppName -DeploymentTypeName $DeploymentType.LocalizedDisplayName
    }

    #If (($UpdateFolder -eq 'Adobe_Reader_XI') -and ($UpdateFile -like 'AdbeRdrUpd*.msp'))
    #{
    #    $SCCMFolder = "$SCCMDrive"+':\Adobe_Reader\Current\'
    #    $SCCMAppName = 'Adobe Reader 11 - (Current)'
    #    $Installer = "$SCCMFolder"+"install.ps1"
    #    $CurrentFile = "$SCCMFolder" + 'AdbeRdrUpd*.msp'
    #    $CurrentLine = [regex]'\$Arguments \+\= \"\`\"AdbeRdrUpd[0-9.]+\.msp\`\"\"'
    #    $NewLine = '$Arguments += "`"'+ $UpdateFile+ '`""'
    #    $CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
    #    If ($CurrentVersion -lt $UpdateVersion){SemiStaticUpdates}
    #}
        	
    If (($UpdateFolder -eq 'Firefox_x86') -and ($UpdateFile -like 'Firefox Setup*.exe'))
    {
        $SCCMFolder = "$SCCMDrive"+':\Firefox\x86\'
        $SCCMAppName = 'Firefox - (Current)'
        $Installer = "$SCCMFolder"+"install.ps1"
        $CurrentFile = "$SCCMFolder" + "Firefox Setup*.exe"
        $CurrentLine = [regex]'Start-Process -Wait -FilePath \"\.\\Firefox Setup [0-9.]+\.exe\" \-ArgumentList \"\-ms\"'
        $NewLine = 'Start-Process -Wait -FilePath ".\'+ $UpdateFile+ '" -ArgumentList "-ms"'
        $CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
        If ($CurrentVersion -lt $UpdateVersion){SemiStaticUpdates}
    }
     
    If (($UpdateFolder -eq 'Java_Update') -and ($UpdateFile -like 'jre-*-windos-i586.exe'))
    {
        $SCCMFolder = "$SCCMDrive"+':\Java\Current\x32\'
        $SCCMAppName = 'Java 8.x 32-bit - (Current)'
        $Installer = "$SCCMFolder"+"install.ps1"
        $CurrentFile = "$SCCMFolder" + 'jre-*-windos-i586.exe'
        $CurrentLine = [regex]'Start-Process "\$CurrentDirectory\\jre-8u[0-9.]+-windos-i586\.exe" \-ArgumentList "INSTALLCFG=\$CurrentDirectory\\jre-install-options\.txt" -Wait -WindowStyle Hidden'
        $NewLine = 'Start-Process "$CurrentDirectory\'+ $UpdateFile+ '" -ArgumentList "INSTALLCFG=$CurrentDirectory\jre-install-options.txt" -Wait -WindowStyle Hidden'
        $CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
        If ($CurrentVersion -lt $UpdateVersion){SemiStaticUpdates}
    }
    
    If (($UpdateFolder -eq 'Java_Update_x64') -and ($UpdateFile -like 'jre-*-windos-x64.exe'))
    {
        $SCCMFolder = "$SCCMDrive"+':\Java\Current\x64\'
        $SCCMAppName = 'Java 8.x 64-bit - (Current)'
        $Installer = "$SCCMFolder"+"install.ps1"
        $CurrentFile = "$SCCMFolder" + 'jre-*-windos-x64.exe'
        $CurrentLine = [regex]'Start-Process "\$CurrentDirectory\\jre-8u[0-9.]+-windos-x64\.exe" \-ArgumentList "INSTALLCFG=\$CurrentDirectory\\jre-install-options\.txt" -Wait -WindowStyle Hidden'
        $NewLine = 'Start-Process "$CurrentDirectory\'+ $UpdateFile+ '" -ArgumentList "INSTALLCFG=$CurrentDirectory\jre-install-options.txt" -Wait -WindowStyle Hidden'
        $CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
        If ($CurrentVersion -lt $UpdateVersion){SemiStaticUpdates}
    }

    #If (($UpdateFolder -eq 'Notepad++') -and ($UpdateFile -like 'npp.*.Installer.exe'))
    #{
    #    $SCCMFolder = "$SCCMDrive"+':\Notepad++\'
    #    $SCCMAppName = 'Notepad++ - (Current)'
    #    $Installer = "$SCCMFolder"+"install.ps1"
    #    $CurrentFile = "$SCCMFolder" + 'npp*Installer.exe'
    #    $CurrentLine = [regex]'Start-Process "\$CurrentDirectory\\npp[0-9.]+\.Installer.exe" -ArgumentList "\/S" -Wait -WindowStyle Hidden'
    #    $NewLine = 'Start-Process "$CurrentDirectory\'+ $UpdateFile+ '" -ArgumentList "/S" -Wait -WindowStyle Hidden'
    #    $CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
    #    If ($CurrentVersion -lt $UpdateVersion){SemiStaticUpdates}
    #}

    # Acrobat update is applied to two installs Pro and Standard
    ######### Information for ACROBAT PRO
    #If (($UpdateFolder -eq 'Adobe_Acrobat_XI') -and ($UpdateFile -like 'AcrobatUpd*.msp'))
    #{
    #    $SCCMFolder = "$SCCMDrive"+':\Adobe_Acrobat\XI_Pro\'
    #    $SCCMAppName = 'Adobe Acrobat 11 Pro - (Current)'
    #    $Installer = "$SCCMFolder"+"install.ps1"
    #    $CurrentFile = "$SCCMFolder" + 'AcrobatUpd*.msp'
    #    $CurrentLine = [regex]'\$Arguments \+\= \"\`\"AcrobatUpd[0-9.]+\.msp\`\"\"'
    #    $NewLine = '$Arguments += "`"'+ $UpdateFile+ '`""'
    #    $CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
    #    If ($CurrentVersion -lt $UpdateVersion){SemiStaticUpdates}
    #}
    ######### Information for ACROBAT STANDARD
    #If (($UpdateFolder -eq 'Adobe_Acrobat_XI') -and ($UpdateFile -like 'AcrobatUpd*.msp'))
    #{
    #    $SCCMFolder = "$SCCMDrive"+':\Adobe_Acrobat\XI_Std\'
    #    $SCCMAppName = 'Adobe Acrobat 11 Standard - (Current)'
    #    $Installer = "$SCCMFolder"+"install.ps1"
    #    $CurrentFile = "$SCCMFolder" + 'AcrobatUpd*.msp'
    #    $CurrentLine = [regex]'\$Arguments \+\= \"\`\"AcrobatUpd[0-9.]+\.msp\`\"\"'
    #    $NewLine = '$Arguments += "`"'+ $UpdateFile+ '`""'
    #    $CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
    #    If ($CurrentVersion -lt $UpdateVersion){SemiStaticUpdates}
    #}
    ######### Information for ACROBAT PRO
    If (($UpdateFolder -eq 'Adobe_Acrobat_DC') -and ($UpdateFile -like 'Acrobat2017Upd*.msp'))
    {
        $SCCMFolder = "$SCCMDrive"+':\Adobe_Acrobat\2017_Pro\'
        $SCCMAppName = 'Adobe Acrobat 2017 Pro'
        $Installer = "$SCCMFolder"+"install.ps1"
        $CurrentFile = "$SCCMFolder" + 'Acrobat2017Upd*.msp'
        $CurrentLine = [regex]'\$Arguments \+\= \"\`\"Acrobat2017Upd[0-9.]+\.msp\`\"\"'
        $NewLine = '$Arguments += "`"'+ $UpdateFile+ '`""'
        $CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
        If ($CurrentVersion -lt $UpdateVersion){SemiStaticUpdates}
    }
    ######## Information for ACROBAT STANDARD
    If (($UpdateFolder -eq 'Adobe_Acrobat_DC') -and ($UpdateFile -like 'Acrobat2017Upd*.msp'))
    {
        $SCCMFolder = "$SCCMDrive"+':\Adobe_Acrobat\2017_Std\'
        $SCCMAppName = 'Adobe Acrobat 2017 Standard'
        $Installer = "$SCCMFolder"+"install.ps1"
        $CurrentFile = "$SCCMFolder" + 'Acrobat2017Upd*.msp'
        $CurrentLine = [regex]'\$Arguments \+\= \"\`\"Acrobat2017Upd[0-9.]+\.msp\`\"\"'
        $NewLine = '$Arguments += "`"'+ $UpdateFile+ '`""'
        $CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
        If ($CurrentVersion -lt $UpdateVersion){SemiStaticUpdates}
    }
}
#############################>

Write-Host "Removing SCCM Packages folder mapping to: " -NoNewline
Write-Host $SCCMDrive':' -ForegroundColor Magenta
Remove-PSDrive -Name $SCCMDrive -Force -PSProvider FileSystem
