## Import ConfigMgr PS Module 
}
    } 
## Import ConfigMgr PS Module 
cls
C:
CD 'C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Start-Sleep -Milliseconds 500
## Connect to ConfigMgr Site 
Set-Location XX1:
CD XX1:
############################################################
 Write-Host "#######################################################################" -f Green 
Write-Host "##        Matts ConfigMgr 2012 SP1 Application Source Modifier       ##" -f Green 
Write-Host "##                blogs.technet.com/b/ConfigMgrDogs                  ##" -f Green 
Write-Host "##                                                                   ##" -f Green 
Write-Host "##                                                                   ##" -f Green 
Write-Host "##  Please ensure your package source content has been moved to the  ##" -f Green 
Write-Host "##          new location *prior* to running this script              ##" -f Green 
Write-Host "##                                                                   ##" -f Green 
Write-Host "#######################################################################" -f Green 
Start-Sleep -s 2
Write-Host "" 
Write-Host "" 
############################################################
 
## Set old Source share 
    $OriginalSource = "\\cmcontent\Packages"
 $DestinationSource = "\\SERVER\dfs$\MCM\Packages"

 
$ApplicationNames = 'Dell Bios Latitude 7400 2-in-1_1.25.0',
'Dell BIOS Latitude_5500_1.25.0',
'Dell BIOS Latitude_5510_1.23.1',
'Dell BIOS Latitude_5520 - 1.32.1',
'Dell BIOS Latitude_5530_1.18.0',
'Dell BIOS Latitude_5540_1.9.0',
'Dell BIOS Latitude_5580_1.32.2',
'Dell BIOS Latitude_7390_1.34.0',
'Dell BIOS Latitude_7400 - 1.28.0',
'Dell BIOS Latitude_7410_1.25.1',
'Dell BIOS Latitude_7420 1.30.1',
'Dell BIOS Latitude_7430_1.18.0',
'Dell BIOS Optiplex_7000_1.18.1',
'Dell BIOS Optiplex_7010_1.8.0',
'Dell BIOS Optiplex_7040 _1.24.0',
'Dell BIOS Optiplex_7050_1.24.0',
'Dell BIOS Optiplex_7070 - 1.22.0',
'Dell BIOS OptiPlex_7080_1.23.0',
'Dell BIOS Optiplex_7090 1.19.0',
'Dell BIOS Precision 7740_1.29.0'

$Minutes = '3'
$Seconds = ([int]$minutes * 60)
ForEach ($ApplicationName in $ApplicationNames)
{ 
    $DeploymentTypeName = Get-CMDeploymentType -ApplicationName $ApplicationName
    ForEach($DT in $DeploymentTypeName)
    { 
        $DTSDMPackageXLM = $DT.SDMPackageXML 
        $DTSDMPackageXLM = [XML]$DTSDMPackageXLM 
        
        ## Get Path for Apps with multiple DTs 
        $DTCleanPath = $DTSDMPackageXLM.AppMgmtDigest.DeploymentType.Installer.Contents.Content.Location[0]
   
        ## Get Path for Apps with single DT 
        If ($DTCleanPath -eq "\") 
        { 
            $DTCleanPath = $DTSDMPackageXLM.AppMgmtDigest.DeploymentType.Installer.Contents.Content.Location
        } 
        
        $DTCleanPath = $DTCleanPath               
        $DirectoryPath = $DTCleanPath -replace [regex]::Escape($OriginalSource), "$DestinationSource"
    
        If ($DirectoryPath -eq $DTCleanPath)
        {
            Write-Host "No Change:" -nonewline
            Write-Host "$ApplicationName" -f green
        }
        Else
        {
            ## Modify DT path 
            
            Write-Host "Application " -f White -NoNewline; 
            Write-Host $ApplicationName -F Red -NoNewline; 
            Write-Host " with Deployment Type " -f White -NoNewline; 
            Write-Host $DT.LocalizedDisplayName -f Cyan -NoNewline; 
             
            Set-CMMsiDeploymentType –ApplicationName "$ApplicationName" –DeploymentTypeName $DT.LocalizedDisplayName –ContentLocation "$DirectoryPath" 
            
            Write-Host " has been modified to " -f White -NoNewline; 
            Write-Host $DirectoryPath -f Yellow
            Write-Host "Waiting $Minutes minutes..."
            Start-Sleep -Seconds $Seconds
        }
    } 
}
