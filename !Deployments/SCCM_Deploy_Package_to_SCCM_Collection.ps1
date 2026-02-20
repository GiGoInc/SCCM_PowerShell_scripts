cls


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
$Log = "H:\Powershell\!SCCM_PS_scripts\!Deployments\$ADate--Package_Deployments.csv"
'Package Name,Program Name,Collection Name,Comment,Available Date,Expiration Date' | Set-Content $Log







$output = @()

Set-CMPackageDeployment -PackageName $PackName `
                        -StandardProgramName $ProgName `
                        -CollectionName $CollName `
                        -Comment $Comment `
                        -DeploymentAvailableDateTime $AvailDate `
                        -DeploymentExpireDateTime $ExpirDate


