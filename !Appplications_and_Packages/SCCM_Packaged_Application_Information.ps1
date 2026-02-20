cls
}
    }
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
$CurrentDirectory = split-path $MyInvocation.MyCommand.Path
$ScriptName = $MyInvocation.MyCommand.Name
$ADateE = Get-Date
$Date = $(get-date -format yyyy-MM-dd)+'__'+ $(get-date -UFormat %R).Replace(':','.')
$DestFile = "$CurrentDirectory\SCCM_Packaged_Application_Information_$Date.csv"

If (Test-Path -Path $DestFile){Remove-Item -Path $DestFile -Force}


"Application Name,Package ID,Created By,Date Created,Date Modified,Last Modified By" -join "," | Set-Content $DestFile

# Loading SCCM Applications List
    Write-host "Checking Applications..." -ForegroundColor Green
    $A = Get-CMApplication -Name * | Select-Object LocalizedDisplayName,PackageID,CreatedBy,DateCreated,DateLastModified,LastModifiedBy

    $End = (GET-DATE)
    $TS = NEW-TIMESPAN –Start $Start –End $End
    $Min = $TS.minutes
    $Sec = $TS.Seconds
    Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan


ForEach ($B in $A)
{
	$AppName = $B.LocalizedDisplayName
	  $PkgID = $B.PackageID
	$Creator = $B.CreatedBy
	$DCreate = $B.DateCreated
	$DModify = $B.DateLastModified
 $LastModder = $B.LastModifiedBy
          $t = NEW-TIMESPAN –Start $DModify –End $ADateE | select days
 
    Write-Output $AppName $PkgID $Creator $DCreate $DModify $LastModder
    "$AppName,$PkgID,$Creator,$DCreate,$DModify,$LastModder" -join "," | Add-Content $DestFile
}



$C = Get-CMPackage -Name * | Select-Object Name,PackageID,SourceDate,PkgSourcePath

ForEach ($D in $C)
{
    $PkgName = $D.Name
      $PkgID = $D.PackageID
     $PkgDLM = $D.SourceDate
      $PkgSP = $D.PkgSourcePath
          $t = NEW-TIMESPAN –Start $PkgDLM –End $ADateE | select days

    If ($t.Days -lt '1')
    { 
        Write-Output $PkgName $PkgID $PkgDLM $PkgSP
        "$PkgName,$PkgID,$PkgDLM,$PkgSP" -join "," | Add-Content $DestFile
    }
}
