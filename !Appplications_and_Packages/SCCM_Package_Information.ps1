cls
}                
    "$PkgName,$PkgID,$PkgSP,$PkgSD,$PkgLR" -join "," | Add-Content $DestFile                
cls

# Add Required Type Libraries
    [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ManagementProvider.dll")) | Out-Null
    [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.dll")) | Out-Null
    [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.Extender.dll")) | Out-Null
    [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.MsiInstaller.dll")) | Out-Null
 
Set-Location XX1:
CD XX1:


# Variables
#Get current working paths
 # $CurrentDirectory = split-path $MyInvocation.MyCommand.Path
 # $ScriptName = $MyInvocation.MyCommand.Name
$Date = $(get-date -format yyyy-MM-dd)+'__'+ $(get-date -UFormat %R).Replace(':','.')
$DestFile = "D:\Powershell\!SCCM_PS_scripts\!Appplications_and_Packages\$Date--SCCM_Application_Information.csv"

	# If (Test-Path -Path "$CurrentDirectory\SCCM_Application_Information.txt"){Remove-Item -Path $DestFile -Force}


"Application Name,Package ID,Created By,Date Created,Date Modified,Last Modified By" -join "," | Add-Content $DestFile



$C = Get-CMPackage -Name * | Select-Object Name,PackageID,PkgSourcePath,SourceDate,LastRefreshTime

ForEach ($D in $C)
{
    $PkgName = $D.Name
    $PkgID = $D.PackageID
    $PkgSP = $D.PkgSourcePath
    $PkgSD = $D.SourceDate
    $PkgLR = $D.LastRefreshTime
    
    Write-Output "$PkgName`t$PkgID"
    "$PkgName,$PkgID,$PkgSP,$PkgSD,$PkgLR" -join "," | Add-Content $DestFile                
}                
