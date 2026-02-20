cls
} 
    Remove-CMDeployment -DeploymentId "$DID" -ApplicationName "$App" -Force    
cls
} 
    Remove-CMDeployment -DeploymentId "$DID" -ApplicationName "$App" -Force    
cls
C:
CD 'C:\Program Files (x86)\ConfigMgr Console\bin'
Import-Module ".\ConfigurationManager.psd1"
Start-Sleep -Milliseconds 500
## Connect to ConfigMgr Site 
Set-Location XX1:
CD XX1:
############################################################
############################################################
$ADate = Get-Date -Format "yyyy_MM-dd_hh-mm-ss"
$Log = "H:\Powershell\!SCCM_PS_scripts\!Deployments\$ADate--Removed_Deployments.csv"
'Deployment ID,Application Name' | Set-Content $Log

$Deployments = '{6C0BF144-1420-45B5-BE6F-33B617F9DCA3},Dell BIOS Optiplex_7040 _1.24.0', 
               '{296430A6-E6AA-4F38-AC9B-32C68FCD6B72},Dell BIOS Latitude_5580_1.32.2', 
               '{5FA255D3-5732-4B03-B223-27A2EDAEA7D7},Dell BIOS Latitude_5500_1.25.0', 
               '{436DBEC3-7E32-43B6-A973-91C07CA04AFE},Dell BIOS Latitude_5510_1.23.1', 
               '{9974E44E-8089-40B9-8872-1E03F602E0E3},Dell BIOS Latitude_5520 - 1.32.1', 
               '{20ED4645-0418-48FB-B332-A4ABBCBB3837},Dell BIOS Latitude_5530_1.18.0', 
               '{19004363-5B1B-4E6F-BDAF-BC3317FDC23C},Dell BIOS Latitude_5540_1.9.0', 
               '{01B33D58-B9DC-4E5E-A466-84E3BD36FCA3},Dell BIOS Latitude_7400 - 1.28.0', 
               '{BCF5240D-15E9-4B03-8D6D-42EB7D92A2D2},Dell BIOS Latitude_7420 1.30.1', 
               '{6941AF45-719F-464F-AA84-81B086ABF128},Dell BIOS Latitude_7430_1.18.0', 
               '{F966564F-C1C4-4323-A9D6-192.FE92A63A},Dell BIOS Precision 7740_1.29.0', 
               '{D3BD848B-616C-46E0-9BAF-73908F0735F4},Dell BIOS Optiplex_7000_1.18.1', 
               '{EA98CE18-A20E-4419-B6C4-DAE5031EE716},Dell BIOS Optiplex_7090 1.19.0', 
               '{B50C55C0-FE80-4452-BD98-1C05F4A11925},Dell BIOS Optiplex_7070 - 1.22.0', 
               '{0587DBBF-39F7-4F1F-963A-4D636DEFEF66},Dell BIOS Optiplex_7050_1.24.0'


$Deployments | % {

    $DID = $_.split(',')[0] 
    $App = $_.split(',')[1] 
    "$DID,$App" | Add-Content $Log
    Remove-CMDeployment -DeploymentId "$DID" -ApplicationName "$App" -Force    
} 
