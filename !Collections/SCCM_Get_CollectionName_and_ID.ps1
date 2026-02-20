CD "D:\!PowerShell"
# Get-CMCollection -Name * | Select-Object Name,CollectionID | Format-Table

CD "D:\!PowerShell"

#Get current working paths
$CurrentDirectory = split-path $MyInvocation.MyCommand.Path
$ScriptName = $MyInvocation.MyCommand.Name

$ADate = Get-Date -Format "yyyy_MM-dd_hh-mm-ss"

#GoGoSCCMModule
C:
CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location XX1:
CD XX1:

Set-CMQueryResultMaximum -Maximum 90000

$A = Get-CMCollection -Name * | Select-Object Name,CollectionID
$CollID = $A.CollectionID
$CollName = $A.Name
"$CollName,$CollID" -join ',' | Add-Content "$CurrentDirectory \SCCM_Collections_$ADate.txt"



# Get-CMCollection -Name * | Select-Object Name,CollectionID | Format-Table
