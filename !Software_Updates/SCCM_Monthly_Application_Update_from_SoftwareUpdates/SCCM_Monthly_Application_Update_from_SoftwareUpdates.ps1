<#
Remove-PSDrive -Name $SCCMDrive -Force -PSProvider FileSystem
Write-Host $SCCMDrive':' -ForegroundColor Magenta
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
	
	Update Adobe Detection methods - update detect method regkey to reflect the new version


#>

# Set Proxy for HTTP connection in BITS
Read-Host -Prompt 'Freakin proxy....Press Enter and put in your A account info.'
$webclient = New-Object System.Net.WebClient
$creds = Get-Credential
$webclient.Proxy.Credentials = $creds

Function CleanupName($line)
{
        $string = $line.Replace(')','').Replace('(','')
        $SplitName = $String.split(' ')
    
        $NewArr = @()
        $NewNum = @()
        ForEach ($split in $Splitname)
        {
            # If string starts with a number add to array
            If ($split -match "^\d")
            {
                $NewNum  = $NewNum += $split+'.'
            }
    
            # If string does not start with a number add to another array
            If (!($split -match "^\d"))
            {
                $NewArr = $NewArr += $split+'_'
            }
        }
    
        # Compile arrays to strings and fix
            [string]$NewNum = $NewNum.replace(' ','')
                    $NewNum = $NewNum.TrimEnd('.')
    
            $NewLine = "$NewArr$NewNum"
    
        Write-Host "`nNew Line: " -NoNewline 
        Write-Host "$NewLine" -ForegroundColor Green
}

[System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.dll")) | Out-Null
[System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.Extender.dll")) | Out-Null
[System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.MsiInstaller.dll")) | Out-Null
 
$SiteServer = "SERVER"
$SiteCode = "XX1"

$Class = Get-WmiObject -ComputerName $SiteServer -Namespace root\SMS\site_$SiteCode -Class SMS_AuthorizationList -list
$UpdateGroup = $Class.GetInstances()
$UpdateCount = $UpdateGroup.Count

CLS
Write-Output "`n"
Write-Output "INFO: There is a total of $($UpdateCount) Update Groups`n"
Write-Host "Starting Source Path Check`t$(Get-Date)" -ForegroundColor Cyan
Write-Host "This should take about five minutes..." -ForegroundColor Yellow


# Set Mapped Drive to SCCM folder
    $Share = "\\SERVER\Packages"
    $DrivesInUse = (Get-PSDrive -PSProvider FileSystem).Name
    Foreach ($Drives in "FGIJKLMNOPQRSTUVWXYZ".ToCharArray())
    {
        If ($DrivesInUse -notcontains $Drives){$SCCMDrive = New-PSDrive -PSProvider FileSystem -Name $Drives -Root $Share}
        break
    }         
    Write-Host "SCCM Packages folder mapped to: " -NoNewline
    Write-Host $SCCMDrive':' -ForegroundColor Green

#region Download the Software Updates

#Create a new PSDrive where the Patches will be downloaded
$DownloadPath = "D:\Projects\SCCM_Stuff\SCCM_Monthly_Application_Update_from_SoftwareUpdates"
  $FolderLog = "$DownloadPath\Dirs.txt"
    $AppInfo = "$DownloadPath\AppInfo.txt"
$UpdateFiles = "$DownloadPath\Updates_Information.txt"

  If (Test-Path $FolderLog){Remove-Item $FolderLog}
    If (Test-Path $AppInfo){Remove-Item $AppInfo}
If (Test-Path $UpdateFiles){Remove-Item $UpdateFiles}
explorer.exe "D:\Projects\SCCM_Stuff\SCCM_Monthly_Application_Update_from_SoftwareUpdates\17008341"
$UpdateNamesArray = @()
ForEach ($Update in $UpdateGroup)
{
    # CIID: 17008342 	SUGName: ADR: 3rd party Updates - Workstations - Test
    # CIID: 17017840 	SUGName: ADR: 3rd Party Updates for Workstations - Weekly
    # CIID: 17008341 	SUGName: ADR: 3rd party Updates - Workstations

    $CIID = $Update.CI_ID
    $SUGName = $Update.LocalizedDisplayName

    If (($SUGName -eq 'ADR: 3rd party Updates - Workstations') -or `
        ($SUGName -eq 'ADR: 3rd party Updates - Workstations - Test') -or `
        ($SUGName -eq 'ADR: 3rd Party Updates for Workstations - Weekly'))
    {
        $SUGContents = Get-CimInstance -ComputerName $SiteServer -Namespace root\SMS\site_XX1 -Query "Select ContentID,ContentUniqueID,ContentLocales from SMS_CITOContent Where CI_ID='$CIID'"

        # Filter out the English Local and ContentID's not targeted to a particular Language
            #$SUGContents = $SUGContents  | Where {($_.ContentLocales -eq "Locale:9") -or ($_.ContentLocales -eq "Locale:0") }

        ForEach ($ContentItem in $SUGContents)
        {
            #       ContentID = 17109947
            #  ContentLocales = {Locale:0}
            # ContentUniqueID = ffc11950-eb16-48c8-8e51-50acbfcf066f
            #  PSComputerName = SERVER

             $CID = $ContentItem.ContentID 
              $CL = $ContentItem.ContentLocales
            $CUID = $ContentItem.ContentUniqueID

            $ContentFile = Get-CimInstance -ComputerName $SiteServer -Namespace root\SMS\site_XX1 -Query "Select FileName,SourceURL from SMS_CIContentfiles WHERE ContentID='$CID'"
            $UN = Get-WmiObject -ComputerName $SiteServer -Namespace root\sms\site_XX1 -query "SELECT LocalizedDisplayName from SMS_SoftwareUpdate where CI_UniqueID='$CUID'" | SELECT LocalizedDisplayName -first 1
            $UpdateName = $UN.LocalizedDisplayName.Replace(')','').Replace('(','')
            $SplitName = $UpdateName.split(' ')
            $UpdateNamesArray += $UpdateName

        ForEach ($UContent in $ContentFile)
        {
                $SUL = $UContent.SourceURL
                 $FN = $UContent.FileName
                $UFolder = "$DownloadPath\17008341"

            ### Cleanup Update Folder Name
            $string = $UpdateName.Replace(')','').Replace('(','')
            $SplitName = $String.split(' ')
    
            $NewArr = @()
            $NewNum = @()
            ForEach ($split in $Splitname)
            {
                # If string starts with a number add to array
                    If ($split -match "^\d"){$NewNum  = $NewNum += $split+'.'}
    
                # If string does not start with a number add to another array
                    If (!($split -match "^\d")){$NewArr = $NewArr += $split+'_'}
            }
            # Compile arrays to strings and fix
                [string]$NewNum = $NewNum.replace(' ','')
                        $NewNum = $NewNum.TrimEnd('.')

                [string]$NewArr = $NewArr.TrimEnd('_')
                $UpdateNewName = $NewArr+'--'+$NewNum
    
        # Additional Variables
                $DFolder = "$UFolder\$UpdateNewName"
                $DFile = "$UFolder\$UpdateNewName\$FN"

                If (!(Test-Path -Path $UFolder)){New-Item -ItemType Directory -Path $UFolder | Out-Null}
                If (!(Test-Path -Path $DFolder))
                {
                    Write-Host "`n   Parent folder: $DownloadPath\$CIID"
                    Write-Host "`n      New Update: " -NoNewline 
                    Write-Host "$UpdateNewName" -ForegroundColor Green

                    New-Item -ItemType Directory -Path $DFolder | Out-Null
                    Write-Host "Creating subfolder: " -NoNewline
                    Write-Host "$UpdateNewName" -Foregroundcolor Cyan

                    Write-Host "   Copying updates... " -Foregroundcolor Magenta -NoNewline
                    Try
                    {
                        Start-BitsTransfer -Source $SUL -Destination $DFile -ErrorAction SilentlyContinue
                        Write-Host ''
                    }
                    Catch
                    {
                        Write-Host $Error[0] -ForegroundColor Red
                        $Error.Clear() # Clear the $Error collection
                    }
                    $DFolder | Add-Content $FolderLog

                    If(C:\Windows\System32\expand.exe)
                    {
                        Try
                        {
                            Write-Host "Extracting updates...`n" -Foregroundcolor Green
                            cmd.exe /c "expand -r `"$DFile`" -f:* `"$DFolder`"" | Out-Null
                        }
                        Catch
                        {
                            Write-host "Cannot find C:\Windows\System32\expand.exe"
                        }
                    }
                    
                    "$NewArr;$NewNum" | Add-Content $AppInfo
                }
               Else
               {
                    $UpdateNewName = $UpdateName.replace('_',' ').replace('-',' ')
                    Write-Host "Ignoring previously downloaded update: " -NoNewline
                    Write-Host "$UpdateNewName" -Foregroundcolor Cyan
               }
            }
        }
    } # END -- If ($SUGName -eq 'ADR: 3rd party Updates - Workstations')

} # END -- ForEach ($Update in $UpdateGroup)
$UpdateNamesArray | sort -unique | Add-Content $AppInfo



# Unblock all the new downloads
    Get-ChildItem -Path $UFolder -Recurse | Unblock-File

Write-Host "`n"
Write-Host "AAAAANNNNNNDDDDD.....we're done copying over the updates!" -ForegroundColor Green
start-sleep -seconds 3

<#
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
$UpdateFolders = dir -path $NewFolders -Include @("*.exe","*.msi","*.msp") -Recurse

# Run thru all the update folder with EXE, MSI, or MSP files
ForEach ($Folder in $UpdateFolders)
{
    $UpdateFullPath = $Folder.DirectoryName
    $UpdateFolder = [string]$UpdateFullPath.Replace("$DownloadPath\17008341\",'').split('-')[0].Replace("$DownloadPath\17008342\",'').split('-')[0].Replace("$DownloadPath\17017840\",'').split('-')[0]
    
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
    If (($UpdateFolder -eq 'Google_Chrome') -and ($UpdateFile -eq 'GoogleChromeStandaloneEnterprise.msi'))
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

    ##################################################################################
    ##################################################################################
    # These update filenames CHANGE from month to month

    If (($UpdateFolder -eq 'Adobe_Reader_XI') -and ($UpdateFile -like 'AdbeRdrUpd*.msp'))
    {
        $SCCMFolder = "$SCCMDrive"+':\Adobe_Reader\Current\'
        $SCCMAppName = 'Adobe Reader 11 - (Current)'
        $Installer = "$SCCMFolder"+"install.ps1"
        $CurrentFile = "$SCCMFolder" + 'AdbeRdrUpd*.msp'
        $CurrentLine = [regex]'\$Arguments \+\= \"\`\"AdbeRdrUpd[0-9.]+\.msp\`\"\"'
        $NewLine = '$Arguments += "`"'+ $UpdateFile+ '`""'
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
        	
    If (($UpdateFolder -eq 'Firefox') -and ($UpdateFile -like 'Firefox Setup*.exe'))
    {
        $SCCMFolder = "$SCCMDrive"+':\Firefox\x86\'
        $SCCMAppName = 'Firefox - (Current)'
        $Installer = "$SCCMFolder"+"install.ps1"
        $CurrentFile = "$SCCMFolder" + "Firefox Setup*.exe"
        $CurrentLine = [regex]'Start-Process -Wait -FilePath \"\.\\Firefox Setup [0-9.]+\.exe\" \-ArgumentList \"\-ms\"'
        $NewLine = 'Start-Process -Wait -FilePath ".\'+ $UpdateFile+ '" -ArgumentList "-ms"'
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
     
    If (($UpdateFolder -eq 'Java_Update') -and ($UpdateFile -like 'jre-*-windows-i586.exe'))
    {
        $SCCMFolder = "$SCCMDrive"+':\Java\Current\x32\'
        $SCCMAppName = 'Java 8.x 32-bit - (Current)'
        $Installer = "$SCCMFolder"+"install.ps1"
        $CurrentFile = "$SCCMFolder" + 'jre-*-windows-i586.exe'
        $CurrentLine = [regex]'Start-Process -Wait -FilePath \"\.\\jre-8u[0-9.]+-windows-i586\.exe" \-ArgumentList "INSTALLCFG=\$CurrentDirectory\\jre-install-options\.txt" -Wait -WindowStyle Hidden'
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
    
    If (($UpdateFolder -eq 'Java_Update_x64') -and ($UpdateFile -like 'jre-*-windows-x64.exe'))
    {
        $SCCMFolder = "$SCCMDrive"+':\Java\Current\x64\'
        $SCCMAppName = 'Java 8.x 64-bit - (Current)'
        $Installer = "$SCCMFolder"+"install.ps1"
        $CurrentFile = "$SCCMFolder" + 'jre-*-windows-x64.exe'
        $CurrentLine = [regex]'Start-Process -Wait -FilePath \"\.\\jre-8u[0-9.]+-windows-x64\.exe" \-ArgumentList "INSTALLCFG=\$CurrentDirectory\\jre-install-options\.txt" -Wait -WindowStyle Hidden'
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

    # Acrobat update is applied to two installs Pro and Standard
    ######## Information for ACROBAT PRO
    If (($UpdateFolder -eq 'Adobe_Acrobat_XI') -and ($UpdateFile -like 'AcrobatUpd*.msp'))
    {
    ######## Information for ACROBAT PRO
        $SCCMFolder = "$SCCMDrive"+':\Adobe_Acrobat\XI_Pro\'
        $SCCMAppName = 'Adobe Acrobat 11 Pro - (Current)'
        $Installer = "$SCCMFolder"+"install.ps1"
        $CurrentFile = "$SCCMFolder" + 'AcrobatUpd*.msp'
        $CurrentLine = [regex]'\$Arguments \+\= \"\`\"AcrobatUpd[0-9.]+\.msp\`\"\"'
        $NewLine = '$Arguments += "`"'+ $UpdateFile+ '`""'
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
    ######## Information for STANDARD
    If (($UpdateFolder -eq 'Adobe_Acrobat_XI') -and ($UpdateFile -like 'AcrobatUpd*.msp'))
    {
        $SCCMFolder = "$SCCMDrive"+':\Adobe_Acrobat\XI_Std\'
        $SCCMAppName = 'Adobe Acrobat 11 Standard - (Current)'
        $Installer = "$SCCMFolder"+"install.ps1"
        $CurrentFile = "$SCCMFolder" + 'AcrobatUpd*.msp'
        $CurrentLine = [regex]'\$Arguments \+\= \"\`\"AcrobatUpd[0-9.]+\.msp\`\"\"'
        $NewLine = '$Arguments += "`"'+ $UpdateFile+ '`""'
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
    If (($UpdateFolder -eq 'Google_Chrome') -and ($UpdateFile -eq 'GoogleChromeStandaloneEnterprise.msi'))
    {
        $SCCMFolder = "$SCCMDrive"+':\GoogleChromeEnterprise\'
        $SCCMAppName = 'Google Chrome - (Current)'
        $CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
        If ($CurrentVersion -lt $UpdateVersion){StaticUpdates}
    }

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

    If (($UpdateFolder -eq 'Adobe_Reader_XI') -and ($UpdateFile -like 'AdbeRdrUpd*.msp'))
    {
        $SCCMFolder = "$SCCMDrive"+':\Adobe_Reader\Current\'
        $SCCMAppName = 'Adobe Reader 11 - (Current)'
        $Installer = "$SCCMFolder"+"install.ps1"
        $CurrentFile = "$SCCMFolder" + 'AdbeRdrUpd*.msp'
        $CurrentLine = [regex]'\$Arguments \+\= \"\`\"AdbeRdrUpd[0-9.]+\.msp\`\"\"'
        $NewLine = '$Arguments += "`"'+ $UpdateFile+ '`""'
        $CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
        If ($CurrentVersion -lt $UpdateVersion){SemiStaticUpdates}
    }
        	
    If (($UpdateFolder -eq 'Firefox') -and ($UpdateFile -like 'Firefox Setup*.exe'))
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
     
    If (($UpdateFolder -eq 'Java_Update') -and ($UpdateFile -like 'jre-*-windows-i586.exe'))
    {
        $SCCMFolder = "$SCCMDrive"+':\Java\Current\x32\'
        $SCCMAppName = 'Java 8.x 32-bit - (Current)'
        $Installer = "$SCCMFolder"+"install.ps1"
        $CurrentFile = "$SCCMFolder" + 'jre-*-windows-i586.exe'
        $CurrentLine = [regex]'Start-Process "\$CurrentDirectory\\jre-8u[0-9.]+-windows-i586\.exe" \-ArgumentList "INSTALLCFG=\$CurrentDirectory\\jre-install-options\.txt" -Wait -WindowStyle Hidden'
        $NewLine = 'Start-Process "$CurrentDirectory\'+ $UpdateFile+ '" -ArgumentList "INSTALLCFG=$CurrentDirectory\jre-install-options.txt" -Wait -WindowStyle Hidden'
        $CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
        If ($CurrentVersion -lt $UpdateVersion){SemiStaticUpdates}
    }
    
    If (($UpdateFolder -eq 'Java_Update_x64') -and ($UpdateFile -like 'jre-*-windows-x64.exe'))
    {
        $SCCMFolder = "$SCCMDrive"+':\Java\Current\x64\'
        $SCCMAppName = 'Java 8.x 64-bit - (Current)'
        $Installer = "$SCCMFolder"+"install.ps1"
        $CurrentFile = "$SCCMFolder" + 'jre-*-windows-x64.exe'
        $CurrentLine = [regex]'Start-Process "\$CurrentDirectory\\jre-8u[0-9.]+-windows-x64\.exe" \-ArgumentList "INSTALLCFG=\$CurrentDirectory\\jre-install-options\.txt" -Wait -WindowStyle Hidden'
        $NewLine = 'Start-Process "$CurrentDirectory\'+ $UpdateFile+ '" -ArgumentList "INSTALLCFG=$CurrentDirectory\jre-install-options.txt" -Wait -WindowStyle Hidden'
        $CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
        If ($CurrentVersion -lt $UpdateVersion){SemiStaticUpdates}
    }

    If (($UpdateFolder -eq 'Notepad++') -and ($UpdateFile -like 'npp.*.Installer.exe'))
    {
        $SCCMFolder = "$SCCMDrive"+':\Notepad++\'
        $SCCMAppName = 'Notepad++ - (Current)'
        $Installer = "$SCCMFolder"+"install.ps1"
        $CurrentFile = "$SCCMFolder" + 'npp*Installer.exe'
        $CurrentLine = [regex]'Start-Process "\$CurrentDirectory\\npp[0-9.]+\.Installer.exe" -ArgumentList "\/S" -Wait -WindowStyle Hidden'
        $NewLine = 'Start-Process "$CurrentDirectory\'+ $UpdateFile+ '" -ArgumentList "/S" -Wait -WindowStyle Hidden'
        $CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
        If ($CurrentVersion -lt $UpdateVersion){SemiStaticUpdates}
    }

    # Acrobat updat is applied to two installs Pro and Standard
    ######## Information for ACROBAT PRO
    If (($UpdateFolder -eq 'Adobe_Acrobat_XI') -and ($UpdateFile -like 'AcrobatUpd*.msp'))
    {
    ######## Information for ACROBAT PRO
        $SCCMFolder = "$SCCMDrive"+':\Adobe_Acrobat\XI_Pro\'
        $SCCMAppName = 'Adobe Acrobat 11 Pro - (Current)'
        $Installer = "$SCCMFolder"+"install.ps1"
        $CurrentFile = "$SCCMFolder" + 'AcrobatUpd*.msp'
        $CurrentLine = [regex]'\$Arguments \+\= \"\`\"AcrobatUpd[0-9.]+\.msp\`\"\"'
        $NewLine = '$Arguments += "`"'+ $UpdateFile+ '`""'
        $CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
        If ($CurrentVersion -lt $UpdateVersion){SemiStaticUpdates}
    }
    ######## Information for STANDARD
    If (($UpdateFolder -eq 'Adobe_Acrobat_XI') -and ($UpdateFile -like 'AcrobatUpd*.msp'))
    {
        $SCCMFolder = "$SCCMDrive"+':\Adobe_Acrobat\XI_Std\'
        $SCCMAppName = 'Adobe Acrobat 11 Standard - (Current)'
        $Installer = "$SCCMFolder"+"install.ps1"
        $CurrentFile = "$SCCMFolder" + 'AcrobatUpd*.msp'
        $CurrentLine = [regex]'\$Arguments \+\= \"\`\"AcrobatUpd[0-9.]+\.msp\`\"\"'
        $NewLine = '$Arguments += "`"'+ $UpdateFile+ '`""'
        $CurrentVersion = Get-CMApplication -Name $SCCMAppName | select SoftwareVersion
        If ($CurrentVersion -lt $UpdateVersion){SemiStaticUpdates}
    }
}
#>



Write-Host "Removing SCCM Packages folder mapping to: " -NoNewline
Write-Host $SCCMDrive':' -ForegroundColor Magenta
Remove-PSDrive -Name $SCCMDrive -Force -PSProvider FileSystem
