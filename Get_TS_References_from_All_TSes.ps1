#######################################
. "C:\Scripts\!Modules\GoGoSCCM_Module_client.ps1"$SiteCode = Get-PSDrive -PSProvider CMSITESet-Location -Path "$($SiteCode.Name):\"$TSS = Get-CMTaskSequence<#    SS100404 -- Windows 10 - MDT Newline
    SS1005EC -- Corp - Operating System Deployment v8.7.5.3
    SS10067C -- EpoTemporaryAutoboot Check
    SS100689 -- **DO NOT USE - TEST ONLY** - 1809 - UPGRADE
    SS1006A8 -- **DO NOT USE - TEST ONLY** - 1809 - NEW
    SS100724 -- **DO NOT USE - TEST ONLY** - 1809 - NEW OS ONLY
    SS100744 -- Windows 10 1909 - Upgrade OS.bak
    SS100745 -- Windows 10 1809 - PreCache-Upgrade Readiness-BAK
    SS10074A -- Windows 10 Enterprise x64 -USMT  PROD - Branch
    SS100759 -- Windows 10 (1809) - FULL INSTALL v4.9 PROD
    SS10075E -- Windows 10 (1809) - FULL INSTALL v4.7.2 PROD
    SS100766 -- Windows 10 Enterprise x64 - USMT Test - AppMapping
    SS10076C -- AOC DisplayLink USB Monitor
    SS100777 -- Windows 10 Enterprise x64 - USMT Dev
    SS10077F -- .Net 4.7.2 and IIS package for Branch Machines
    SS100785 -- IIS package(Dism) and .Net 4.7.2
    SS10078C -- Windows 10 Enterprise x64 - USMT Pilot- BackOffice
    SS100794 -- DDI TEST
    SS1007A2 -- Windows 10 1809 - PreCache-Readiness
    SS1007A3 -- Windows 10 1809 - Upgrade OS
    SS1007A9 -- Windows 10 Enterprise x64 - USMT Test - McAfeeDE
    SS1007AF -- App Mapping - No OS
    SS1007B0 -- Windows 10 1909 - PreCache-Readiness
    SS1007B1 -- Windows 10 1909 - OS Upgrade
    SS1007BA -- McAfee Testing
    SS1007BB -- Windows 10 Enterprise x64 - USMT Test - M-SS1007BB
    SS1007C5 -- * TEST - Windows 10 (1809) - FULL INSTALL v4.8 **
    SS1007CC -- Windows 10 (1809) - FULL INSTALL v4.8 PRO-SS1007CC
    SS1007CD -- Windows 10 (1809) - FULL INSTALL v4.8 Testing
    SS1007E0 -- Win10 Ent x64 - USMT - AppMapping
    SS1007E1 -- TESTING - USMT  PROD - Branch
    SS1007E4 -- TESTNG - FULL INSTALL
    SS1007F4 -- Windows 10 (1809) - FULL INSTALL v4.8 PROD - SAM
    SS1007FC -- Test Windows 10 (1809) - FULL INSTALL v4.9 PRODC
    SS1007FD -- Windows 10 (1909) - FULL INSTALL v1.7
    SS1007FF -- Windows 7 v8.7.53 - TESTCOPY
    SS100805 -- Windows 10 1909 - OS Upgrade-SS100805
    SS100825 -- 1e Test
    SS100828 -- Bitlocker Deployment#>ForEach ($TS in $TSS){           $TSID = $TS.PackageID        $TSName = $TS.name    $ADateStart = $(Get-Date -format yyyy-MM-dd)+'__'+ $(Get-Date -UFormat %R).Replace(':','.')        $Folder = 'D:\Powershell\!SCCM_PS_scripts\!DPs\SCCM_Check_DP_Content_Status'
         $TName = $TSName.replace('*','-')
         $TSLog = "$Folder\Task_Sequence--$TName--Results.csv"    Write-Host "Checking $TSName..." -ForegroundColor Magenta    $TSRefs = $TS.references | select Package
    ############################################################################    Write-Host "Generating..." -ForegroundColor Green    Write-Host "$TSLog`r`n" -NoNewline -ForegroundColor Yellow    $TSOutout = @()    $TSOutout += $TSRefs.package    ForEach ($TSR in $TSRefs)    {        If ($TSR.package -match 'ScopeId_')        {            $AppID = $TSR.package.split('/')[1]            $AppName = $(. "C:\Scripts\!Modules\ConvertFrom-CMApplicationCIUniqueID.ps1" -SiteServer 'sccm1' -CIUniqueID "$AppID").DisplayName            $TSOutout += $AppName        }    }    $TSOutout | Set-Content $TSLog}