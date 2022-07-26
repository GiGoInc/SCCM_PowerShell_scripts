#SCCM Module
C:
CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:
CD SS1:



# Variables
#Get current working paths
$CurrentDirectory = split-path $MyInvocation.MyCommand.Path
$ScriptName = $MyInvocation.MyCommand.Name
$ADate = Get-Date -Format "yyyy-MM-dd__hh.mm.ss.tt"
$DestFile = "D:\!Powershell\!SCCM_PS_scripts\SCCM - Collection Information - $ADate.csv"

If (Test-Path -Path $DestFile ){Remove-Item -Path $DestFile -Force}


"Name,CollectionID,MemberCount,LimitToCollectionName,LimitToCollectionID,ServiceWindowsCount,Comment" -join "," | Add-Content $DestFile


$a = Get-CMCollection -Name * | Select-Object Name,CollectionID,MemberCount,LimitToCollectionName,LimitToCollectionID,ServiceWindowsCount,Comment

ForEach ($B in $A){
  $CollName = $B.Name
    $CollID = $B.CollectionID
  $MemCount = $B.MemberCount
$ToCollName = $B.LimitToCollectionName
  $ToCollID = $B.LimitToCollectionID
       $SwC = $B.ServiceWindowsCount
   $Comment = $B.Comment
 
Write-Output $CollName $MemCount $CollID $ToCollName $ToCollID $SwC $Comment
"$CollName,$CollID,$MemCount,$ToCollName,$ToCollID,$SwC,$Comment" -join "," | Add-Content $DestFile
}