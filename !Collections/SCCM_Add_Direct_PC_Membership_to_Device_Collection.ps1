$SiteCode = "XX1"
    Write-Host "`nScript ran: $min minutes and $sec seconds." -ForegroundColor Cyan
    $sec = $t.seconds
$SiteCode = "XX1"
$SiteServer = "SERVER.DOMAIN.COM"
$SCCMPaths = 'C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin\ConfigurationManager.psd1', "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"            
$SCCMPaths | % { If (Test-Path "$_") { Import-Module "$_"  -Force }}
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
New-PSDrive -name $SiteCode -psprovider CMSite  -Root $SiteServer }
Set-Location "$($SiteCode):"
######################################################################################################
# List contains "Collection ID + ; + ComputerName"
######################################################################################################

[string[]]$ComputerList = Get-Content -Path "D:\random_workstation_collections.txt"


#################################################################################################################################
# Get Match list of Computer to ResourceID
#################################################################################################################################
$ADateS = Get-Date
Write-Host "Getting ResourceID from PC Names..." -NoNewline -ForegroundColor Yellow
$SQL_Query = "Select Name0,ResourceID From v_R_System"
##########################################################################
      $SQL_DB = 'CM_XX1'
  $SQL_Server = 'SERVER'
$SQL_Instance = 'SERVER'
##########################################################################
$SQL_Check = Invoke-Sqlcmd -ConnectionTimeout 60 `
        -Database $SQL_DB  `
        -HostName $SQL_Server  `
        -Query $SQL_Query `
        -QueryTimeout 600 `
        -ServerInstance $SQL_Instance `
        -Encrypt Optional `
        -TrustServerCertificate
##########################################################################
Write-Host "done." -ForegroundColor Green
# FINALLY - Write Time
    $ADateE = Get-Date
    $t = NEW-TIMESPAN –Start $ADateS –End $ADateE | select Minutes,Seconds
    $min = $t.Minutes
    $sec = $t.seconds
    Write-Host "`nScript ran: $min minutes and $sec seconds." -ForegroundColor Cyan

$Output = @()
$ComputerList | % {
$Group = $_.split(';')[0]
$Computer = $_.split(';')[1]
    $SQL_Check | % {
    $Record = $_.Name0
    $ID = $_.ResourceID
    If ($Computer -eq $record) { $Output += $Group + ";" + $Computer + ";" + $ID }

}}

#################################################################################################################################
# Use Computer to ResourceID to add systems to Collection(s)
#################################################################################################################################
$ADateS = Get-Date
$i = 1
Write-Host "Adding computers to collection(s)..." -NoNewline -ForegroundColor Yellow
$total = $computerlist.count
ForEach ($Item in $Output)
{
           $Group = $Item.Split(';')[0]
    $ComputerName = $Item.Split(';')[1]
      $ResourceID = $Item.Split(';')[2]

        $DeploymentHash = @{
                            CollectionId = $CollID
                            ResourceID = $ResourceID
                            }
        "$i of $total`t$collID -- $ComputerName"
        Add-CMDeviceCollectionDirectMembershipRule @DeploymentHash
        $i++
}
Write-Host "Done..."
# FINALLY - Write Time
    $ADateE = Get-Date
    $t = NEW-TIMESPAN –Start $ADateS –End $ADateE | select Minutes,Seconds
    $min = $t.Minutes
    $sec = $t.seconds
    Write-Host "`nScript ran: $min minutes and $sec seconds." -ForegroundColor Cyan
