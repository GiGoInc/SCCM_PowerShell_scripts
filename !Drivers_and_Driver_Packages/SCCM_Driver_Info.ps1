# Import Module
$CMModulepath = $Env:SMS_ADMIN_UI_PATH.ToString().Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + "\ConfigurationManager.psd1"
Import-Module $CMModulepath -force
# Change the site Code
CD SS1:

$ADate = Get-Date -Format "yyyy_MM-dd_hh-mm-ss"
# Log File
$Log = "D:\Powershell\!SCCM_PS_scripts\!Drivers_and_Driver_Packages\SCCM_Driver_Info--$ADate--Results.csv"
"ObjectPath,LocalizedDisplayName,DriverClass,LocalizedCategoryInstanceNames,DriverVersion,DriverProvider,DriverINFFile,DriverDate,CreatedBy,LastModifiedBy,DateCreated,DateLastModified,ContentSourcePath" | Set-Content $Log

cls
Write-Host "`nWorking on gathering drivers..." -ForegroundColor Yellow
$Drivers = Get-CMDriver | Select ObjectPath, LocalizedDisplayName, DriverClass, LocalizedCategoryInstanceNames, DriverVersion, DriverProvider, DriverINFFile, DriverDate, CreatedBy, LastModifiedBy, DateCreated, DateLastModified, ContentSourcePath

ForEach ($D in $Drivers)
{
    $ObjectPath                     = $D.ObjectPath
    $LocalizedDisplayName           = $D.LocalizedDisplayName
    $DriverClass                    = $D.DriverClass
    $LocalizedCategoryInstanceNames = $D.LocalizedCategoryInstanceNames
    $DriverVersion                  = $D.DriverVersion
    $DriverProvider                 = $D.DriverProvider
    $DriverINFFile                  = $D.DriverINFFile
    $DriverDate                     = $D.DriverDate
    $CreatedBy                      = $D.CreatedBy
    $LastModifiedBy                 = $D.LastModifiedBy
    $DateCreated                    = $D.DateCreated
    $DateLastModified               = $D.DateLastModified
    $ContentSourcePath              = $D.ContentSourcePath

    "$ObjectPath,$LocalizedDisplayName,$DriverClass,$LocalizedCategoryInstanceNames,$DriverVersion,`"$DriverProvider`",$DriverINFFile,$DriverDate,$CreatedBy,$LastModifiedBy,$DateCreated,$DateLastModified,$ContentSourcePath" | Add-Content $Log
}

Write-Host "`nWe done!" -ForegroundColor Green
D:
Start-Sleep -Seconds 5