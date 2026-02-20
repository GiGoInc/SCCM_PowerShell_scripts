cls

}
cls
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

$ADate = Get-Date -Format "yyyy_MM-dd"
$Applications = 'DELL BIOS LATITUDE 7400 2-IN-1_1.25.0', 
'DELL BIOS LATITUDE_5500_1.25.0', 
'DELL BIOS LATITUDE_5520 - 1.32.1', 
'DELL BIOS LATITUDE_5530_1.18.0', 
'DELL BIOS LATITUDE_5540_1.9.0', 
'DELL BIOS LATITUDE_5580_1.32.2', 
'DELL BIOS LATITUDE_7390_1.34.0', 
'DELL BIOS LATITUDE_7400 - 1.28.0', 
'DELL BIOS LATITUDE_7410_1.25.1', 
'DELL BIOS LATITUDE_7420 1.30.1', 
'DELL BIOS LATITUDE_7430_1.18.0', 
'DELL BIOS LATITUDE_7440_1.13.0', 
'DELL BIOS OPTIPLEX_7000_1.18.1', 
'DELL BIOS OPTIPLEX_7010_1.8.0', 
'DELL BIOS OPTIPLEX_7010_SFF_1.13.1', 
'DELL BIOS OPTIPLEX_7040 _1.24.0', 
'DELL BIOS OPTIPLEX_7050_1.24.0', 
'DELL BIOS OPTIPLEX_7070 - 1.22.0', 
'DELL BIOS OPTIPLEX_7080_1.23.0', 
'DELL BIOS OPTIPLEX_7090 1.19.0', 
'DELL BIOS PRECISION 7740_1.29.0'

$i = 1
$total = $applications.count
ForEach ($Application in $Applications)
{
    "$i of $total -- checking $Application..."
    $CMApp = $null
    $CMApp = Get-CMApplication -Name $Application
    If ($CMApp -eq $null){}
    Else
    {
        #################################################################
        # EXPORT APPLICATION
        "Exporting Application..."
        Get-CMApplication "$Application" | Export-CMApplication -Path "D:\Powershell\!SCCM_PS_scripts\SCCM_Exported_Apps_Packages\$ADate--$Application.zip" -IgnoreRelated -OmitContent -Comment "Application export" -Force 
        #################################################################
        $PkgID = $($CMApp.PackageID)
        $CIIC = $($CMApp.CI_ID)
        $DistStatus = Get-CMDistributionStatus -Id $PkgID

        If (($($DistStatus.Targeted -eq 0)) -and
            ($($DistStatus.NumberErrors -eq 0)) -and
            ($($DistStatus.NumberInProgress -eq 0)) -and
            ($($DistStatus.NumberSuccess -eq 0)))
        {
            Write-Host "$i of $total -- $Application has no distributed content - deleting" -f Green
            Remove-CMApplication -InputObject $CMApp -Force
        }
        Else
        {
            Write-Host "$i of $total -- $Application --- Found Content" -f Red
            $DPgroups = "Datacenter DPs",
                        "All DP's",
                        "BackOffice Sites",
                        "PXE Boot",
                        "Software Patching - Servers"
            ForEach ($DPGroup in $DPGroups)
            {
                $ErrorActionPreference = 'SilentlyContinue'
                Write-Host "Removing $Application content from `"$DPGroup`"" -f Yellow
                Remove-CMContentDistribution -ApplicationId $CIIC -DistributionPointGroupName "$DPGroup" -Force
            }
            $DPs = 'SERVER.DOMAIN.COM',
                    'SERVER.DOMAIN.COM',
                    'SERVER.DOMAIN.COM',
                    'SERVER.DOMAIN.COM',
                    'SERVER.DOMAIN.COM',
                    'SERVER.DOMAIN.COM',
                    'SERVER.DOMAIN.COM',
                    'SERVER.DOMAIN.COM',
                    'SERVER.DOMAIN.COM',
                    'SERVER.DOMAIN.COM',
                    'SERVER.DOMAIN.COM',
                    'SERVER.DOMAIN.COM'
            ForEach ($DP in $DPs)
            {
                $ErrorActionPreference = 'SilentlyContinue'
                Write-Host "Removing $Application content from `"$DP`"" -f Yellow
                Remove-CMContentDistribution -ApplicationId "$CIIC" -DistributionPointName "$DP" -force
            }
            Remove-CMApplication -InputObject $CMApp -Force
        }
    }
    $i++
}

