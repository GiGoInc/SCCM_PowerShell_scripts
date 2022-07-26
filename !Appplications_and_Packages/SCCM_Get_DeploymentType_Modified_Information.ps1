C:
CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:
CD SS1:

$AppName = Get-Content "C:\!Powershell\!SCCM_PS_scripts\Get_DeploymentType_Modified_Information_AppNames.txt"
                $Log = "C:\!Powershell\!SCCM_PS_scripts\Get_DeploymentType_Modified_Information_log.csv"

"App Name,DT Name,LastModifiedBy,DateLastModified,CI_UniqueID,CIVersion,SDMPackageVersion" | Set-Content $Log

ForEach ($AName in $AppName)
{
    $dptypes = Get-CMDeploymentType -ApplicationName "$AName"
    foreach ($dpt in $dptypes){
         $DName = $dpt.LocalizedDisplayName
       $DWhoMod = $dpt.LastModifiedBy
      $DLastMod = $dpt.DateLastModified
         $DCUID = $dpt.CI_UniqueID
         $DCVer = $dpt.CIVersion
          $DSPV = $dpt.SDMPackageVersion

       "$AName,$DName,$DWhoMod,$DLastMod,$DCUID,$DCVer,$DSPV" | Add-Content $Log
        Write-Host "$AName`t$DName"
    }
}