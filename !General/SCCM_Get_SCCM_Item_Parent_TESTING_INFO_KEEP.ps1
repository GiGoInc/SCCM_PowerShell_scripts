<#
Exit
Read-Host -Prompt 'Press Enter to exit...'
<#
Exit
Read-Host -Prompt 'Press Enter to exit...'
<#
Object 						Class 								InstanceKey / Property    Example
Application 				SMS_ApplicationLatest 				ModelName                 ScopeId_B524C55D-6E5C-465E-82C3-E2B262C19608/Application_3fe8b1b5-d8d9-4887-b819-a9243a5286c0
Package 					SMS_Package 						PackageID
Configuration Baseline 		SMS_ConfigurationBaselineInfo 		ModelName
Boot Image 					SMS_BootImagePackage 				PackageID
Driver Package 				SMS_DriverPackage 					PackageID
Driver 						SMS_Driver 							ModelName
Collection 					SMS_Collection 						CollectionID  
#>  
  
  
  Get-CMApplication -Name 'ExtraHIPSUninstall' | Select LocalizedDisplayName,ModelName,SmsProviderObjectPath | ft
   Get-CMCollection -Name 'ITSD' | Select Name,CollectionID,SmsProviderObjectPath | ft



      Get-CMPackage -Name 'USMT for Windows 10' | Select Name,PackageID,SmsProviderObjectPath | ft
Get-CMDriverPackage -Name 'Win10 - Dell Latitude E5540 - A02' | Select Name,PackageID,SmsProviderObjectPath | ft
    Get-CMBootImage -Name 'WinPE x64 - 6.3' | Select Name,PackageID,SmsProviderObjectPath | ft

       Get-CMDriver -Name 'Win10 - Dell Latitude E5540 - A02' | Select LocalizedDisplayName,ModelName,SmsProviderObjectPath | ft

# Application 
    If ($Y -eq 'SMS_Application'){$SPOP = 'SMS_ApplicationLatest'}
SELECT ocn.* FROM SMS_ObjectContainerNode AS ocn JOIN SMS_ObjectContainerItem AS oci ON ocn.ContainerNodeID=oci.ContainerNodeID WHERE oci.InstanceKey='ScopeId_B524C55D-6E5C-465E-82C3-E2B262C19608/Application_f8ce801f-def0-43aa-b60e-e3c063132bdf' and oci.ObjectTypeName='SMS_ApplicationLatest'

# Boot Image 
    If ($Y -eq 'SMS_BootImagePackage'){$SPOP = 'SMS_Collection_Device'}
SELECT ocn.* FROM SMS_ObjectContainerNode AS ocn JOIN SMS_ObjectContainerItem AS oci ON ocn.ContainerNodeID=oci.ContainerNodeID WHERE oci.InstanceKey='XX1000AC' and oci.ObjectTypeName='SMS_BootImagePackage'


# Collection 
    If ($Y -eq 'SMS_Collection'){$SPOP = 'SMS_Collection_Device'}
SELECT ocn.* FROM SMS_ObjectContainerNode AS ocn JOIN SMS_ObjectContainerItem AS oci ON ocn.ContainerNodeID=oci.ContainerNodeID WHERE oci.InstanceKey='XX10072D' and oci.ObjectTypeName='SMS_Collection_Device'


# Package 
    If ($Y -eq 'SMS_Package'){$SPOP = 'SMS_Package'}
SELECT ocn.* FROM SMS_ObjectContainerNode AS ocn JOIN SMS_ObjectContainerItem AS oci ON ocn.ContainerNodeID=oci.ContainerNodeID WHERE oci.InstanceKey='XX10037E' and oci.ObjectTypeName='SMS_Package'

# DriverPackage 
    If ($Y -eq 'SMS_DriverPackage'){$SPOP = 'SMS_Collection_Device'}
SELECT ocn.* FROM SMS_ObjectContainerNode AS ocn JOIN SMS_ObjectContainerItem AS oci ON ocn.ContainerNodeID=oci.ContainerNodeID WHERE oci.InstanceKey='XX1003C1' and oci.ObjectTypeName='SMS_DriverPackage'



# Driver 
    If ($Y -eq 'SMS_Package'){$SPOP = 'SMS_Collection_Device'}
SELECT ocn.* FROM SMS_ObjectContainerNode AS ocn JOIN SMS_ObjectContainerItem AS oci ON ocn.ContainerNodeID=oci.ContainerNodeID WHERE oci.InstanceKey='XX1003C1' and oci.ObjectTypeName='SMS_Driver'

SELECT ocn.* FROM SMS_ObjectContainerNode AS ocn JOIN SMS_ObjectContainerItem AS oci ON ocn.ContainerNodeID=oci.ContainerNodeID WHERE oci.InstanceKey='XX1000AC'

SELECT oci.* FROM SMS_ObjectContainerNode WHERE oci.InstanceKey='XX1000AC'

SELECT oci.* FROM SMS_ObjectContainerNode WHERE oci.InstanceKey='XX1000AC'

SELECT su.* From SMS_SoftwareUpdate AS su Where su.LocalizedDisplayName='Adobe Acrobat XI (11.0.19)'











Get-ObjectLocation -InstanceKey $X -SPOP $Y



Function CheckDriverPackages ($Log1,$Log2)
{
    Write-Host "Generating $Log2, this should take less than a minute...." -ForegroundColor Cyan
	'Name,Folder Location' | Set-Content $Log2
	Write-Host "`tStarting: $(Get-Date)" -ForegroundColor Green
	$X = Get-Content $Log1
	ForEach ($item in $X)
	{
		$Name = $item.split(',')[0]
		$X = $item.split(',')[1]
		$Y = $item.split(',')[2].split('.')[0]
        If ($Y -eq 'SMS_Collection'){$SPOP = 'SMS_Collection_Device'}
        If ($Y -eq 'SMS_Application'){$SPOP = 'SMS_ApplicationLatest'}
        If ($Y -eq 'SMS_Package'){$SPOP = 'SMS_Package'}
        If ($Y -eq 'SMS_DriverPackage'){$SPOP = 'SMS_Collection_Device'}
        If ($Y -eq 'SMS_BootImagePackage'){$SPOP = 'SMS_Collection_Device'}
        
		Write-Host "Checking $X..."
		$Location = Get-ObjectLocation -InstanceKey $X -SPOP $Y
		"$Name,$Location" | Add-Content $Log2
	}
	Write-Host "`tFinished: $(Get-Date)" -ForegroundColor Red
}

# DriverPackages by PackageID
    $Log1 = 'C:\Temp\InstanceKeys--DriverPackages.txt'
    $Log2 = 'C:\Temp\Folder_Parents---DriverPackages.csv'
    #GenerateDriverPackages -Log1 $Log1
    CheckDriverPackages -Log1 $Log1 -Log2 $Log2

Write-Host ''
Write-Host "Completed script: $(Get-Date)" -ForegroundColor Cyan
Read-Host -Prompt 'Press Enter to exit...'
Exit
