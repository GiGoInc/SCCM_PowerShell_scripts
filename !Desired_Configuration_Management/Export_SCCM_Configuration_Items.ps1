<#
Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
$Sec = $Span.Seconds
<#
.Synopsis
   Exports all scripts (discovery and remediation) used in all SCCM Compliance Setting Configuration Items
.DESCRIPTION
   This script connects to the SCCM database to retrieve all Compliance Setting Configuration Items. It then processes each item looking for
   discovery and remediation scripts for the current (latest) version. It will export any script found into a directory structure.
.NOTES
    Requirements - 'db_datareader' permission to the SCCM SQL database with the account running this script.
    Parameters - set the parameters below as required
#>

#################
## Functions   ##
#################
Function Remove-InvalidFileNameChars {
  param(
    [Parameter(Mandatory=$true,
      Position=0,
      ValueFromPipeline=$true,
      ValueFromPipelineByPropertyName=$true)]
    [String]$Name
  )

  $invalidChars = [IO.Path]::GetInvalidFileNameChars() -join ''
  $re = "[{0}]" -f [RegEx]::Escape($invalidChars)
  return ($Name -replace $re)
}

Function RunTime
{
    $End = (GET-DATE)
    $TS = NEW-TIMESPAN –Start $Start –End $End
    $Min = $TS.minutes
    $Sec = $TS.Seconds
    Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
}


#######################################
## PARAMETERS                        ##
#######################################
   # $ErrorActionPreference = 'SilentlyContinue'
    $SDate = $(Get-Date)

    # Root directory to export the scripts to
      $RootDirectory = "C:\Temp" 
      $SubDirectory = "Compliance_Settings_CI_Scripts"
      $Folder = "$RootDirectory\$SubDirectory"
      If (!(Test-Path $Folder)){New-Item -Path $Folder -ItemType Directory | Out-Null}
      If (!(Test-Path $Folder))
      {
		Write-Host "$Folder was not created! Can you write to 'C:\Temp' ???"-ForegroundColor Red
		Read-Host -Prompt "Press any key to continue or CTRL+C to quit" 
      }

    # SCCM SQL Server (and instance where applicable)
      $SQLServer = 'SERVER'
    
    # SCCM Database name
      $Database = 'CM_XX1'

    # CAB List Log
      $CABLog = "$Folder\CAB_Files.csv"
      If (Test-Path $CABLog){Remove-Item -Path $CABLog -Force}

    # CAB Temp Directory
      $CABTemp = "$RootDirectory\CABTemp"
      If (!(Test-Path $CABTemp)){New-Item -Path $CABTemp -ItemType Directory}
	  
    # CAB Temp Directory
      $RulesTemp = "$RootDirectory\RulesTemp"
      If (!(Test-Path $RulesTemp)){New-Item -Path $RulesTemp -ItemType Directory}	  

    # Compliance Rule Log
      $RulesLog = "$Folder\Compliance_Rules.csv"
      If (Test-Path $RulesLog){Remove-Item -Path $RulesLog -Force}


cls  
$5Minutes = (get-date).AddMinutes(10).ToString("HH:mm")
"Exporting Configuration Items -- Estimated time 1 minute --- $(Get-Date) --- check back in at $5Minutes"  
# Write-Host "$(Get-Date)`tExporting Configuration Items -- Estimated time 10 minutes`n"



#######################################
## Build list of Configuration Items ##
#######################################
    #Load SCCM Modules
        ."C:\Scripts\!Modules\GoGoSCCM_Module_client.ps1"
    
    $Start = (GET-DATE)
    $5Minutes = (get-date).AddMinutes(1).ToString("HH:mm")
    "Building list of Configuration Items -- Estimated time 1 minute --- $(Get-Date) -- check back in at $5Minutes"  
    # Write-Host "$(Get-Date)`tBuilding list of Configuration Items -- Estimated time 1 minute"
    $CItemNames = Get-CMConfigurationItem | Select-Object LocalizedDisplayName
    Write-Host "$(Get-Date)`tDone building list of Configuration Items" -ForegroundColor Green
    RunTime
    Start-Sleep -Seconds 1


#######################################
## Exporting CAB files               ##
#######################################
    $Start = (GET-DATE)
    $5Minutes = (get-date).AddMinutes(5).ToString("HH:mm")
    "Starting to export CAB files -- Estimated time 5 minutes --- $(Get-Date) -- check back in at $5Minutes"  
	# Write-Host "$(Get-Date)`tStarting to export CAB files -- Estimated time 5 minutes"
    ForEach ($IName in $CItemNames)
    {
        $ItemName = $IName.LocalizedDisplayName
        $CABPath = "$CABTemp\$ItemName.cab"
    
        # Create subdirectory structure if doesn't exist: configuration item name > current package version
        If (!(Test-Path "$Folder\$ItemName"))
        {
            New-Item -Path "$Folder" -Name "$ItemName" -ItemType container | Out-Null
        }
    
        Export-CMConfigurationItem -Name $ItemName -Path $CABPath
        Start-Sleep -Milliseconds 500
        # Move-Item "$Folder\$ItemName.cab" "$Folder\$ItemName" -Force
        $CABPath | Add-Content $CABLog
    }
	Write-Host "$(Get-Date)`tFinished exporting CAB files" -ForegroundColor Green
    RunTime
    D:


#######################################
## Export Configuration Item Scripts ##
#######################################
    $Start = (GET-DATE)
    Write-Host "$(Get-Date)`tExporting Configuration Item Scripts -- Estimated time a few seconds"
    
    # Create the subdirectory if doesn't exist
    If (!(Test-Path "$Folder"))
    {
        New-Item -Path "$RootDirectory" -Name "$SubDirectory" -ItemType container | Out-Null
    }
    
    # Define the SQL query
    $Query = "
    Select * from dbo.v_ConfigurationItems
    where CIType_ID = 3
    and IsLatest = 'true'"
    
    # Run the SQL query
    $connectionString = "Server=$SQLServer;Database=$Database;Integrated Security=SSPI"
    $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString
    $connection.Open()
    $command = $connection.CreateCommand()
    $command.CommandText = $Query
    $reader = $command.ExecuteReader()
    $ComplianceItems = New-Object -TypeName 'System.Data.DataTable'
    $ComplianceItems.Load($reader)
    $connection.Close()
    
    # Process each compliance item returned
    $ComplianceItems | ForEach {
        
        # Set some variables
        $PackageVersion = "v $($_.SDMPackageVersion)"
        [xml]$Digest = $_.SDMPackageDigest
        $CIName = $Digest.ChildNodes.OperatingSystem.Annotation.DisplayName.Text
    
        # Create subdirectory structure if doesn't exist: configuration item name > current package version
        If (!(Test-Path "$Folder\$CIName"))
        {
            New-Item -Path "$Folder" -Name "$CIName" -ItemType container | Out-Null
        }
        
        If (!(Test-Path "$Folder\$CIName\$PackageVersion"))
        {
            New-Item -Path "$Folder\$CIName" -Name "$PackageVersion" -ItemType container | Out-Null
        }
    
        # Put each compliance item setting in XML format into an arraylist for quick processing
        $Settings = New-Object System.Collections.ArrayList
        $Digest.DesiredConfigurationDigest.OperatingSystem.Settings.RootComplexSetting.SimpleSetting | foreach {
            [void]$Settings.Add([xml]$_.OuterXml)
            }
    
        # Process each compliance item setting
        $Settings | foreach {
            
            # Only process if this setting has a script source
            If ($_.SimpleSetting.ScriptDiscoverySource)
            {
                # Set some variables
                $SettingName = $_.SimpleSetting.Annotation.DisplayName.Text
                $DiscoveryScriptType = $_.SimpleSetting.ScriptDiscoverySource.DiscoveryScriptBody.ScriptType
                $DiscoveryScript = $_.SimpleSetting.ScriptDiscoverySource.DiscoveryScriptBody.'#text'
                $RemediationScriptType = $_.SimpleSetting.ScriptDiscoverySource.RemediationScriptBody.ScriptType
                $RemediationScript = $_.SimpleSetting.ScriptDiscoverySource.RemediationScriptBody.'#text'
                
                #Replace invalid characters
                $SettingName = Remove-InvalidFileNameChars $SettingName
    
                # Create the subdirectory for this setting if doesn't exist
                If (!(Test-Path "$Folder\$CIName\$PackageVersion\$SettingName"))
                {
                    New-Item "$Folder\$CIName\$PackageVersion" -Name $SettingName -ItemType container -Force | Out-Null
                }
                
                # If a discovery script is found
                If ($DiscoveryScript)
                {
                    # Set the file extension based on the script type
                    Switch ($DiscoveryScriptType)
                    {
                        Powershell { $Extension = "ps1" }
                        JScript { $Extension = "js" }
                        VBScript { $Extension = "vbs" }            
                    }
                    
                    # Export the script to a file
                    New-Item -Path "$Folder\$CIName\$PackageVersion\$SettingName" -Name "Discovery.$Extension" -ItemType file -Value $DiscoveryScript -Force | Out-Null
                }
                
                # If a remediation script is found
                If ($RemediationScript)
                {
                    # Set the file extension based on the script type
                    Switch ($RemediationScriptType)
                    {
                        Powershell { $Extension = "ps1" }
                        JScript { $Extension = "js" }
                        VBScript { $Extension = "vbs" }  
                    }
                    
                    # Export the script to a file
                    New-Item -Path "$Folder\$CIName\$PackageVersion\$SettingName" -Name "Remediation.$Extension" -ItemType file -Value $RemediationScript -Force | Out-Null
                }
            }
        }
    }
    Write-Host "$(Get-Date)`tExport complete" -ForegroundColor Green
    RunTime

<# For reference: CIType_IDs
    1	Software Updates
    2	Baseline
    3	OS
    4	General
    5	Application
    6	Driver
    7	Uninterpreted
    8	Software Updates Bundle
    9	Update List
    10	Application Model
    11	Global Settings
    13	Global Expression
    14	Supported Platform
    21	Deployment Type
    24	Intend Install Policy
    25  DeploymentTechnology
    26  HostingTechnology
    27  InstallerTechnology
    28  AbstractConfigurationItem
    60	Virtual Environment
#>

###################################################
## Extract Configuration Item Rules XML from CAB ##
###################################################
    $Start = (GET-DATE)
    Write-Host "$(Get-Date)`tExtracting CAB files containing Configuration Item Rules -- Estimated time a few seconds"

    $CABFiles = Get-Content $CABLog
    Foreach ($CABFile in $CABFiles)
    {
        If(C:\Windows\System32\expand.exe)
        {
            Try { cmd.exe /c "C:\Windows\System32\expand.exe -F:* `"$CABFile`" `"$RulesTemp`"" | Out-Null}
            Catch { Write-host "Nope, don't have that, soz." -ForegroundColor Red}
        }
    }
    Get-ChildItem -Path $RulesTemp -Filter "*.cab" -Recurse | Rename-Item -NewName {$_.name -replace 'cab','xml' }
    Write-Host "$(Get-Date)`tFinished extracting CAB files" -ForegroundColor Green
    RunTime

###################################################
## Generating Configuration Item Rules           ##
###################################################
    $Start = (GET-DATE)
    $5Minutes = (get-date).AddMinutes(3).ToString("HH:mm")
    "Enumerating list of Configuration Item Rules -- Estimated time 3 minutes --- $(Get-Date) -- check back in at $5Minutes" 
    # Write-Host "$(Get-Date)`tEnumerating list of Configuration Item Rules -- Estimated time 3 minutes"

    $XMLFiles = Get-ChildItem -Path $RulesTemp -Filter "*.xml"
    ForEach ($Item in $XMLFiles)
    {
        $XML = gc $Item.FullName
        If ($XML -match '<Rule xmlns')
        {
            $XMLName = $item.BaseName
            $From =  ($XML | Select-String -pattern '<Rule xmlns' | Select-Object LineNumber).LineNumber
            $To =  ($XML  | Select-String -pattern '</Rule>' | Select-Object LineNumber).LineNumber

            [array]$AFrom = @($From)
            [array]$ATo = @($To)
            
            $Found = $AFrom.Count
            $Num = 0
                
            Function GetLines
            {
                $Start = $From[$Num]
                $Finish = $To[$Num]
                $LineNumber = 0
                $Array = @()
                Foreach ($Line in $XML)
                {
                    ForEach-Object { $LineNumber++ }
                    If (($LineNumber -gt $Start) -and ($LineNumber -lt $Finish))
                    {
                        $Array += $Line      
                    }
                }
                #$Array | Add-Content 'D:\Projects\SCCM_DCM_Settings\Found.txt'
                Foreach ($Line in $Array)
                {
                    If ($Line -match 'DisplayName Text=')
                    {
                        $DN = $Line.Split('"')[1]
                    }Else{$DN = $Null}
                    $X += $DN+' '
                    
                    If ($Line -match '<Where>')
                    {
                        $W = $Line.Split('>')[1].Trim('</Where')
                    }Else{$W = $Null}
                    $X += $W+' '
        
                    If ($Line -match '<Operator>')
                    {
                        $Op = $Line.Split('>')[1].Trim('</Operator')
                    }Else{$Op = $Null}
                    $X += $Op+' '
                              
                    If ($Line -match 'ConstantValue Value=')
                    {
                        $CV = $Line.Split('"')[1]
                    }Else{$CV = $Null}
                    $X += $CV+' '
                }
                #"Rule: $X" | Add-Content "$Folder\Found.txt"
                $Z = "$($XMLName),`t`"$X`"" -replace '\s+', ' '
                $Z = $Z.replace(' " ','"').replace(' "','"')
                $TextInfo = (Get-Culture).TextInfo
                $TextInfo.ToTitleCase($Z) | Add-Content $RulesLog
            }
       
            Do 
            {
            GetLines
            $Num++
            }
            While ($Num -lt $Found)
        }
    }
    Write-Host "$(Get-Date)`tFinished enumerating Compliance Item Rules" -ForegroundColor Green
    RunTime



$EDate = (GET-DATE)
$Span = NEW-TIMESPAN –Start $SDate –End $EDate
$Min = $Span.minutes
$Sec = $Span.Seconds
Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
