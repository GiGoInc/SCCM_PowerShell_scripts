#$FileName = "E:\!Scripts\Powershell\SCCM_Application_Modification_information_List.txt"
E:

#$FileName = "E:\!Scripts\Powershell\SCCM_Application_Modification_information_List.txt"
$DestFile = "E:\!Scripts\Powershell\SCCM_Application_Modification_information_results_$(get-date -f yyyy-MM-dd).csv"

Write-Output $FileName
Write-Output $DestFile



C:
CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location XX1:
 
#Get-CMApplication | Select-Object LocalizedDisplayName,LastModifiedBy,DateLastModified | Out-File -FilePath $DestFile
#Get-CMApplication -Name "Adobe Flash Player 13 ActiveX" | Select-Object LocalizedDisplayName,LastModifiedBy,DateLastModified | Export-Csv -Encoding ASCII $DestFile

Get-CMApplication | Select-Object LocalizedDisplayName,LastModifiedBy,DateLastModified | Export-Csv -Encoding ASCII $DestFile

#Get-CMApplication -Name "Adobe Flash Player 13 ActiveX" | Format-Table LocalizedDisplayName,LastModifiedBy,DateLastModified

E:
