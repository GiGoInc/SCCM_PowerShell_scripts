cls
}
    '"' + $CollName + '","' + $CollID + '","' + $MemCount + '","' + $ToCollName + '","' + $ToCollID + '","' + $SwC + '","' + $Comment + '"' | Add-Content $DestFile
cls
##############################
$SiteCode = "XX1"
$SiteServer = "SERVER.DOMAIN.COM"
$SCCMPaths = 'C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin\ConfigurationManager.psd1', "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"            
$SCCMPaths | % { If (Test-Path "$_") { Import-Module "$_"  -Force }}
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
New-PSDrive -name $SiteCode -psprovider CMSite  -Root $SiteServer }
Set-Location "$($SiteCode):"


# Variables
#Get current working paths
$CurrentDirectory = split-path $MyInvocation.MyCommand.Path
$ScriptName = $MyInvocation.MyCommand.Name
$ADate = Get-Date -Format "yyyy-MM-dd__hh.mm.ss.tt"
$DestFile = "D:\Powershell\!SCCM_PS_scripts\!Collections\SCCM_Collection_Information__$ADate.csv"

If (Test-Path -Path $DestFile ){Remove-Item -Path $DestFile -Force}


"Name,CollectionID,MemberCount,LimitToCollectionName,LimitToCollectionID,ServiceWindowsCount,Comment" -join "," | Add-Content $DestFile


$a = Get-CMCollection -Name * | Select-Object Name,CollectionID,MemberCount,LimitToCollectionName,LimitToCollectionID,ServiceWindowsCount,Comment
$total = $A.count

Write-Host "Found $total collections..."
ForEach ($B in $A)
{
      $CollName = $B.Name
        $CollID = $B.CollectionID
      $MemCount = $B.MemberCount
    $ToCollName = $B.LimitToCollectionName
      $ToCollID = $B.LimitToCollectionID
           $SwC = $B.ServiceWindowsCount
       $Comment = $B.Comment
 
    #Write-Host $CollName $MemCount $CollID $ToCollName $ToCollID $SwC $Comment
    '"' + $CollName + '","' + $CollID + '","' + $MemCount + '","' + $ToCollName + '","' + $ToCollID + '","' + $SwC + '","' + $Comment + '"' | Add-Content $DestFile
}
