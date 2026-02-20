cls
Write-Host "$(Get-Date)`tScript ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
$Sec = $TS.Seconds
cls
$ScriptStart = (GET-DATE)
# Static Variables
C:
 ##############################
 # Add Required Type Libraries
     [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ManagementProvider.dll")) | Out-Null
     [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.dll")) | Out-Null
     [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.Extender.dll")) | Out-Null
     [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.MsiInstaller.dll")) | Out-Null
##############################
# CD 'C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin'
##############################
CD 'C:\Program Files (x86)\ConfigMgr Console\bin'
##############################
Import-Module ".\ConfigurationManager.psd1"
Start-Sleep -Milliseconds 500
Set-Location XX1:
CD XX1:
##############################

# Variables
#Get current working paths
#$CurrentDirectory = split-path $MyInvocation.MyCommand.Path
#$ScriptName = $MyInvocation.MyCommand.Name
$ADateE = Get-Date
$Date = $(get-date -format yyyy-MM-dd)+'__'+ $(get-date -UFormat %R).Replace(':','.')
$Folder = 'D:\Powershell\!SCCM_PS_scripts\!Appplications_and_Packages\Get_Applications_and_Package_Info'
$DestFile = "$Folder\SCCM_Packaged_Application_Information_$Date.csv"
If (Test-Path -Path $DestFile){Remove-Item -Path $DestFile -Force}
"Item Type,Application Name,DP Count,Deployment Type Title,Manufacturer,Version,Package ID,Created By,Date Created,Date Modified,Last Modified By,Source Path,SourcePath for Matching,Path Match,Expired/Retired,Content Size" -join "," | Set-Content $DestFile
#############################################################################################################################
#############################################################################################################################
    $CMAStart = Get-Date
    # Loading SCCM Applications List
    Write-host "Checking Applications..." -ForegroundColor Green
    Write-host "This should take about ten minutes..." -ForegroundColor Yellow
    $CMA = Get-CMApplication -Name * #| Select-Object LocalizedDisplayName,PackageID,CreatedBy,DateCreated,DateLastModified,LastModifiedBy

    $CMAEnd = (GET-DATE)
    $TS = NEW-TIMESPAN –Start $CMAStart –End $CMAEnd
    $Min = $TS.minutes
    $Sec = $TS.Seconds
    Write-Host "$(Get-Date)`tChecking Applications ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
#############################################
#############################################
    $BStart = Get-Date
    Write-host "Checking Applications properties..." -ForegroundColor Green
    $output = @()
    ForEach ($B in $CMA)
    {
        $AppMgmt = ([xml]$B.SDMPackageXML).AppMgmtDigest
        $AppName = $B.LocalizedDisplayName
        $TDPCount = $($B | Where-Object {$_.IsExpired -eq $false} | Get-CMDistributionStatus | Select-Object Targeted).targeted
        foreach ($DeploymentType in $AppMgmt.DeploymentType)
        {              
            $AppName  = $AppName
            $Location = $DeploymentType.Installer.Contents.Content.Location
            [string]$ContentSize = $($DeploymentType.Installer.Contents.Content.File.size | Measure-Object -Sum).sum

               $DTTitle = $DeploymentType.title.'#text'
               $Manufan = $B.Manufacturer
               $Version = $B.SoftwareVersion
                 $PkgID = $B.PackageID
               $Creator = $B.CreatedBy
               $DCreate = $B.DateCreated
               $DModify = $B.DateLastModified
            $LastModder = $B.LastModifiedBy
             $IsEnabled = $B.IsEnabled
             $IsExpired = $B.IsExpired

            # $ErrorActionPreference = 'SilentlyContinue'
            $MatchLocation = $null
                If ($Location.ToLower() -match 'e:\\packages')                                                   { $matchlocation = $location.tolower().replace('e:\packages','Packages').TrimEnd('\') } 
                               
            ElseIf ($Location.ToLower() -match '\\\\cmcontent\\driverssource')                                   { $matchlocation = $location.tolower().replace('\\cmcontent\driverssource','DriversSource').TrimEnd('\') }
            ElseIf ($Location.ToLower() -match '\\cmcontent\\packages')                                          { $matchlocation = $location.tolower().replace('\\cmcontent\packages','Packages').TrimEnd('\') }

            ElseIf ($Location.ToLower() -match '\\\\cmsource\\driverssource')                                    { $matchlocation = $location.tolower().replace('\\cmsource\driverssource','DriversSource').TrimEnd('\') }
            ElseIf ($Location.ToLower() -match '\\cmsource\\osd\$')                                              { $matchlocation = $location.tolower().replace('\\cmsource\osd$','OSD$').TrimEnd('\') }
            ElseIf ($Location.ToLower() -match '\\\\cmsource\\packages')                                         { $matchlocation = $location.tolower().replace('\\cmsource\packages','Packages').TrimEnd('\') }

            ElseIf ($Location.ToLower() -match '\\\\DOMAIN.COM\\GROUP1\\SERVER1\\mcm\\driverssource') { $matchlocation = $location.tolower().replace('\\DOMAIN.COM\GROUP1\SERVER1\mcm\driverssource','DriversSource').TrimEnd('\') }
            ElseIf ($Location.ToLower() -match '\\\\DOMAIN.COM\\GROUP1\\SERVER1\\mcm\\packages')      { $matchlocation = $location.tolower().replace('\\DOMAIN.COM\GROUP1\SERVER1\mcm\packages','Packages').TrimEnd('\') }
            
            ElseIf ($Location.ToLower() -match '\\\\SERVER.DOMAIN.COM\\sms_XX1')                          { $matchlocation = $location.tolower().replace('\\SERVER.DOMAIN.COM\sms_XX1','SMS_XX1').TrimEnd('\') }
            ElseIf ($Location.ToLower() -match '\\\\SERVER\\driverssource')                                   { $matchlocation = $location.tolower().replace('\\SERVER\driverssource','DriversSource').TrimEnd('\') }
            
            ElseIf ($Location.ToLower() -match '\\\\SERVER\\e\$\\packages')                                   { $matchlocation = $location.tolower().replace('\\SERVER\e$\packages','Packages').TrimEnd('\') }
            ElseIf ($Location.ToLower() -match '\\\\SERVER\\packages')                                        { $matchlocation = $location.tolower().replace('\\SERVER\packages','Packages').TrimEnd('\') }
            ElseIf ($MatchLocation -eq $null) { $MatchLocation = 'Not Found' }                           


           $output += 'Application,"' + $AppName + '","' + $TDPCount + '","' + $DTTitle + '","' + $Manufan + '","' + $Version + '","' + $PkgID + '","' + $Creator + '","' + $DCreate + '","' + $DModify + '","' + $LastModder + '","' + $Location + '","' + $MatchLocation + '","=INDEX(SCCM_Folder_Paths!$B$2:$B$30000,MATCH(M2,SCCM_Folder_Paths!$C$2:$C$30000,FALSE),1)","' + $IsExpired + '","' + $ContentSize + '"'
        }
    }

    $output | Add-Content $DestFile

$BEnd = (GET-DATE)
$TS = NEW-TIMESPAN –Start $BStart –End $BEnd
$Min = $TS.minutes
$Sec = $TS.Seconds
Write-Host "$(Get-Date)`tChecking Applications properties ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
##########################################################################################################################################################################################################################################################
##########################################################################################################################################################################################################################################################
$CStart = Get-Date
    Write-host "Checking Packages..." -ForegroundColor Green
    $C = Get-CMPackage -Name * -Fast # | Select-Object Name,PackageID,SourceDate,PkgSourcePath
$CEnd = (GET-DATE)
$TS = NEW-TIMESPAN –Start $CStart –End $CEnd
$Min = $TS.minutes
$Sec = $TS.Seconds
Write-Host "$(Get-Date)`tChecking Packages ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
#############################################
#############################################
$DStart = Get-Date
$obj = @()
ForEach ($D in $C)
{
    $PkgName = $D.Name
    $Manufan = $D.Manufacturer
     $PKGVer = $D.Version
      $PkgID = $D.PackageID
     $PkgDLM = $D.SourceDate
      $PkgSP = $D.PkgSourcePath
    $PkgSize = $D.PackageSize
   $PDPCount = $(Get-CMDistributionStatus -Id $D.PackageID).targeted
    
    $MatchLocation = $null
        If ($PkgSP.ToLower() -match 'e:\\packages')                                                   { $matchlocation = $PkgSP.tolower().replace('e:\packages','Packages').TrimEnd('\') } 
                       
    ElseIf ($PkgSP.ToLower() -match '\\\\cmcontent\\driverssource')                                   { $matchlocation = $PkgSP.tolower().replace('\\cmcontent\driverssource','DriversSource').TrimEnd('\') }
    ElseIf ($PkgSP.ToLower() -match '\\cmcontent\\packages')                                          { $matchlocation = $PkgSP.tolower().replace('\\cmcontent\packages','Packages').TrimEnd('\') }
    
    ElseIf ($PkgSP.ToLower() -match '\\\\cmsource\\driverssource')                                    { $matchlocation = $PkgSP.tolower().replace('\\cmsource\driverssource','DriversSource').TrimEnd('\') }
    ElseIf ($PkgSP.ToLower() -match '\\cmsource\\osd\$')                                              { $matchlocation = $PkgSP.tolower().replace('\\cmsource\osd$','OSD$').TrimEnd('\') }
    ElseIf ($PkgSP.ToLower() -match '\\\\cmsource\\packages')                                         { $matchlocation = $PkgSP.tolower().replace('\\cmsource\packages','Packages').TrimEnd('\') }
    
    ElseIf ($PkgSP.ToLower() -match '\\\\DOMAIN.COM\\GROUP1\\SERVER1\\mcm\\driverssource') { $matchlocation = $PkgSP.tolower().replace('\\DOMAIN.COM\GROUP1\SERVER1\mcm\driverssource','DriversSource').TrimEnd('\') }
    ElseIf ($PkgSP.ToLower() -match '\\\\DOMAIN.COM\\GROUP1\\SERVER1\\mcm\\packages')      { $matchlocation = $PkgSP.tolower().replace('\\DOMAIN.COM\GROUP1\SERVER1\mcm\packages','Packages').TrimEnd('\') }
    
    ElseIf ($PkgSP.ToLower() -match '\\\\SERVER.DOMAIN.COM\\sms_XX1')                          { $matchlocation = $PkgSP.tolower().replace('\\SERVER.DOMAIN.COM\sms_XX1','SMS_XX1').TrimEnd('\') }
    ElseIf ($PkgSP.ToLower() -match '\\\\SERVER\\driverssource')                                   { $matchlocation = $PkgSP.tolower().replace('\\SERVER\driverssource','DriversSource').TrimEnd('\') }
    
    ElseIf ($PkgSP.ToLower() -match '\\\\SERVER\\e\$\\packages')                                   { $matchlocation = $PkgSP.tolower().replace('\\SERVER\e$\packages','Packages').TrimEnd('\') }
    ElseIf ($PkgSP.ToLower() -match '\\\\SERVER\\packages')                                        { $matchlocation = $PkgSP.tolower().replace('\\SERVER\packages','Packages').TrimEnd('\') }
    ElseIf ($MatchLocation -eq $null) { $MatchLocation = 'Not Found' }   

       $obj += 'Package,"' + $PkgName + '","' + $TDPCount + '",,"' + $Manufan + '","' + $PKGVer + '","' + $PkgID + '",,"' + $PkgDLM + '",,,"' + $PkgSP + '","' + $matchLocation + '","=INDEX(SCCM_Folder_Paths!$B$2:$B$30000,MATCH(M2,SCCM_Folder_Paths!$C$2:$C$30000,FALSE),1)","' + $PkgSize + '"'
}
$obj | Add-Content $DestFile
$DEnd = (GET-DATE)
$TS = NEW-TIMESPAN –Start $DStart –End $DEnd
$Min = $TS.minutes
$Sec = $TS.Seconds
Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
#############################################################################################################################
#############################################################################################################################
$EStart = Get-Date
    Write-host "Checking SCCM1 Packages folder directory..." -ForegroundColor Green
    New-PSDrive -Name "SCCM1P" -PSProvider "FileSystem" -Root "\\SERVER\E$\Packages"
    $SCCM1Packages = $(Get-ChildItem -Path 'SCCM1P:' -Depth 6 -Directory).FullName
    Remove-PSDrive -Name SCCM1P -Force
$EEnd = (GET-DATE)
$TS = NEW-TIMESPAN –Start $EStart –End $EEnd
$Min = $TS.minutes
$Sec = $TS.Seconds
Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan

$EStart = Get-Date
    Write-host "Checking SCCM1 DriverSource folder directory..." -ForegroundColor Green
    New-PSDrive -Name "SCCM1D" -PSProvider "FileSystem" -Root "\\SERVER\E$\DriversSource"
    $SCCM1Drivers = $(Get-ChildItem -Path 'SCCM1D:' -Depth 6 -Directory).FullName
    Remove-PSDrive -Name SCCM1D -Force
$EEnd = (GET-DATE)
$TS = NEW-TIMESPAN –Start $EStart –End $EEnd
$Min = $TS.minutes
$Sec = $TS.Seconds
Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan

$EStart = Get-Date
    Write-host "Checking MCM folder directory..." -ForegroundColor Green
    New-PSDrive -Name "MCM" -PSProvider "FileSystem" -Root "\\DOMAIN.COM\GROUP1\SERVER1\MCM"
    $MCMFolders = $(Get-ChildItem -Path 'MCM:' -Depth 6 -Directory).FullName
    Remove-PSDrive -Name MCM -Force
$EEnd = (GET-DATE)
$TS = NEW-TIMESPAN –Start $EStart –End $EEnd
$Min = $TS.minutes
$Sec = $TS.Seconds
Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan

$EStart = Get-Date
    Write-host "Creating Folder Paths file..." -ForegroundColor Green
    $DestFile2 = "$Folder\SCCM_Folder_Paths_$Date.csv"
    'E:\Packages Folder Path,Path ShortName,Matching Folder Paths' | Set-Content $DestFile2
    $SCCM1Packages | % { '"' + $_ + '","' + $_.replace('\\SERVER\E$\','SERVER\E$\') + '","' + $_.replace('\\SERVER\E$\','') + '"' | Add-Content $DestFile2 }
     $SCCM1Drivers | % { '"' + $_ + '","' + $_.replace('\\SERVER\E$\','SERVER\E$\') + '","' + $_.replace('\\SERVER\E$\','') + '"' | Add-Content $DestFile2 }
       $MCMFolders | % { '"' + $_ + '","' + $_.replace('\\DOMAIN.COM\GROUP1\SERVER1\MCM\','MCM\') + '","' + $_.replace('\\DOMAIN.COM\GROUP1\SERVER1\MCM\','') + '"'  | Add-Content $DestFile2 }
$EEnd = (GET-DATE)
$TS = NEW-TIMESPAN –Start $EStart –End $EEnd
$Min = $TS.minutes
$Sec = $TS.Seconds
Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
#############################################################################################################################
#############################################################################################################################
$ScriptEnd = (GET-DATE)
$TS = NEW-TIMESPAN –Start $ScriptStart –End $ScriptEnd
$Min = $TS.minutes
$Sec = $TS.Seconds
Write-Host "$(Get-Date)`tScript ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
