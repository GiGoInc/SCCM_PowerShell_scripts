$CurrentDirectory = 'D:\Powershell\!SCCM_PS_scripts\!DPs'
    D:
# Go back to local drive
$CurrentDirectory = 'D:\Powershell\!SCCM_PS_scripts\!DPs'
$ADateStart = $(get-date -format yyyy-MM-dd) + '_' + $(get-date -UFormat %R).Replace(':', '.')

$Log = "$CurrentDirectory\$ADateStart--DP_ContentStatus_Issues.csv"
$DestFile = "$CurrentDirectory\$ADateStart--SCCM_Item_Information.csv"
"Package ID,Name" -join "," | Set-Content $DestFile


#SCCM Module
C:
CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location XX1:
CD XX1:

clear-host

Function GetInfoApplications
{
    $info = @()
    $object = @()
    foreach ($Application in Get-CMApplication)
    {
        $AppMgmt = ([xml]$Application.SDMPackageXML).AppMgmtDigest
        $AppName = $AppMgmt.Application.DisplayInfo.FirstChild.Title
        $App_ID = $Application.PackageID
        $object += ($App_ID, $AppName + ',') -join ','
        $info += $object
    }
    $info
}

Function GetInfoPackages()
{
    $xPackages = Get-CMPackage | Select-object Name, PkgSourcePath, PackageID
    $info = @()
    foreach ($xpack in $xPackages)
    {
        $P_ID = $xpack.PackageID
        $P_Name = $xpack.Name
        $object = @()
        $object += ($P_ID, $P_Name + ',') -join ','
        $info += $object
    }
    $info
}

Function GetInfoBootimage()
{
    $xPackages = Get-CMBootImage | Select-object Name, PkgSourcePath, PackageID
    $info = @()
    foreach ($xpack in $xPackages)
    {
        $BI_ID = $xpack.PackageID
        $BI_Name = $xpack.Name
        $object = @()
        $object += ($BI_ID, $BI_Name + ',') -join ','
        $info += $object
    }
    $info
}

Function GetInfoOSImage()
{
    $xPackages = Get-CMOperatingSystemImage | Select-object PackageID, Name, PkgSourcePath
    $info = @()
    foreach ($xpack in $xPackages)
    {
        $GIOI_ID = $xpack.PackageID
        $GIOI_Name = $xpack.Name
        $object = @()
        $object += ($GIOI_ID, $GIOI_Name + ',') -join ','
        $info += $object
    }
    $info
}

Function GetInfoDriver()
{
    $xPackages = Get-CMDriver | Select-object LocalizedDisplayName, ContentSourcePath, PackageID
    $info = @()
    foreach ($xpack in $xPackages)
    {
        $D_ID = $xpack.PackageID
        $D_Name = $xpack.LocalizedDisplayName
        $object = @()
        $object += ($D_ID, $D_Name + ',') -join ','
        $info += $object
    }
    $info
}

Function GetInfoDriverPackage()
{
    $xPackages = Get-CMDriverPackage | Select-object Name, PkgSourcePath, PackageID
    $info = @()
    foreach ($xpack in $xPackages)
    {
        $DP_ID = $xpack.PackageID
        $DP_Name = $xpack.Name
        $object = @()
        $object += ($DP_ID, $DP_Name + ',') -join ','
        $info += $object
    }
    $info
}

Function GetInfoSWUpdatePackage()
{
    $xPackages = Get-CMSoftwareUpdateDeploymentPackage | Select-object Name, PkgSourcePath, PackageID
    $info = @()
    foreach ($xpack in $xPackages)
    {
        $UP_ID = $xpack.PackageID
        $UP_Name = $xpack.Name
        $object = @()
        $object += ($UP_ID, $UP_Name + ',') -join ','
        $info += $object
    }
    $info
}

Function Get-DPContent
{
    'PackageID,DistributionPoint' | Set-Content $Log
    $Query = 'SELECT * FROM SMS_PackageStatusDistPointsSummarizer WHERE State = 2 OR State = 3'
    $ContentIssues = Get-WmiObject -ComputerName 'SERVER' -Namespace "ROOT\SMS\site_XX1" -Query $query |
        Select-Object packageID, @{n = 'DistributionPoint'; e = {$_.ServerNALPath.Split('\')[2]}}, @{n = 'PackageType'; e = {$_.PackageType}}
    # | Format-Table -AutoSize

    ForEach ($line in $ContentIssues)
    {
        $PI = $line.packageID
        $DP = $line.DistributionPoint
        $PT = $line.PackageType
        $PI, $DP, $PT -join ',' | Add-Content $Log
    }

}

Function RunTime
{
    $End = (GET-DATE)
    $TS = NEW-TIMESPAN –Start $Start –End $End
    $Min = $TS.minutes
    $Sec = $TS.Seconds
    Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Magenta
}




# Get the SCCM ITEM INFORMATION DATA
    $StartScript = (GET-DATE)
    Write-host "Getting Applications info...Starting..." -ForegroundColor Magenta
    Write-host "Estimated Time to Complete entire script: 6 minutes...`n" -ForegroundColor Magenta 

    $Start = (GET-DATE)
    Write-host "Getting Applications info...Starting..." -ForegroundColor Yellow
    Write-host "Estimated Time to Complete: 4 minutes..." -ForegroundColor Cyan 
    GetInfoApplications | Add-Content $DestFile
    RunTime

    $Start = (GET-DATE)
    Write-host "Getting Packages info...Starting..." -ForegroundColor Yellow
    Write-host "Estimated Time to Complete: 1 minute..." -ForegroundColor Cyan     
    GetInfoPackages | Add-Content $DestFile
    RunTime

    $Start = (GET-DATE)
    Write-host "Getting Boot Images info...Starting..." -ForegroundColor Yellow
    Write-host "Estimated Time to Complete: 10 seconds..." -ForegroundColor Cyan       
    GetInfoBootimage | Add-Content $DestFile
    RunTime

    $Start = (GET-DATE)
    Write-host "Getting OS Images info...Starting..." -ForegroundColor Yellow
    Write-host "Estimated Time to Complete: 10 seconds..." -ForegroundColor Cyan       
    GetInfoOSImage | Add-Content $DestFile
    RunTime

    # $Start = (GET-DATE)
    # Write-host "Getting Drivers info...Starting..." -ForegroundColor Yellow
    # Write-host "Estimated Time to Complete: 10 seconds..." -ForegroundColor Cyan       
    # GetInfoDriver | Add-Content $DestFile
    # RunTime

    $Start = (GET-DATE)
    Write-host "Getting Driver Packages info...Starting..." -ForegroundColor Yellow
    Write-host "Estimated Time to Complete: 40 seconds..." -ForegroundColor Cyan       
    GetInfoDriverPackage | Add-Content $DestFile
    RunTime

    $Start = (GET-DATE)
    Write-host "Getting Software Update Package Groups info...Starting..." -ForegroundColor Yellow
    Write-host "Estimated Time to Complete: 10 seconds..." -ForegroundColor Cyan        
    GetInfoSWUpdatePackage | Add-Content $DestFile
    RunTime

# Get DP Content that has failed and/or is retrying to distribute
    $Start = (GET-DATE)
    Write-host "Getting Content Status from DP that have failed or are Retrying...Starting..." -ForegroundColor Yellow
    Write-host "Estimated Time to Complete: 10 seconds..." -ForegroundColor Cyan       
    Get-DPContent
    RunTime

# Total time to run script
    $EndScript = (GET-DATE)
    $TS = NEW-TIMESPAN –Start $StartScript –End $EndScript
    $MinS = $TS.minutes
    $SecS = $TS.Seconds
    Write-Host "`n$(Get-Date)`tScript ran for $minS minutes and $secS seconds`n`n" -ForegroundColor Magenta

# Go back to local drive
    D:
