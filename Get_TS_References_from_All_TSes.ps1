#######################################
}
    $TSOutout | Set-Content $TSLog
#######################################
. "C:\Scripts\!Modules\GoGoSCCM_Module_client.ps1"
$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-Location -Path "$($SiteCode.Name):\"
$TSS = Get-CMTaskSequence

<#
    XX100404 -- Windows 10 - MDT Newline
    XX1005EC -- HWC - Operating System Deployment v8.7.5.3
    XX10067C -- EpoTemporaryAutoboot Check
    XX100689 -- **DO NOT USE - TEST ONLY** - 1809 - UPGRADE
    XX1006A8 -- **DO NOT USE - TEST ONLY** - 1809 - NEW
    XX100724 -- **DO NOT USE - TEST ONLY** - 1809 - NEW OS ONLY
    XX100744 -- Windows 10 1909 - Upgrade OS.bak
    XX100745 -- Windows 10 1809 - PreCache-Upgrade Readiness-BAK
    XX10074A -- Windows 10 Enterprise x64 -USMT  PROD - RemoteLocale
    XX100759 -- Windows 10 (1809) - FULL INSTALL v4.9 PROD
    XX10075E -- Windows 10 (1809) - FULL INSTALL v4.7.2 PROD
    XX100766 -- Windows 10 Enterprise x64 - USMT Test - AppMapping
    XX10076C -- AOC DisplayLink USB Monitor
    XX100777 -- Windows 10 Enterprise x64 - USMT Dev
    XX10077F -- .Net 4.7.2 and IIS package for RemoteLocale Machines
    XX100785 -- IIS package(Dism) and .Net 4.7.2
    XX10078C -- Windows 10 Enterprise x64 - USMT Pilot- BackOffice
    XX100794 -- DDI TEST
    XX1007A2 -- Windows 10 1809 - PreCache-Readiness
    XX1007A3 -- Windows 10 1809 - Upgrade OS
    XX1007A9 -- Windows 10 Enterprise x64 - USMT Test - McAfeeDE
    XX1007AF -- App Mapping - No OS
    XX1007B0 -- Windows 10 1909 - PreCache-Readiness
    XX1007B1 -- Windows 10 1909 - OS Upgrade
    XX1007BA -- McAfee Testing
    XX1007BB -- Windows 10 Enterprise x64 - USMT Test - M-XX1007BB
    XX1007C5 -- * TEST - Windows 10 (1809) - FULL INSTALL v4.8 **
    XX1007CC -- Windows 10 (1809) - FULL INSTALL v4.8 PRO-XX1007CC
    XX1007CD -- Windows 10 (1809) - FULL INSTALL v4.8 Testing
    XX1007E0 -- Win10 Ent x64 - USMT - AppMapping
    XX1007E1 -- TESTING - USMT  PROD - RemoteLocale
    XX1007E4 -- TESTNG - FULL INSTALL
    XX1007F4 -- Windows 10 (1809) - FULL INSTALL v4.8 PROD - SAM
    XX1007FC -- Test Windows 10 (1809) - FULL INSTALL v4.9 PRODC
    XX1007FD -- Windows 10 (1909) - FULL INSTALL v1.7
    XX1007FF -- Windows 7 v8.7.53 - TESTCOPY
    XX100805 -- Windows 10 1909 - OS Upgrade-XX100805
    XX100825 -- 1e Test
    XX100828 -- Bitlocker Deployment
#>

ForEach ($TS in $TSS)
{ 
          $TSID = $TS.PackageID
        $TSName = $TS.name
    $ADateStart = $(Get-Date -format yyyy-MM-dd)+'__'+ $(Get-Date -UFormat %R).Replace(':','.')
        $Folder = 'D:\Powershell\!SCCM_PS_scripts\!DPs\SCCM_Check_DP_Content_Status'
         $TName = $TSName.replace('*','-')
         $TSLog = "$Folder\Task_Sequence--$TName--Results.csv"
    Write-Host "Checking $TSName..." -ForegroundColor Magenta
    $TSRefs = $TS.references | select Package
    ############################################################################
    Write-Host "Generating..." -ForegroundColor Green
    Write-Host "$TSLog`r`n" -NoNewline -ForegroundColor Yellow
    $TSOutout = @()
    $TSOutout += $TSRefs.package
    ForEach ($TSR in $TSRefs)
    {
        If ($TSR.package -match 'ScopeId_')
        {
            $AppID = $TSR.package.split('/')[1]
            $AppName = $(. "C:\Scripts\!Modules\ConvertFrom-CMApplicationCIUniqueID.ps1" -SiteServer 'SERVER' -CIUniqueID "$AppID").DisplayName
            $TSOutout += $AppName
        }
    }
    $TSOutout | Set-Content $TSLog
}
