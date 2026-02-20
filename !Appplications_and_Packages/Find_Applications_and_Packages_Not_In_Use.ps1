cls
Write-Host "Done! CSVs stored in D:\Powershell\!SCCM_PS_scripts\!Appplications_and_Packages." -ForegroundColor Green

cls
##############################
try
{
    Import-Module ConfigurationManager -ErrorAction 'Stop'
    Set-Location XX1:
}
catch [System.IO.FileNotFoundException]
{
    throw 'The ConfigurationManager module cannot be found.'
}
##############################
# Add Required Type Libraries
    [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ManagementProvider.dll")) | Out-Null
    [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.dll")) | Out-Null
    [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.Extender.dll")) | Out-Null
    [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.MsiInstaller.dll")) | Out-Null
##############################
C:
CD 'C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
##############################
Start-Sleep -Milliseconds 500
Set-Location XX1:
CD XX1:
##############################
$ADate = Get-Date -Format "yyyy_MM-dd"
# Grab all non-deployed/0 dependent TS/0 dependent DT applications, and all packages (can't filter packages like applications)
$FinalApplications = Get-CMApplication | Where-Object {($_.IsDeployed -eq $False) -and ($_.NumberofDependentTS -eq 0) -and ($_.NumberofDependentDTs -eq 0)}
$AllPackages = Get-CMPackage

Write-Host "Grabbed relevant applications and all packages." -ForegroundColor Cyan

# Grab all task sequences, filter to just a list of their references
$TSReferences = Get-CMTaskSequence | Select-Object -ExpandProperty References

Write-Host "Grabbed all task sequences and filtered for their references." -ForegroundColor Cyan

# Grab all deployments, filter to just a list of their package IDs
$DeploymentPackageIDs = Get-CMDeployment | Select-Object -ExpandProperty PackageID

Write-Host "Grabbed all deployments and filtered for their PackageIDs." -ForegroundColor Cyan
##############################
$FinalPackages = New-Object -TypeName 'System.Collections.ArrayList'

# Filter packages to only those that do not have their PackageID in the list of references
foreach ($package in $AllPackages) {
    if (($package.PackageID -notin $TSReferences.package) -and ($package.PackageID -notin $DeploymentPackageIDs)) {
        $FinalPackages.Add($package)
    } 
}
Write-Host "Filtered packages through references and deployment PackageIDs." -ForegroundColor Cyan
############################################################
$FinalApplications | Select-Object -Property LocalizedDisplayName, PackageID, DateCreated, DateLastModified, IsDeployable, IsEnabled, IsExpired, IsHidden, IsSuperseded | Sort-Object -Property LocalizedDisplayName `
    | Export-Csv -Path "D:\Powershell\!SCCM_PS_scripts\!Appplications_and_Packages\$ADate--SCCM_Applications_Not_In_Use.csv"

$FinalPackages | Select-Object Name, PackageID, SourceDate, LastRefreshTime | Sort-Object -Property Name `
    | Export-Csv -Path "D:\Powershell\!SCCM_PS_scripts\!Appplications_and_Packages\$ADate--SCCM_Packages_Not_In_Use.csv"

Write-Host "Done! CSVs stored in D:\Powershell\!SCCM_PS_scripts\!Appplications_and_Packages." -ForegroundColor Green
