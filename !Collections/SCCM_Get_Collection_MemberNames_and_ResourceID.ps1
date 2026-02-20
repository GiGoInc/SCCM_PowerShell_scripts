cls
Copy-Item $Log "H:\Powershell\!SCCM_PS_scripts\!Collections" -Force

cls
##############################
$SiteCode = "XX1"
$SiteServer = "SERVER.DOMAIN.COM"

$SCCMPaths = 'C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin\ConfigurationManager.psd1', "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"            
$SCCMPaths | % { If (Test-Path "$_") { Import-Module "$_"  -Force }}

if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
New-PSDrive -name $SiteCode -psprovider CMSite  -Root $SiteServer 
}
Set-Location "$($SiteCode):\"


######################################################################################################
######################################################################################################

$ADate = Get-Date -Format "yyyy-MM-dd__hh.mm.ss.tt"

$CollNames  = 'LOGGED OFF - BIOS - DELL LATITUDE 5500', 
'LOGGED OFF - BIOS - DELL LATITUDE 5510', 
'LOGGED OFF - BIOS - DELL LATITUDE 5520', 
'LOGGED OFF - BIOS - DELL OPTIPLEX 7000', 
'LOGGED OFF - BIOS - DELL OPTIPLEX 7010 SFF', 
'LOGGED OFF - BIOS - DELL OPTIPLEX 7020 SFF', 
'LOGGED OFF - BIOS - DELL OPTIPLEX 7070', 
'LOGGED OFF - BIOS - DELL OPTIPLEX 7080', 
'LOGGED OFF - BIOS - DELL OPTIPLEX 7090'


$CollCount = $CollNames.length
$Log = "C:\Temp\SCCM_Get_Collection_MemberNames_and_ResourceID--Results__$ADate.csv"
"Collection,Computer,RID" | Set-Content $Log

$i = 1
ForEach ($CollName in $CollNames)
{
    $Coll = $CollName.replace(' - ','_')
    Write-Host "Checking Collection: $i of $CollCount`t|`t$coll" -foregroundcolor yellow
    $A = Get-CMCollectionMember -CollectionName $CollName | select Name, ResourceID
    ForEach ($Item in $A)
    {
        [string]$Computer = $Item.Name
        [string]$RID = $Item.ResourceID
        "$CollName,$Computer,$RID" | Add-Content $Log
    }
    $i++
}

Copy-Item $Log "H:\Powershell\!SCCM_PS_scripts\!Collections" -Force
