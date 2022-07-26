cls

$Today = $(get-date -format yyyy/MM/dd)
$DriverPackagePath = 'D:\Drivers'
$DriversSourcePath = 'D:\DriversSource'

$A = gci $DriversSourcePath -Filter *.cab
If ($A.Count -ne 0)
{
    Write-Host "`nThis script assumes you have already removed/purged/deleted the previous " -NoNewline -ForegroundColor Cyan
    Write-Host $A.Count -NoNewline -ForegroundColor Yellow
    Write-Host " DRIVERS and DRIVER PACKAGES for the following models....`n" -ForegroundColor Cyan
}
Else
{
    Write-Host "`nCannot find CAB files to update Drivers and Packages!!! Exiting..." -ForegroundColor Red
    Read-Host -Prompt "Press any key to continue or CTRL+C to quit"
    exit
}


ForEach ($Item in $A)
{
    $Model = $Item.name.Split('-')[0].split('_')[0]
    Write-Host "`t$Model" -ForegroundColor Green
}


Write-Host "`nARE YOU READY TO BUILD NEW DRIVERS AND DRIVER PACKAGES???`n"-ForegroundColor Yellow
Read-Host -Prompt "Press any key to continue or CTRL+C to quit"
Write-Host "`nSERIOUSLY, ARE YOU READY TO BREAK SOME STUFF...?`n"-ForegroundColor Red
Read-Host -Prompt "Press any key to continue or CTRL+C to quit"


Write-Host "Found" $A.Count "CAB Files" -ForegroundColor Magenta
ForEach ($Item in $A)
{
    $CAB                        = $null
    $Model                      = $null
    $Version                    = $null
    $FullPath                   = $null
    $DriverPackages_FullPath    = $null
    $DriversSource_ExpandedPath = $null
    $DriversSource_FullPath     = $null
    $DriversSource_PartPath     = $null
    $FolderName                 = $null

         $CAB = $Item.name
       $Model = $Item.name.Split('-')[0] #.split('_')[0]
     $Version = $Item.name.Split('-')[2]
    $FullPath = $Item.FullName

    If ($Model -eq '7010'){$FolderName =  "Win10_Dell_Optiplex_7010_$Version"} 
    If ($Model -eq '7040'){$FolderName =  "Win10_Dell_Optiplex_7040_$Version"} 
    If ($Model -eq '7050'){$FolderName =  "Win10_Dell_Optiplex_7050_$Version"} 
    If ($Model -eq '7480'){$FolderName =  "Win10_Dell_Latitude_7480_$Version"} 
    If ($Model -eq '9020'){$FolderName =  "Win10_Dell_Optiplex_9020_$Version"}
    If ($Model -eq 'E5540'){$FolderName = "Win10_Dell_Latitude_E5540_$Version"}
    If ($Model -eq 'E5550'){$FolderName = "Win10_Dell_Latitude_E5550_$Version"} 
    If ($Model -eq 'E5570'){$FolderName = "Win10_Dell_Latitude_E5570_$Version"} 
    If ($Model -eq '5580'){$FolderName =  "Win10_Dell_Latitude_E5580_$Version"} 
    If ($Model -eq 'E7440'){$FolderName = "Win10_Dell_Latitude_E7440_$Version"} 
    If ($Model -eq 'E7470'){$FolderName = "Win10_Dell_Latitude_E7470_$Version"}

        $DriversSource_FullPath = "$DriversSourcePath\$FolderName"
        $DriversSource_PartPath = "$DriversSourcePath\$FolderName" -replace ".{4}$"
    $DriversSource_ExpandedPath = "$DriversSource_FullPath\$Model\win10\x64"

    $DriverPackages_FullPath = "$DriverPackagePath\$FolderName"
    $DriverPackages_PartPath = "$DriverPackagePath\$FolderName" -replace ".{4}$"

    Write-Host "Model:`t`t" $Model -ForegroundColor Cyan
    Write-Host "Driver Ver:`t" $Version -ForegroundColor Cyan
    Write-Host "DriverPackageName:`t" $FolderName -ForegroundColor Cyan
    Write-Host "CAB File:`t" $CAB -ForegroundColor Cyan    
    Write-Host ''
    Write-Host "Drivers_PartPath:`t`t" $DriversSource_PartPath -ForegroundColor Yellow
    Write-Host "Drivers_FullPath:`t`t" $DriversSource_FullPath -ForegroundColor Yellow
    Write-Host "Drivers_ExpandedPath:`t" $DriversSource_ExpandedPath -ForegroundColor Yellow
    Write-Host ''
    Write-Host "DriverPackages_PartPath:`t" $DriverPackages_PartPath -ForegroundColor Magenta
    Write-Host "DriverPackages_FullPath:`t" $DriverPackages_FullPath -ForegroundColor Magenta
    Write-Host "`n"


##################
# REMOVE FOLDERS
    Write-Host "`tRemoving current Driver source folder: $DriversSourcePath -- Win10_$Model" -ForegroundColor Cyan
    If(Test-Path "$DriversSource_PartPath*"){Remove-Item -Path "$DriversSource_PartPath*" -Force -Recurse}

    Write-Host "`tRemoving current DriverPackage folder: $DriverPackagePath -- Win10_$Model" -ForegroundColor White
    If(Test-Path "$DriverPackages_PartPath*"){Remove-Item -Path "$DriverPackages_PartPath*" -Force -Recurse}
    #Start-Sleep -Seconds 10

##################
# ADD FOLDERS
    Write-Host "`tRecreating current Driver source folder: $DriversSourcePath\Win10_$Model" -ForegroundColor Red
    If(!(Test-Path "$DriversSource_PartPath*")){New-Item -ItemType Directory -Path $DriversSource_FullPath | Out-Null}

    Write-Host "`tRecreating current DriverPackage folder: $DriverPackagePath\Win10_$Model" -ForegroundColor Red
    If(!(Test-Path "$DriverPackages_PartPath*")){New-Item -ItemType Directory -Path $DriverPackages_FullPath | Out-Null}

##################
# EXPAND CABS TO SOURCE FOLDERS
    Write-Host "`tExpanding CAB: $CAB to $DriversSource_FullPath" -ForegroundColor Green
    expand -r $FullPath "$DriversSource_FullPath" -f:*

    If(Test-Path "$DriversSource_ExpandedPath")
    {
          Move-Item -Path "$DriversSource_ExpandedPath\*" -Destination $DriversSource_FullPath -Force
        Remove-Item -Path "$DriversSource_FullPath\$Model" -Force -Recurse
    }
    Else
    {
        Write-Host "FAILED TO FIND EXPANDED DRIVER FOLDERS!!!: $DriversSource_ExpandedPath" -ForegroundColor Red
        Read-Host -Prompt "Press any key to continue or CTRL+C to quit"
    }

<#
##################
# CREATE NEW DRIVER PACKAGE IN SCCM - RUN BEFORE ADDING NEW DRIVERS
    Write-Host "`tCreating new DriverPackage: $DriverPackagePath\$FolderName" -ForegroundColor Green
    # New-CMDriverPackage -Name "Win10 - $Model - $Version" -Path "\\SCCMSERVER\Drivers\$FolderName" -Description "created $Today by PowerShell"

    Write-Host "`tModifying DriverPackage: $DriverPackagePath\$FolderName" -ForegroundColor Green
    Set-CMDriverPackage -Name "Win10 - $Model - $Version"



##################
# ADD NEW DRIVERS AND DRIVERPACKAGES TO SCCM
$Drivers = Get-ChildItem -Path "$DriverPackagePath\$FolderName" -Recurse -Filter "*.inf"
cd SS1:
    # Foreach($Item in $Drivers)
    # {
    # 	Import-CMDriver -UncFileLocation $Item.FullName -ImportDuplicateDriverOption AppendCategory -EnableAndAllowInstall $True
    # }

New-CMDriverPackage -Name "Win10 - $Model - $Version" -Path "\\SCCMSERVER\Drivers\$FolderName" -Description "created $Today by PowerShell" | Out-Null
Foreach($Item in $Drivers)
{
    $FileName = $item.FullName
    $FileName = $FileName.replace('E:\','\\SCCMSERVER\')
    [string]$DriverCategory = "Win10 - $Model - $Version"
    Write-Host $FileName
	$DriverPackage = Get-CMDriverPackage -Name "Win10 - $Model - $Version"
	$DriverInfo = Import-CMDriver -UncFileLocation "$FileName"  -ImportDuplicateDriverOption AppendCategory -EnableAndAllowInstall $True | Select-Object *
-AdministrativeCategory "Win10 - E7470 - A07"
	Add-CMDriverToDriverPackage -DriverId $DriverInfo.CI_ID -DriverPackageName "Win10 - $Model - $Version"
    #Read-Host -Prompt "Press any key to continue or CTRL+C to quit"
}





    Write-Host "`tAdding new Drivers to SCCM for: $Model - $Version" -ForegroundColor Magenta
    Import-CMDriver -UncFileLocation $DriversSource_FullPath -AdministrativeCategory ??? -DriverPackage (Win10 - $Model - $Version) -EnableAndAllowInstall True -ImportDuplicateDriverOption ???? -SupportedPlatform ???? -SupportedPlatformName ??? -UpdateDriverPackageDistributionPoint ???

$DriverCategory = Get-CMCategory -Name "TEST"
 $DriverPackage = Get-CMDriverPackage -Name "Win10 - $Model - $Version"

Set-Location C:\
$Drivers = Get-childitem -path "\\YourServer\e$\Drivers\test" -Recurse -Filter "*.inf"
Set-Location ABC:
foreach($item in $Drivers)
{
	Import-CMDriver -UncFileLocation $item.FullName `
                    -ImportDuplicateDriverOption AppendCategory `
                    -EnableAndAllowInstall $True `
                    -DriverPackage $DriverPackage `
                    -AdministrativeCategory $DriverCategory `
                    -UpdateDistributionPointsforDriverPackage $False
}


##################
# CREATE NEW DRIVER PACKAGE IN SCCM
    Write-Host "`tCreating new DriverPackage: $DriverPackagePath\$FolderName" -ForegroundColor Green
    New-CMDriverPackage -Name "Win10 - $Model - $Version" -Path "\\SCCMSERVER\Drivers\$FolderName" -Description "created $Today by PowerShell"

    Write-Host "`tModifying DriverPackage: $DriverPackagePath\$FolderName" -ForegroundColor Green
    Set-CMDriverPackage -Name "Win10 - $Model - $Version"
#>


##################
    Write-Host ''
    # Read-Host -Prompt "Press any key to continue or CTRL+C to quit"

}




<#

$driverPackage = Get-CMDriverPackage -Id "ST100062"
$bootPackage = Get-CMBootImage -Id "CM100004"
Import-CMDriver -UncFileLocation "\\btc-dist-08\Public\CM\AdminTeam\Driver\X64Driver\AudioDriver\smwdmCH6.inf" -ImportDuplicateDriverOption OverwriteCategory -EnableAndAllowInstall $True -DriverPackage $driverPackage -BootImagePackage $bootPackage

Import-CMDriver -UncFileLocation \\SCCMSERVER\DriversSource\E7440-WIN7-A09-MJP2J\x86\chipset\3664N_A00-00\WIN7 -AdministrativeCategory (Win10 - Dell Latitude 7480) -DriverPackage (Win10 - E7480) -EnableAndAllowInstall True


$Folders = '7040-WIN7-A02-CRW28', `
           'Dell-WinPE-Drivers_x32', `
           'Dell-WinPE4.0-Drivers', `
           'Dell-WinPE5.0-Drivers_x32-A04', `
           'Dell_7010_Win7_x64_A99', `
           'Dell_7010_Win7_x86_A99', `
           'Dell_7040_Win7x64_A99', `
           'Dell_7040_Win7x86_A99', `
           'Dell_7050_Win7_x64_A99', `
           'Dell_7050_Win7_x86_A99', `
           'Dell_9020_Win7_x64_A99', `
           'Dell_9020_Win7_x86_A99', `
           'Dell_990_Win7_x64_A99', `
           'Dell_E5540_Win7_x64_A99', `
           'Dell_E5540_Win7_x64_A99', `
           'Dell_E5540_Win7_x64_preA09_NIC_Driver', `
           'Dell_E5540_Win7_x86_A99', `
           'Dell_E5540_Win7_x86_A99', `
           'Dell_E5540_Win7_x86_preA09_NIC_Driver', `
           'Dell_E5550_Win7x32_A99', `
           'Dell_E5550_Win7x64_A99', `
           'Dell_E5580_Win7_x32_A99', `
           'Dell_E5580_Win7_x64_A99', `
           'Dell_E6540_Win7_x64_A99', `
           'Dell_E7440_Win7_x64_A99', `
           'Dell_E7440_Win7_x86_A99', `
           'Dell_E7450_Win7_x64_A99', `
           'Dell_E7450_Win7x64_A99', `
           'Dell_E7450_Win7x86_A99', `
           'Dell_E7470_Win7_x64_A99', `
           'Dell_E7470_Win7_x64_A99', `
           'Dell_E7470_Win7_x64_WiGigUpdate', `
           'Dell_E7470_Win7_x86_A99', `
           'Dell_E7480_Win7_x64_A99', `
           'Dell_E7480_Win7_x86_A99', `
           'E5550-WIN7-A05-7PC6F', `
           'E5570-WIN7-A04-VMD64', `
           'E7440-WIN7-A09-MJP2J', `
           'Lenovo_M78_Win7x32', `
           'Lenovo_M78_Win7x64', `
           'Lenovo_T530_Win7x64', `
           'Old_Drivers', `
           'Videofor7470', `
           'WIN10-NewLine', `
           'Win10-D15-Dock', `
           'Win10_Dell_Latitude_7480_A99', `
           'Win10_Dell_Latitude_E5540_A99', `
           'Win10_Dell_Latitude_E5550_5550_A99', `
           'Win10_Dell_Latitude_E5570_A99', `
           'Win10_Dell_Latitude_E5580_A99', `
           'Win10_Dell_Latitude_E7440_A99', `
           'Win10_Dell_Latitude_E7470_A99', `
           'Win10_Dell_Optiplex_7010_A99', `
           'Win10_Dell_Optiplex_7040_A99', `
           'Win10_Dell_Optiplex_7050_A99', `
           'Win10_Dell_Optiplex_9020_A99', `
           'Win7-D15-Dock'
		   
ForEach ($Folder in $Folders)		  
{
	If (!(Test-Path "D:\Drivers\$Folder")){mkdir "D:\Drivers\$Folder"}
	If (!(Test-Path "D:\DriversSource\$Folder")){mkdir "D:\DriversSource\$Folder"}
}


$CABS = '5580-WIN10-A04-69H6T.CAB', `
        '7040-WIN10-A09-693DT.CAB', `
        '7050-WIN10-A04-PVPC4.CAB', `
        '7480-WIN10-A04-DTY03.CAB', `
        '9020-WIN10-A04-2RVY7.CAB', `
        'E5540-WIN10-A02-KFY4R.CAB', `
        'E5550_5550-WIN10-A06-HYH54.CAB', `
        'E5570-WIN10-A13-04FXV.CAB', `
        'E7440-WIN10-A03-PW82J.CAB', `
        'E7470-WIN10-A07-WXGDV.CAB'
	
ForEach ($CAB in $CABS)		  
{
	If (!(Test-Path "D:\DriversSource\$CAB")){mkdir "D:\DriversSource\$CAB"}
}
	
#>
