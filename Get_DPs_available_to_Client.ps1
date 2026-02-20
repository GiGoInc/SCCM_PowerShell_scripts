# Define main variables:


# Define main variables:
    $site = (Get-WmiObject -ComputerName 'SERVER' -Namespace "ROOT\SMS" -Query "Select * from SMS_ProviderLocation" | Select-Object -First 1).SiteCode
    $SCCMConsoleInstallDir = (Get-ItemProperty "hklm:\software\WOW6432Node\Microsoft\ConfigMgr10\setup")."UI Installation Directory"
    Import-Module "$SCCMConsoleInstallDir\bin\ConfigurationManager.psd1"
    cd ($site + ":")



$computers = 'SERVER'
# $Computers = 'LASPTN61','LASPTN62','LASPTN63','LASPTN64','LASPTN65','LASPTN66','LASPTN67','LASPTN68'

cls
ForEach ($computer in $Computers)
{
    $ClientObject = Get-WmiObject -ComputerName 'SERVER' -Namespace "ROOT\SMS\site_$site" -Query "select * from SMS_R_System" | Where {$_.ADSiteName -ne $null -and $_.Name -eq $Computer}
    $ClientADSite = $ClientObject.ADSiteName
    
    $ClientBoundary = Get-CMBoundary | Where {$_.DisplayName -like "*$ClientADSite*"} | select displayname,sitesystems
    $Boundaries = Get-CMBoundary | select displayname
    [array]$DPs = $ClientBoundary.SiteSystems
    
    Write-Host 'The list of Distribution Points associated with the client ' -NoNewline
    Write-Host $Computer -NoNewline -ForegroundColor Green
    write-host ' is the following: ' -NoNewline
    $DPArray = @()
    foreach ($item in $DPs)
    {
        If ($item -ne $null){$DPArray += "`n`t" + $item}
    }
    Write-Host $($DPArray) -ForegroundColor Cyan
    "$Computer,$DPArray" | Add-Content 'd:\dps.txt'
}

cd C:\


