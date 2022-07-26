[System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.dll")) | Out-Null
[System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.Extender.dll")) | Out-Null
[System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.MsiInstaller.dll")) | Out-Null
 
Set-Location SS1:
CD SS1:

$SiteServer = "SCCMSERVER"
$SiteCode = "SS1"

$FileName = "D:\Powershell\!SCCM_PS_scripts\!Appplications_and_Packages\!Appplications_and_Packages\Application_Information_$(Get-Date -f yyyy-MM-dd).txt"
Write-Host "Getting all application names...this will take a few minutes" -ForegroundColor Cyan
$AppNames = Get-CMApplication  | Select -ExpandProperty LocalizedDisplayName,CreatedBy,DateCreated,DateLastModified
$Appnames | Sort | Set-Content $FileName

$A.LocalizedDisplayName +"`t" + $A.CreatedBy +"`t" + $A.DateCreated +"`t" + $A.DateLastModified +"`t" + $A.LastModifiedBy | Add-Content $AppInfoFile



<#
Function FAKEFUNCTION ($FAKE)
{
[System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.dll")) | Out-Null
[System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.Extender.dll")) | Out-Null
[System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.MsiInstaller.dll")) | Out-Null
 
$SiteServer = "SCCMSERVER"
$SiteCode = "SS1"
$CurrentContentPath = "\\\\<name_of_server_where_the_content_was_stored_previously\\<folder>\\<folder>"
$UpdatedContentPath = "\\<name_of_the_server_where_the_content_is_stored_now\<folder>\<folder>"
 
$Applications = Get-WmiObject -ComputerName $SiteServer -Namespace root\SMS\site_$SiteCode -class SMS_Application | Where-Object {$_.IsLatest -eq $True}
$ApplicationCount = $Applications.Count
 
Write-Output ""
Write-Output "INFO: A total of $($ApplicationCount) applications will be modified`n"
Write-Output "INFO: Value of current content path: $($CurrentContentPath)"
Write-Output "INFO: Value of updated content path: $($UpdatedContentPath)`n"
Write-Output "# What would you like to do?"
Write-Output "# ---------------------------------------------------------------------"
Write-Output "# 1. Verify first - Verify the applications new path before updating"
Write-Output "# 2. Update now - Update the path on all applications"
Write-Output "# ---------------------------------------------------------------------`n"
$EnumAnswer = Read-Host "Please enter your selection [1,2] and press Enter"
 
switch ($EnumAnswer) {
    1 {$SetEnumAnswer = "Verify"}
    2 {$SetEnumAnswer = "Update"}
    Default {$SetEnumAnswer = "Verify"}
}
 
if ($SetEnumAnswer -like "Verify") {
    Write-Output ""
    $Applications | ForEach-Object {
        $CheckApplication = [wmi]$_.__PATH
        $CheckApplicationXML = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($CheckApplication.SDMPackageXML,$True)
        foreach ($CheckDeploymentType in $CheckApplicationXML.DeploymentTypes) {
            $CheckInstaller = $CheckDeploymentType.Installer
            $CheckContents = $CheckInstaller.Contents[0]
            $CheckUpdatedPath = $CheckContents.Location -replace "$($CurrentContentPath)","$($UpdatedContentPath)"
            Write-Output "INFO: Current content path for $($_.LocalizedDisplayName):"
            Write-Output -ForegroundColor Green "$($CheckContents.Location)"
            Write-Output "UPDATE: Updated content path will be:"
            Write-Output -ForegroundColor Red "$($CheckUpdatedPath)`n"
        }
    }
}
}
#>