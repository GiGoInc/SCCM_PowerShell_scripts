# Original script from
}
    }
# Original script from
# http://blogs.technet.com/b/configmgrdogs/archive/2013/05/09/package-amp-application-source-modification-scripts.aspx
# Modifications by https://t3chn1ck.wordpress.com
 
Write-Host "#######################################################################"
Write-Host "##        Matts ConfigMgr 2012 SP1 Package Source Modifier           ##"
Write-Host "##                blogs.technet.com/b/ConfigMgrDogs                  ##"
Write-Host "#######################################################################"

##############################

# ##############################
# # Add Required Type Libraries
#     [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ManagementProvider.dll")) | Out-Null
#     [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.dll")) | Out-Null
#     [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.Extender.dll")) | Out-Null
#     [System.Reflection.Assembly]::LoadFrom((Join-Path (Get-Item $env:SMS_ADMIN_UI_PATH).Parent.FullName "Microsoft.ConfigurationManagement.ApplicationManagement.MsiInstaller.dll")) | Out-Null
#  Set-Location XX1:
#  CD XX1:
# #############################

cls
C:
CD 'C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Start-Sleep -Milliseconds 500
Set-Location XX1:
CD XX1:

############################################################
############################################################

$PackageIDs = 
'XX100A50',
'XX100A4F',
'XX100A4B',
'XX100A51',
'XX100A4C',
'XX100A52',
'XX100A6E',
'XX100A6F',
'XX100A92',
'XX100A8D',
'XX100A8E',
'XX100A6C',
'XX100A6D',
'XX100A4D',
'XX100A4E',
'XX100A09',
'XX100A4A',
'XX100A08',
'XX100A56'

$Minutes = '2'
$Seconds = ([int]$minutes * 60)
ForEach ($PackageID in $PackageIDs)
{
    $Package = Get-CMPackage -Id "$PackageID" -Fast
    $OldPath = "\\cmcontent\Packages"
    $NewPath = "\\SERVER\dfs$\MCM\Packages"
    $OldPkgPath = $Package.PkgSourcePath

    If ($OldPkgPath.StartsWith("$OldPath"))
    {
       $ChangePath = $Package.PkgSourcePath
       $ChangePath = $ChangePath.Replace($OldPath, $NewPath)
    
       Set-CMPackage -Id $Package.PackageID -Path $ChangePath
       Write-Host "Changed: " -n -f White
       Write-Host $Package.PackageID " " -n -f Cyan
       Write-Host $Package.Name " " -n -f Yellow
       Write-Host "to " -n -f White
       Write-Host "$ChangePath" -f Green
       Update-CMDistributionPoint -PackageId $Package.PackageID
        Write-Host "Waiting $Minutes minutes..."
        Start-Sleep -Seconds $Seconds
    } 
    Else 
    {
       Write-Host "Not changed: " -n -f White
       Write-Host $Package.Name -f Red
    }
}
