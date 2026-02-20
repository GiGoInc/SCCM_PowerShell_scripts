Function GetInfoPackages()
#>
GetInfoPackages | Format-Table -AutoSize
Function GetInfoPackages()
{
$xPackages = Get-CMPackage | Select-object Name, PkgSourcePath, PackageID
$info = @()
ForEach ($xpack in $xPackages) 
    {
        Write-Host "Checking Package:`t$xpack..."
        $P_ID = $xpack.PackageID
        $P_Name = $xpack.Name
        $P_SP = $xpack.PkgSourcePath
        $object = @()
        $object += ($P_ID,$P_Name,$P_SP+',') -join ','
        # $object | Add-Member -MemberType NoteProperty  -Name Package -Value $xpack.Name
        # $object | Add-Member -MemberType NoteProperty  -Name SourceDir -Value $xpack.PkgSourcePath
        # $object | Add-Member -MemberType NoteProperty  -Name PackageID -Value $xpack.PackageID
        $info += $object
    }
    $info
}


Function GetInfoDriverPackage()
{
$xPackages = Get-CMDriverPackage | Select-object Name, PkgSourcePath, PackageID
$info = @()
ForEach ($xpack in $xPackages) 
    {
        Write-Host "Checking Driver Package:`t" $xpack
        $DP_ID = $xpack.PackageID
        $DP_Name = $xpack.Name
        $DP_SP = $xpack.PkgSourcePath
        $object = @()
        $object += ($DP_ID,$DP_Name,$DP_SP+',') -join ','
        # $object = New-Object -TypeName PSObject
        # $object | Add-Member -MemberType NoteProperty  -Name Package -Value $xpack.Name
        # $object | Add-Member -MemberType NoteProperty  -Name SourceDir -Value $xpack.PkgSourcePath
        # $object | Add-Member -MemberType NoteProperty  -Name PackageID -Value $xpack.PackageID
        $info += $object
    }
    $info
}


Function GetInfoBootimage()
{
$xPackages = Get-CMBootImage | Select-object Name, PkgSourcePath, PackageID
$info = @()
ForEach ($xpack in $xPackages) 
    {
        Write-Host "Checking Boot Images:`t" $xpack
        $BI_ID = $xpack.PackageID
        $BI_Name = $xpack.Name
        $BI_SP = $xpack.PkgSourcePath
        $object = @()
        $object += ($BI_ID,$BI_Name,$BI_SP+',') -join ','
        # $object = New-Object -TypeName PSObject
        # $object | Add-Member -MemberType NoteProperty  -Name Package -Value $xpack.Name
        # $object | Add-Member -MemberType NoteProperty  -Name SourceDir -Value $xpack.PkgSourcePath
        # $object | Add-Member -MemberType NoteProperty  -Name PackageID -Value $xpack.PackageID
        $info += $object
    }
    $info
}


Function GetInfoOSImage()
{
$xPackages = Get-CMOperatingSystemImage | Select-object PackageID, Name, PkgSourcePath
$info = @()
ForEach ($xpack in $xPackages) 
    {
        Write-Host "Checking Operating Sytem Image:`t" $xpack
        $GIOI_ID = $xpack.PackageID
        $GIOI_Name = $xpack.Name
        $GIOI_SP = $xpack.PkgSourcePath
        $object = @()
        $object += ($GIOI_ID,$GIOI_Name,$GIOI_SP+',') -join ','
        #$object | Add-Member -MemberType NoteProperty  -Name PackageID -Value $xpack.PackageID
        #$object | Add-Member -MemberType NoteProperty  -Name Package -Value $xpack.Name
        #$object | Add-Member -MemberType NoteProperty  -Name SourceDir -Value $xpack.PkgSourcePath
        $info += $object
    }
    $info
}


Function GetInfoDriver()
{
$xPackages = Get-CMDriver | Select-object LocalizedDisplayName, ContentSourcePath, PackageID
$info = @()
ForEach ($xpack in $xPackages) 
    {
        Write-Host "Checking Driver:`t$" xpack
        $D_ID = $xpack.PackageID
        $D_Name = $xpack.LocalizedDisplayName
        $D_SP = $xpack.ContentSourcePath
        $object = @()
        $object += ($D_ID,$D_Name,$D_SP+',') -join ','
        # $object = New-Object -TypeName PSObject
        # $object | Add-Member -MemberType NoteProperty  -Name Package -Value $xpack.LocalizedDisplayName
        # $object | Add-Member -MemberType NoteProperty  -Name SourceDir -Value $xpack.ContentSourcePath
        # $object | Add-Member -MemberType NoteProperty  -Name PackageID -Value $xpack.PackageID
        $info += $object
    }
    $info
}


Function GetInfoSWUpdatePackage()
{
$xPackages = Get-CMSoftwareUpdateDeploymentPackage | Select-object Name, PkgSourcePath, PackageID
$info = @()
ForEach ($xpack in $xPackages) 
    {
        Write-Host "Checking Software Update Deployment Package:`t$" xpack
        $UP_ID = $xpack.PackageID
        $UP_Name = $xpack.Name
        $UP_SP = $xpack.PkgSourcePath
        $object = @()
        $object += ($UP_ID,$UP_Name,$UP_SP+',') -join ','
        # $object = New-Object -TypeName PSObject
        # $object | Add-Member -MemberType NoteProperty  -Name Package -Value $xpack.Name
        # $object | Add-Member -MemberType NoteProperty  -Name SourceDir -Value $xpack.PkgSourcePath
        # $object | Add-Member -MemberType NoteProperty  -Name PackageID -Value $xpack.PackageID
        $info += $object
    }
    $info
}


Function GetInfoApplications
{
$info = @()
$object = @()
    ForEach ($Application in Get-CMApplication)
    {

        $AppMgmt = ([xml]$Application.SDMPackageXML).AppMgmtDigest
        $AppName = $AppMgmt.Application.DisplayInfo.FirstChild.Title
        $App_ID = $Application.PackageID
        $App_Expired = $Application.IsExpired
        ForEach ($DeploymentType in $AppMgmt.DeploymentType)
        {
            # Calculate Size and convert to MB
            $size = 0
            ForEach ($MyFile in $DeploymentType.Installer.Contents.Content.File)
            {
                $size += [int]($MyFile.GetAttribute("Size"))
            }
            $size = [math]::truncate($size/1MB)
 
            # Fill properties
            # $AppData = @{            
                $Location = $DeploymentType.Installer.Contents.Content.Location
                $DeploymentTypeName = $DeploymentType.Title.InnerText
                $Technology = $DeploymentType.Installer.Technology
                $ContentId = $DeploymentType.Installer.Contents.Content.ContentId
                $SizeMB = $size
             # }                          

            # Create object
            # $Object = New-Object PSObject -Property $AppData
    
            # Return it
            #$Object
        $object += ($App_ID,$AppName,$App_Expired,$Location,$DeploymentTypeName,$Technology,$ContentId,$SizeMB+',') -join ','
        $info += $object
        }
    }
    $info
 }

#####################################
# SCCM Module
C:
CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location XX1:
CD XX1:

clear-host
#####################################

# Get the Data
$CurrentDirectory = 'D:\Powershell\!SCCM_PS_scripts\!General\SCCM_Item_Information'
$ADateStart = $(get-date -format yyyy-MM-dd)+'_'+ $(get-date -UFormat %R).Replace(':','.')

Write-host "Getting Applications info....." -ForegroundColor Yellow
$DestFile = "$CurrentDirectory\$ADateStart--SCCM_Application_Information.csv"
"Package ID,Name,IsExpired,Source Folder,DeploymentType Name,Technology,Content ID,App Size" -join "," | Set-Content $DestFile
GetInfoApplications | Add-Content $DestFile
Write-host "Done getting Applications info" -ForegroundColor Green


Write-host "Getting Packages info....." -ForegroundColor Yellow
$DestFile = "$CurrentDirectory\$ADateStart--SCCM_Packages_Information.csv"
"Package ID,Name,Source Folder" -join "," | Set-Content $DestFile
GetInfoPackages | Add-Content $DestFile
Write-host "Done getting Packages info" -ForegroundColor Green


Write-host "Getting Boot Images info....." -ForegroundColor Yellow
$DestFile = "$CurrentDirectory\$ADateStart--SCCM_Boot_Images_Information.csv"
"Package ID,Name,Source Folder" -join "," | Set-Content $DestFile
GetInfoBootimage | Add-Content $DestFile
Write-host "Done getting Boot Images info" -ForegroundColor Green


Write-host "Getting OS Images info....." -ForegroundColor Yellow
$DestFile = "$CurrentDirectory\$ADateStart--SCCM_OS_Images_Information.csv"
"Package ID,Name,Source Folder" -join "," | Set-Content $DestFile
GetInfoOSImage | Add-Content $DestFile
Write-host "Done getting OS Images info" -ForegroundColor Green


Write-host "Getting Drivers info....." -ForegroundColor Yellow
$DestFile = "$CurrentDirectory\$ADateStart--SCCM_Drivers_Information.csv"
"Package ID,Localized Display Name,Content Source Path" -join "," | Set-Content $DestFile
GetInfoDriver | Add-Content $DestFile
Write-host "Done getting Drivers info" -ForegroundColor Green


Write-host "Getting Driver Packages info....." -ForegroundColor Yellow
$DestFile = "$CurrentDirectory\$ADateStart--SCCM_Driver_Packages_Information.csv"
"Package ID,Name,Source Folder" -join "," | Set-Content $DestFile
GetInfoDriverPackage | Add-Content $DestFile
Write-host "Done getting Driver Packages info" -ForegroundColor Green

Write-host "Getting Software Update Package Groups info....." -ForegroundColor Yellow
$DestFile = "$CurrentDirectory\$ADateStart--SCCM_Software_Update_Package_Groups_Information.csv"
"Package ID,Name,Source Folder" -join "," | Set-Content $DestFile
GetInfoSWUpdatePackage | Add-Content $DestFile
Write-host "Done getting Software Update Package Groups info" -ForegroundColor Green




<#
# Get the Data
Write-host "Applications" -ForegroundColor Yellow
GetInfoApplications | select-object AppName, Location, Technology | Format-Table -AutoSize 

Write-host "Driver Packages" -ForegroundColor Yellow
GetInfoDriverPackage | Format-Table -AutoSize 

Write-host "Drivers" -ForegroundColor Yellow
GetInfoDriver | Format-Table -AutoSize

Write-host "Boot Images" -ForegroundColor Yellow
GetInfoBootimage | Format-Table -AutoSize

Write-host "OS Images" -ForegroundColor Yellow
GetInfoOSImage | Format-Table -AutoSize

Write-host "Software Update Package Groups" -ForegroundColor Yellow
GetInfoSWUpdatePackage | Format-Table -AutoSize

Write-host "Packages" -ForegroundColor Yellow
GetInfoPackages | Format-Table -AutoSize
#>
