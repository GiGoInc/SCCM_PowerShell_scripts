<#
Object 						Class 								InstanceKey / Property    Example
Application 				SMS_ApplicationLatest 				ModelName                 ScopeId_B524C55D-6E5C-465E-82C3-E2B262C19608/Application_3fe8b1b5-d8d9-4887-b819-a9243a5286c0
Package 					SMS_Package 						PackageID
Configuration Baseline 		SMS_ConfigurationBaselineInfo 		ModelName
Boot Image 					SMS_BootImagePackage 				PackageID
Driver Package 				SMS_DriverPackage 					PackageID
Driver 						SMS_Driver 							ModelName
Collection 					SMS_Collection 						CollectionID              SS1000E8

Query 						SMS_Query 							QueryID
Software Metering Rule 		SMS_MeteredProductRule 				SecurityKey
Configuration Item 			SMS_ConfigurationItemLatest 		ModelName
Operating System Image 		SMS_OperatingSystemInstallPackage 	PackageID
Operating System Package 	SMS_ImagePackage 					PackageID
User State Migration 		SMS_StateMigration 					MigrationID
Task Sequence 				SMS_TaskSequencePackage 			PackageID
Software Update 			SMS_SoftwareUpdate 					ModelName
#>

cls
. 'C:\Scripts\!Modules\Get-ObjectLocation.ps1'
. 'C:\Scripts\!Modules\GoGoSCCM_Module_client.ps1'

Function GenerateApplications ($Log1)
{
    If (Test-Path $Log1){Remove-Item $Log1}
    Write-Host "Generating $Log1, this should take about four minutes...." -ForegroundColor Cyan
    Write-Host "`tStarting: $(Get-Date)" -ForegroundColor Green
    Get-CMApplication | select LocalizedDisplayName,ModelName,SmsProviderObjectPath |  ForEach {$_.LocalizedDisplayName,$_.ModelName,$_.SmsProviderObjectPath -join ',' | Add-Content $Log1}
    Write-Host "`tFinished: $(Get-Date)" -ForegroundColor Red
}

Function GenerateCollections ($Log1)
{
    If (Test-Path $Log1){Remove-Item $Log1}
    Write-Host "Generating $Log1, this should take about three minutes...." -ForegroundColor Cyan
    Write-Host "`tStarting: $(Get-Date)" -ForegroundColor Green
    Get-CMCollection | select Name,CollectionID,SmsProviderObjectPath |  ForEach {$_.Name,$_.CollectionID,$_.SmsProviderObjectPath -join ',' | Add-Content $Log1}
    Write-Host "`tFinished: $(Get-Date)" -ForegroundColor Red
}

Function GenerateDrivers ($Log1)
{
    If (Test-Path $Log1){Remove-Item $Log1}
    Write-Host "Generating $Log1, this should take less than a minute...." -ForegroundColor Cyan
    Write-Host "`tStarting: $(Get-Date)" -ForegroundColor Green
    Get-CMDriver | select LocalizedDisplayName,ModelName,SmsProviderObjectPath |  ForEach {$_.LocalizedDisplayName,$_.ModelName,$_.SmsProviderObjectPath -join ',' | Add-Content $Log1}
    Write-Host "`tFinished: $(Get-Date)" -ForegroundColor Red
}

Function GeneratePackages ($Log1)
{
    If (Test-Path $Log1){Remove-Item $Log1}
    Write-Host "Generating $Log1, this should take less than a minute...." -ForegroundColor Cyan
    Write-Host "`tStarting: $(Get-Date)" -ForegroundColor Green
    Get-CMPackage | select Name,PackageID,SmsProviderObjectPath |  ForEach {$_.Name,$_.PackageID,$_.SmsProviderObjectPath -join ',' | Add-Content $Log1}
    Write-Host "`tFinished: $(Get-Date)" -ForegroundColor Red
}

Function GenerateDriverPackages ($Log1)
{
    If (Test-Path $Log1){Remove-Item $Log1}
    Write-Host "Generating $Log1, this should take less than a minute...." -ForegroundColor Cyan
    Write-Host "`tStarting: $(Get-Date)" -ForegroundColor Green
    Get-CMDriverPackage | select Name,PackageID,SmsProviderObjectPath |  ForEach {$_.Name,$_.PackageID,$_.SmsProviderObjectPath -join ',' | Add-Content $Log1}
    Write-Host "`tFinished: $(Get-Date)" -ForegroundColor Red
}

<#
Function GenerateBootImages__Does_NOT_Work ($Log1)
{
    If (Test-Path $Log1){Remove-Item $Log1}
    Write-Host "Generating $Log1, this should take about a minute...." -ForegroundColor Cyan
    Write-Host "`tStarting: $(Get-Date)" -ForegroundColor Green
    Get-CMBootImage | select Name,PackageID,SmsProviderObjectPath |  ForEach {$_.Name,$_.PackageID,$_.SmsProviderObjectPath -join ',' | Add-Content $Log1}
    Write-Host "`tFinished: $(Get-Date)" -ForegroundColor Red
}
#>



Function CheckApplications ($Log1,$Log2)
{
	If (!(Test-Path $Log1))
	{
		Write-Host ""
		Write-Host "Hey, dum dum it doesn't look like the file " -NoNewline -ForegroundColor Cyan
		Write-host "$Log1 " -ForegroundColor Green -NoNewline
		Write-Host "exists..." -ForegroundColor Cyan
		Write-Host ""
		Write-Host "You need to run the Generate*** function first...you know the one..." -ForegroundColor Green
		Write-Host ""
		Write-Host "Action cancelled." -ForegroundColor Red
		Read-Host -Prompt 'Press Enter to exit...'
		Exit
	}

	# Checking $Log1
    Write-Host "Generating $Log2, this should take less than a minute...." -ForegroundColor Cyan
	'Name,Folder Location' | Set-Content $Log2
	Write-Host "`tStarting: $(Get-Date)" -ForegroundColor Green
	$X = Get-Content $Log1
	ForEach ($item in $X)
	{
		$Name = $item.split(',')[0]
		$X = $item.split(',')[1]
		$y = $item.split(',')[2].split('.')[0]
		Write-Host "Checking $X..."
		$Location = Get-ObjectLocation -InstanceKey $X
		"$Name,$Location" | Add-Content $Log2
	}
	Write-Host "`tFinished: $(Get-Date)" -ForegroundColor Red
}

Function CheckCollections ($Log1,$Log2)
{
	If (!(Test-Path $Log1))
	{
		Write-Host ""
		Write-Host "Hey, dum dum it doesn't look like the file " -NoNewline -ForegroundColor Cyan
		Write-host "$Log1 " -ForegroundColor Green -NoNewline
		Write-Host "exists..." -ForegroundColor Cyan
		Write-Host ""
		Write-Host "You need to run the Generate*** function first...you know the one..." -ForegroundColor Green
		Write-Host ""
		Write-Host "Action cancelled." -ForegroundColor Red
		Read-Host -Prompt 'Press Enter to exit...'
		Exit
	}

	# Checking $Log1
    Write-Host "Generating $Log2, this should take less than a minute...." -ForegroundColor Cyan
	'Name,Folder Location' | Set-Content $Log2
	Write-Host "`tStarting: $(Get-Date)" -ForegroundColor Green
	$X = Get-Content $Log1
	ForEach ($item in $X)
	{
		$Name = $item.split(',')[0]
		$X = $item.split(',')[1]
		$y = $item.split(',')[2].split('.')[0]
		Write-Host "Checking $X..."
		$Location = Get-ObjectLocation -InstanceKey $X
		"$Name,$Location" | Add-Content $Log2
	}
	Write-Host "`tFinished: $(Get-Date)" -ForegroundColor Red
}

Function CheckDrivers ($Log1,$Log2)
{
	If (!(Test-Path $Log1))
	{
		Write-Host ""
		Write-Host "Hey, dum dum it doesn't look like the file " -NoNewline -ForegroundColor Cyan
		Write-host "$Log1 " -ForegroundColor Green -NoNewline
		Write-Host "exists..." -ForegroundColor Cyan
		Write-Host ""
		Write-Host "You need to run the Generate*** function first...you know the one..." -ForegroundColor Green
		Write-Host ""
		Write-Host "Action cancelled." -ForegroundColor Red
		Read-Host -Prompt 'Press Enter to exit...'
		Exit
	}

	# Checking $Log1
    Write-Host "Generating $Log2, this should take less than a minute...." -ForegroundColor Cyan
	'Name,Folder Location' | Set-Content $Log2
	Write-Host "`tStarting: $(Get-Date)" -ForegroundColor Green
	$X = Get-Content $Log1
	ForEach ($item in $X)
	{
		$Name = $item.split(',')[0]
		$X = $item.split(',')[1]
		$y = $item.split(',')[2].split('.')[0]
		Write-Host "Checking $X..."
		$Location = Get-ObjectLocation -InstanceKey $X
		"$Name,$Location" | Add-Content $Log2
	}
	Write-Host "`tFinished: $(Get-Date)" -ForegroundColor Red
}

Function CheckPackages ($Log1,$Log2)
{
	If (!(Test-Path $Log1))
	{
		Write-Host ""
		Write-Host "Hey, dum dum it doesn't look like the file " -NoNewline -ForegroundColor Cyan
		Write-host "$Log1 " -ForegroundColor Green -NoNewline
		Write-Host "exists..." -ForegroundColor Cyan
		Write-Host ""
		Write-Host "You need to run the Generate*** function first...you know the one..." -ForegroundColor Green
		Write-Host ""
		Write-Host "Action cancelled." -ForegroundColor Red
		Read-Host -Prompt 'Press Enter to exit...'
		Exit
	}

	# Checking $Log1
    Write-Host "Generating $Log2, this should take less than a minute...." -ForegroundColor Cyan
	'Name,Folder Location' | Set-Content $Log2
	Write-Host "`tStarting: $(Get-Date)" -ForegroundColor Green
	$X = Get-Content $Log1
	ForEach ($item in $X)
	{
		$Name = $item.split(',')[0]
		$X = $item.split(',')[1]
		$y = $item.split(',')[2].split('.')[0]
		Write-Host "Checking $X..."
		$Location = Get-ObjectLocation -InstanceKey $X
		"$Name,$Location" | Add-Content $Log2
	}
	Write-Host "`tFinished: $(Get-Date)" -ForegroundColor Red
}

Function CheckDriverPackages ($Log1,$Log2)
{
	If (!(Test-Path $Log1))
	{
		Write-Host ""
		Write-Host "Hey, dum dum it doesn't look like the file " -NoNewline -ForegroundColor Cyan
		Write-host "$Log1 " -ForegroundColor Green -NoNewline
		Write-Host "exists..." -ForegroundColor Cyan
		Write-Host ""
		Write-Host "You need to run the Generate*** function first...you know the one..." -ForegroundColor Green
		Write-Host ""
		Write-Host "Action cancelled." -ForegroundColor Red
		Read-Host -Prompt 'Press Enter to exit...'
		Exit
	}

	# Checking $Log1
    Write-Host "Generating $Log2, this should take less than a minute...." -ForegroundColor Cyan
	'Name,Folder Location' | Set-Content $Log2
	Write-Host "`tStarting: $(Get-Date)" -ForegroundColor Green
	$X = Get-Content $Log1
	ForEach ($item in $X)
	{
		$Name = $item.split(',')[0]
		$X = $item.split(',')[1]
		$y = $item.split(',')[2].split('.')[0]
		Write-Host "Checking $X..."
		$Location = Get-ObjectLocation -InstanceKey $X
		"$Name,$Location" | Add-Content $Log2
	}
	Write-Host "`tFinished: $(Get-Date)" -ForegroundColor Red
}

<#
Function CheckBootImages__Does_NOT_Work ($Log1,$Log2)
{
    If (!(Test-Path $Log1))
    {
        Write-Host "Generating $Log1, this should take about a minute...." -ForegroundColor Cyan
        Write-Host "`tStarting: $(Get-Date)" -ForegroundColor Green
        Get-CMBootImage | select Name,PackageID,SmsProviderObjectPath |  ForEach {$_.Name,$_.PackageID,$_.SmsProviderObjectPath -join ',' | Add-Content $Log1}
        Write-Host "`tFinished: $(Get-Date)" -ForegroundColor Red
    }
    Else
    {
        Write-Host "Found $Log1, using it...."
    }

	# Checking $Log1
    Write-Host "Generating $Log2, this should take less than a minute...." -ForegroundColor Cyan
	'Name,Folder Location' | Set-Content $Log2
	Write-Host "`tStarting: $(Get-Date)" -ForegroundColor Green
	$X = Get-Content $Log1
	ForEach ($item in $X)
	{
		$Name = $item.split(',')[0]
		$X = $item.split(',')[1]
		$y = $item.split(',')[2].split('.')[0]
		Write-Host "Checking $X..."
		$Location = Get-ObjectLocation -InstanceKey $X
		"$Name,$Location" | Add-Content $Log2
	}
	Write-Host "`tFinished: $(Get-Date)" -ForegroundColor Red
}
#>




<#
# Boot Images by PackageID
    $Log1 = 'D:\Powershell\!SCCM_PS_scripts\Client_Execution_Tools\InstanceKeys--BootImages.txt'
    $Log2 = 'D:\Powershell\!SCCM_PS_scripts\Client_Execution_Tools\Folder_Parents---BootImages.csv'
    GenerateBootImages -Log1 $Log1
    # CheckBootImages -Log1 $Log1 -Log2 $Log2
#>

# Applications by Name
    $Log1 = 'D:\Powershell\!SCCM_PS_scripts\Client_Execution_Tools\InstanceKeys--Application.txt'
    $Log2 = 'D:\Powershell\!SCCM_PS_scripts\Client_Execution_Tools\Folder_Parents---Applications.csv'
    GenerateApplications -Log1 $Log1
    # CheckApplications -Log1 $Log1 -Log2 $Log2

# Collections by CollectionID
    $Log1 = 'D:\Powershell\!SCCM_PS_scripts\Client_Execution_Tools\InstanceKeys--Collection.txt'
    $Log2 = 'D:\Powershell\!SCCM_PS_scripts\Client_Execution_Tools\Deployment_Collection_Parents.csv'
    GenerateCollections -Log1 $Log1
    # CheckCollections -Log1 $Log1 -Log2 $Log2

# Drivers by Modelname
    $Log1 = 'D:\Powershell\!SCCM_PS_scripts\Client_Execution_Tools\InstanceKeys--Driver.txt'
    $Log2 = 'D:\Powershell\!SCCM_PS_scripts\Client_Execution_Tools\Folder_Parents---Drivers.csv'
    GenerateDrivers -Log1 $Log1
    # CheckDrivers -Log1 $Log1 -Log2 $Log2

# Packages by PackageID
    $Log1 = 'D:\Powershell\!SCCM_PS_scripts\Client_Execution_Tools\InstanceKeys--Packages.txt'
    $Log2 = 'D:\Powershell\!SCCM_PS_scripts\Client_Execution_Tools\Folder_Parents---Packages.csv'
    GeneratePackages -Log1 $Log1
    # CheckPackages -Log1 $Log1 -Log2 $Log2

# DriverPackages by PackageID
    $Log1 = 'D:\Powershell\!SCCM_PS_scripts\Client_Execution_Tools\InstanceKeys--DriverPackages.txt'
    $Log2 = 'D:\Powershell\!SCCM_PS_scripts\Client_Execution_Tools\Folder_Parents---DriverPackages.csv'
    GenerateDriverPackages -Log1 $Log1
    # CheckDriverPackages -Log1 $Log1 -Log2 $Log2

Write-Host ''
Write-Host "Completed script: $(Get-Date)" -ForegroundColor Cyan
Read-Host -Prompt 'Press Enter to exit...'
Exit