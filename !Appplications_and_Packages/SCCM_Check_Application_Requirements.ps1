<#
#>
$DTInstaller = $DTRequirement | Select DisplayName -ExpandProperty DisplayName
<#
.Synopsis
This script is intended to be called by itself to check all the applications in SCCM and return the DeploymentTypes for each application.
Specifically it writes a log that contains all the Requirements for a DeploymentType.

The data follows comma separated order:
Application Name,,DeploymentType,Requirements 1,Requirements 2,Requirements 3,Requirements 4,Requirements 5,Requirements 6,Requirements 7,Requirements 8,Requirements 9,Requirements 10

.Example
PS C:\> .\Check_Application_Requirements.ps1
    Change PC Name during OSD,No DeploymentTypes for this Application
    PSTools,Install,Operating system One of All Windows 7 (64-bit),All Windows 7 (32-bit),Windows 7 (64-bit),Windows 7 SP1 (64-bit),Windows 7 (32-bit),Windows 7 SP1 (32-bit),All Windows 8 (64-bit),All Windows 8 (32-bit),All Windows 8.1 (64-bit),All Windows 8.1 (32-bit)
    Adobe Acrobat 10 Standard,Adobe Acrobat 10 Standard (Native),No Requirements for this DeploymentType
#>

[System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.dll")) | Out-Null
[System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.Extender.dll")) | Out-Null
[System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.MsiInstaller.dll")) | Out-Null
 
$SiteServer = "SERVER"
$SiteCode = "XX1"

# Flip flag to write out to screen or not - True = Run the Write-Host lines
    $Write_To_Screen = 'False'

$ADateStart = Get-Date -Format "yyyy-MM-dd__hh.mm.ss.tt"
$Log = ".\Check_Application_Requirements---Results_$ADateStart.csv"
'Application Name,DeploymentType Name,Requirements 1,Requirements 2,Requirements 3,Requirements 4,Requirements 5,Requirements 6,Requirements 7,Requirements 8,Requirements 9,Requirements 10' | Set-Content $Log

$Applications = Get-WmiObject -ComputerName $SiteServer -Namespace root\SMS\site_$SiteCode -class SMS_Application | Where-Object {$_.IsLatest -eq $True}
$ApplicationCount = $Applications.Count

CLS
Write-Host "`n"
Write-Host "INFO: There is a total of $($ApplicationCount) applications`n"
Write-Host "Starting Application Check`t$(Get-Date)" -ForegroundColor Cyan
Write-Host "This should take about five minutes..." -ForegroundColor Yellow

#  $Application is TEST code to check a specific application by name
#  $Application = $Applications | Where-Object{ $_.LocalizedDisplayName -eq 'Change PC Name during OSD'}

$Applications | ForEach-Object{
    $CheckApplication = [wmi]$_.__PATH
    If ($Write_To_Screen -eq $True){Write-Host "Retrieving information for Application: " $CheckApplication.LocalizedDisplayName -ForegroundColor Green}

    $CheckApplicationXML = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($CheckApplication.SDMPackageXML,$True)
		If ($CheckApplicationXML.DeploymentTypes -ne $Null)
        {
            ForEach ($CheckDeploymentType in $CheckApplicationXML.DeploymentTypes)
            {
                If ($Write_To_Screen -eq $True){Write-Host "`tDeploymentType: " $CheckDeploymentType.Title -ForegroundColor Yellow -NoNewline}

                $CheckInstaller = $CheckDeploymentType.Requirements
                If ($CheckInstaller -ne $Null)
                {
                    If ($Write_To_Screen -eq $True){Write-Host ''}
                    $CR = $CheckInstaller.Name.Replace('{','').Replace('}','').Replace('Operating system One of','').replace(',\s',',').Split(',').trim() | sort-object
                    $CheckRules = $CR -join ','

                    If ($Write_To_Screen -eq $True){Write-Host "`t`tRequirements: " $CheckInstaller.Name -ForegroundColor Cyan}
                    $CheckApplication.LocalizedDisplayName+','+$CheckDeploymentType.Title+','+$CheckRules | Add-Content $Log
                }
                Else
                {
                    If ($Write_To_Screen -eq $True){Write-Host "`tNo Requirements for this DeploymentType" -ForegroundColor Yellow}
                    $CheckApplication.LocalizedDisplayName+','+$CheckDeploymentType.Title+',  No Requirements for this DeploymentType' | Add-Content $Log
                }
            }
        }
        Else
        {
            If ($Write_To_Screen -eq $True){Write-Host "`tDeploymentType: No DeploymentTypes for this Application" -ForegroundColor Yellow}
            $CheckApplication.LocalizedDisplayName+',  No DeploymentTypes for this Application' | Add-Content $Log
        }
    }
	
Write-Host "Application Check Completed`t$(Get-Date)" -ForegroundColor Green

Read-Host -Prompt 'Press Enter to exit...'
Exit


# $Applications | Where-Object{ $_.LocalizedDisplayName -eq 'Change PC Name during OSD'}



<#

    ([xml]($app.SDMPackageXML)).AppMgmtDigest.DeploymentType.Installer.RequiresLogon
    
    [xml]$xml = Get-Content $serviceStatePath
    Select-Xml "//Annotation[DisplayName]" $xml | % {$_.Node.' #text'}
    
    Object = Annotation
    Property = DisplayName
    @Text =
    Select-Xml "//Object[Property/@Name='ServiceState' and Property='Running']/Property[@Name='DisplayName']" $xml | % {$_.Node.' #text'}
    
    Write-Host "UPDATE: Updated content path will be:"
    Write-Host -ForegroundColor Red "$($CheckUpdatedPath)`n"
    
    
        foreach ($CheckDeploymentType in $CheckApplicationXML.DeploymentTypes) {
            $CheckInstaller = $CheckDeploymentType.Installer
            $CheckContents = $CheckInstaller.Contents[0]
            $CheckUpdatedPath = $CheckContents.Location -replace "$($CurrentContentPath)","$($UpdatedContentPath)"
            Write-Host "INFO: Current content path for $($_.LocalizedDisplayName):"
            Write-Host -ForegroundColor Green "$($CheckContents.Location)"
            Write-Host "UPDATE: Updated content path will be:"
            Write-Host -ForegroundColor Red "$($CheckUpdatedPath)`n"	
    

Function FAKEFUNCTION ($FAKE)
{
([xml]($app.SDMPackageXML)).AppMgmtDigest.DeploymentType.Installer.RequiresLogon
	
$DeploymentTypes = Get-CMDeploymentType -ApplicationName "Citrix Receiver"
$SDMPackageXML = $DeploymentTypes | Select SDMPackageXML -ExpandProperty SDMPackageXML
$DTInfo = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($SDMPackageXML)	
$DTRequirement = $DTRequirements[0]
$DTInstaller = $DTRequirement | Select DisplayName -ExpandProperty DisplayName
#>
