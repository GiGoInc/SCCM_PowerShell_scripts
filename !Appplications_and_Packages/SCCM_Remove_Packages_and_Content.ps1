cls

}
cls
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
$Packages = 'DELL BIOS LATITUDE 5520 3560', 
'DELL BIOS OPTIPLEX 7070', 
'DELL BIOS OPTIPLEX 7090', 
'DELL BIOS OPTIPLEX 7090 1.18.1'

#################################################################
#################################################################

$i = 1
$total = $Packages.count
ForEach ($Package in $Packages)
{
    $ModName = $Package.Replace('/','-')
    "$i of $total -- checking $Package..."
    $CMPkg = $null
    $CMPkg = Get-CMPackage -Name $Package -Fast
    If ($CMPkg -eq $null){}
    Else
    {
        #################################################################
        # EXPORT PACKAGE
        "Exporting Package..."
        Get-CMPackage -Name "$Package" -Fast | Export-CMPackage -Path "D:\Powershell\!SCCM_PS_scripts\SCCM_Exported_Apps_Packages\$ADate--$ModName.zip" -WithContent $False  -Comment "Package export" -Force 
        #################################################################


        $PkgID = $($CMPkg.PackageID)
        $CIIC = $($CMPkg.CI_ID)
        $DistStatus = Get-CMDistributionStatus -Id $PkgID

        If (($($DistStatus.Targeted -eq 0)) -and
            ($($DistStatus.NumberErrors -eq 0)) -and
            ($($DistStatus.NumberInProgress -eq 0)) -and
            ($($DistStatus.NumberSuccess -eq 0)))
        {
            Write-Host "$i of $total -- $Package has no distributed content - deleting" -f Green
            Remove-CMPackage -InputObject $CMPkg -Force
        }
        ElseIf ($DistStatus -eq $null)
        {
            Write-Host "$i of $total -- $Package has no distributed content - deleting" -f Green
            Remove-CMPackage -InputObject $CMPkg -Force
        }
        Else
        {
            Write-Host "$i of $total -- $Package --- Found Content" -f Red
            $DPgroups = "Datacenter DPs",
                        "All DP's",
                        "BackOffice Sites",
                        "PXE Boot",
                        "Software Patching - Servers"
            ForEach ($DPGroup in $DPGroups)
            {
                $ErrorActionPreference = 'SilentlyContinue'
                Write-Host "Removing $Package content from `"$DPGroup`"" -f Yellow
                Remove-CMContentDistribution -PackageId $PkgID -DistributionPointGroupName "$DPGroup" -Force
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
                Write-Host "Removing $Package content from `"$DP`"" -f Yellow
                Remove-CMContentDistribution -PackageId "$PkgID" -DistributionPointName "$DP" -force
            }
            Remove-CMPackage -InputObject $CMPkg -Force
        }
    }
    $i++
}

