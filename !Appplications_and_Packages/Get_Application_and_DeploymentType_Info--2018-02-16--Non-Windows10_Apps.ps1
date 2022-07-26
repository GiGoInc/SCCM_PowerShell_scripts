$i = 1
$Files = Get-ChildItem 'D:\Powershell\!SCCM_PS_scripts\!Appplications_and_Packages\Get_Application_and_DeploymentType_Info' -Recurse
 $Null | Set-Content 'D:\Powershell\!SCCM_PS_scripts\!Appplications_and_Packages\Get_Application_and_DeploymentType_Info--Count.txt'


$total = $Files.Count
"Total files: $total"
ForEach ($File in $Files)
{
    $Content = Get-Content $File.FullName
    if ($Content -match 'All Windows 10'){$i++}Else
    {
    $($File.Name)
    $($File.Name).replace('Application--','')
    $FileName = $($File.Name).replace('Application--','')
    $FileName = $FileName.replace('--Get-CMResults.txt','')
    $FileName | Add-Content 'D:\Powershell\!SCCM_PS_scripts\!Appplications_and_Packages\Get_Application_and_DeploymentType_Info--Non-Windows10_Apps.txt'}
}
"$i of $total"