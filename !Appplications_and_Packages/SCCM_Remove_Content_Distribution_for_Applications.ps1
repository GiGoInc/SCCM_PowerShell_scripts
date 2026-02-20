$applications = '8021x Hotfixes',

}
$applications = '8021x Hotfixes',
'Adobe Acrobat Reader 2017 MUI',
'Bomgar Jump Client',
'CUDeviceManager v4.0.0.119',
'Cisco WebEx Recorder and Player',
'Image Centre 2022',
'Monarch 2020',
'Privilege Management for Windows (x64) 21.6.153.0',
'Veritas Enterprise Vault Discovery Accelerator Client 12.4.0.1105',
'Veritas Enterprise Vault Discovery Accelerator Client 14.1.1.1165',
'Veritas Enterprise Vault Outlook Add-in 14.2.0.1226'

$i = 1
$total = $applications.count
ForEach ($Application in $Applications)
{
    "$i of $total -- deleting $Application..."

    $CMApp = Get-CMApplication -Name $Application
    $PkgID = $($CMApp.PackageID)
    $CIIC = $($CMApp.CI_ID)
    $DistStatus = Get-CMDistributionStatus -Id $PkgID

    If (($($DistStatus.Targeted -eq 0)) -and
        ($($DistStatus.NumberErrors -eq 0)) -and
        ($($DistStatus.NumberInProgress -eq 0)) -and
        ($($DistStatus.NumberSuccess -eq 0)))
    {
        Write-Host "$i of $total -- $Application has no distributed content - deleting" -f Green
        # Remove-CMApplication -InputObject $CMApp -Force
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
    }
    $i++
}

