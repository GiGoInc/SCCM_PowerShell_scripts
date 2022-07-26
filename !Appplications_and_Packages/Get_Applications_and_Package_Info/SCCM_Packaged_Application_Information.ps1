cls
##############################
# Add Required Type Libraries
    [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ManagementProvider.dll")) | Out-Null
    [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.dll")) | Out-Null
    [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.Extender.dll")) | Out-Null
    [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.MsiInstaller.dll")) | Out-Null
Set-Location SS1:
CD SS1:
##############################
C:
CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:
CD SS1:
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
"Item Type,Application Name,Manufacturer,Version,Package ID,Created By,Date Created,Date Modified,Last Modified By,Source Path,Expired/Retired" -join "," | Set-Content $DestFile
#############################################################################################################################
#############################################################################################################################
    $CMAStart = Get-Date
    # Loading SCCM Applications List
    Write-host "Checking Applications..." -ForegroundColor Green
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
    ForEach ($B in $CMA)
    {
        $AppMgmt = ([xml]$B.SDMPackageXML).AppMgmtDigest
        # $AppName = $AppMgmt.Application.DisplayInfo.FirstChild.Title
        $AppName = $B.LocalizedDisplayName

        foreach ($DeploymentType in $AppMgmt.DeploymentType)
        {           
            # Fill properties
            # $AppData = @{            
                $AppName  = $AppName
                $Location = $DeploymentType.Installer.Contents.Content.Location
            #     }                           
            # Create object
                # $Object = New-Object PSObject -Property $AppData
            # Return it
                # $Object
        }

	    #$AppName = $B.LocalizedDisplayName
	    $Manufan = $B.Manufacturer
	    $Version = $B.SoftwareVersion
	      $PkgID = $B.PackageID
	    $Creator = $B.CreatedBy
	    $DCreate = $B.DateCreated
	    $DModify = $B.DateLastModified
     $LastModder = $B.LastModifiedBy
      $IsEnabled = $B.IsEnabled
      $IsExpired = $B.IsExpired

        #Write-Output $AppName $Manufan $Version  $PkgID $Creator $DCreate $DModify $LastModder $Location $IsExpired
        'Application,"' + $AppName + '","' + $Manufan + '","' + $Version + '","' + $PkgID + '","' + $Creator + '","' + $DCreate + '","' + $DModify + '","' + $LastModder + '","' + $Location + '","' + $IsExpired + '"'  | Add-Content $DestFile
    }

$BEnd = (GET-DATE)
$TS = NEW-TIMESPAN –Start $BStart –End $BEnd
$Min = $TS.minutes
$Sec = $TS.Seconds
Write-Host "$(Get-Date)`tChecking Applications properties ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
#############################################################################################################################
#############################################################################################################################
$CStart = Get-Date
    Write-host "Checking Packages..." -ForegroundColor Green
    $C = Get-CMPackage -Name * # | Select-Object Name,PackageID,SourceDate,PkgSourcePath
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
       $obj += 'Package,"' + $PkgName + '","' + $Manufan + '","' + $PKGVer + '","' + $PkgID + '",,"' + $PkgDLM + '",,,"' + $PkgSP + '"'
}
$obj | Add-Content $DestFile
$DEnd = (GET-DATE)
$TS = NEW-TIMESPAN –Start $DStart –End $DEnd
$Min = $TS.minutes
$Sec = $TS.Seconds
Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
