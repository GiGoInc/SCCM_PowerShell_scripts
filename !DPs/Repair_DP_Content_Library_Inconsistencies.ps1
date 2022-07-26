# UPDATE THESE VARIABLES FOR YOUR ENVIRONMENT
[string]$SiteServer = "SCCMSERVER.Domain.Com"
[string]$SiteCode = "SS1"
[int32]$WarnThreshold = 3


# function for pausing the script and prompting the user for confirmation
Function Pause-Script
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter(Mandatory=$false)]
        [ValidateRange(0,5)]
        [int]$Buttons = 0,

        [Parameter(Mandatory=$false)]
        [switch]$Warning
    )

    # Check for Powershell ISE
    if ($psISE) {
        Add-Type -AssemblyName System.Windows.Forms
        $x = [System.Windows.Forms.MessageBox]::Show("$message","Script Execution Paused",$Buttons)
    } else {
        #translate buttons
        switch ($Buttons) {
            0 { $options = "Type OK to continue" }
            1 { $options = "OK or Cancel" }
            2 { $options = "Abort, Retry, or Ignore" }
            3 { $options = "Yes, No, or Cancel" }
            4 { $options = "Yes or No" }
            5 { $options = "Retry or Cancel" }
        }

        if ($Warning) {
            $message = "Warning: $message"
            $color = "Red"
        } else {
            $color = "Yellow"
        }

        $invalid = $true
        while ($invalid)
        {
            Write-Host "$message" -ForegroundColor $color
            $x = Read-Host -Prompt "$options"

            switch ($Buttons) {
                0 {
                    if ($x -contains 'OK') {$invalid = $false}
                     else {
                        Write-Warning "Invalid input."
                    }
                }
                1 {
                    if (($x -contains 'OK') -or ($x -contains 'Cancel')) {
                        $invalid = $false
                    } else {
                        Write-Warning "Invalid input."
                    }
                }
                2 {
                    if (($x -contains 'Abort') -or ($x -contains 'Retry') -or ($x -contains 'Ignore')) {
                        $invalid = $false
                    } else {
                        Write-Warning "Invalid input."
                    }
                }
                3 {
                    If (($x -contains 'Yes') -or ($x -contains 'No') -or ($x -contains 'Cancel')) {
                        $invalid = $false
                    } else {
                        Write-Warning "Invalid input."
                    }
                }
                4 {
                    If (($x -contains 'Yes') -or ($x -contains 'No')) {
                        $invalid = $false
                    } else {
                        Write-Warning "Invalid input."
                    }
                }
                5 {
                    If (($x -contains 'Retry') -or ($x -contains 'Cancel')) {
                        $invalid = $false
                    } else {
                        Write-Warning "Invalid input."
                    }
                }
            }
        }
    }

    return $x
}


# Get all valid packages from the primary site server
$Namespace = "root\SMS\Site_" + $SiteCode
Write-Host "Getting all valid packages... " -NoNewline
$ValidPackages = Get-WMIObject -ComputerName $SiteServer -Namespace $Namespace -Query "Select * from SMS_ObjectContentExtraInfo"
Write-Host ([string]($ValidPackages.count) + " packages found.")

# Get all distribution points
Write-Host "Getting all valid distribution points... " -NoNewline
$DistributionPoints = Get-WMIObject -ComputerName $SiteServer -Namespace $Namespace -Query "select * from SMS_DistributionPointInfo where ResourceType = 'Windows NT Server'"
Write-Host ([string]($DistributionPoints.count) + " distribution points found.")
Write-Host ""

# iterate through all DPs
foreach ($DistributionPoint in $DistributionPoints)
{
    # first, clean up orphaned records in WMI by comparing to master content lib
    $InvalidPackages = @()
    $DistributionPointName = $DistributionPoint.ServerName

###################################################################################################
If ($DistributionPoint.ServerName -eq 'msbism01.Domain.Com')
{
###################################################################################################

    if ( -not(Test-Connection $DistributionPointName -Quiet -Count 1)) {
        Write-error "Could not connect to DistributionPoint $DistributionPointName - Skipping this server..."
    } else {
        Write-Host "$DistributionPointName is online." -ForegroundColor Green
        Write-Host "Getting packages from WMI on $DistributionPointName ... " -NoNewline
        $CurrentPackageList = @(Get-WMIObject -ComputerName $DistributionPointName -Namespace "root\sccmdp" -Query "Select * from SMS_PackagesInContLib")
        Write-Host ([string]($CurrentPackageList.Count) + " packages found.")

        if (($CurrentPackageList.Count -eq 0) -or ($CurrentPackageList -eq $null)){
            Write-Host "Skipping this distribution point"
        } else{
            Write-Host "Validating WMI packages on $DistributionPointName ..."

            $result = @(Compare-Object -ReferenceObject $CurrentPackageList -DifferenceObject $ValidPackages -Property PackageID -PassThru)
            $InvalidPackages = @($result |Where-Object {$_.sideindicator -eq '<='})

            if ($InvalidPackages.Count -eq 0){
                Write-Host "All WMI packages on $DistributionPointName are valid" -ForegroundColor Green
            }
            else {
                $response = $null
                if ($InvalidPackages.Count -gt $WarnThreshold) {
                    Write-Host "Number of invalid packages exceeds threshold [$($InvalidPackages.Count) invalid]." -ForegroundColor Yellow
                    $InvalidPackages.PackageID
                    $response = Pause-Script -Message "Proceed with removing invalid WMI packages on $($Env:COMPUTERNAME)?" -Warning -Buttons 4
                } else {
                    Write-Host "Invalid WMI packages on $DistributionPointName :" -ForegroundColor Yellow
                    $InvalidPackages.PackageID
                }

                if ($response -eq "No") {
                    Write-Host "Skipping WMI package maintenance on $DistributionPointName." -ForegroundColor Yellow
                } else {
                    $InvalidPackages | foreach {
                        $InvalidPackageID = $_.PackageID
                        Write-Host "Removing invalid package $InvalidPackageID from WMI on $DistributionPointName " -NoNewline
                        Get-WMIObject -ComputerName $DistributionPointName -Namespace "root\sccmdp" -Query ("Select * from SMS_PackagesInContLib where PackageID = '" + ([string]($_.PackageID)) + "'") | Remove-WmiObject
                        Write-Host "-Done"
                    }
                }
            }
            Write-Host ""
        }
    }

    # next, clean up orphaned records from PkgLib by comparing to cleaned WMI
    Invoke-Command -ComputerName $DistributionPointName -ScriptBlock {

        Function Write-LogFile
        {
            param(
                [parameter(Mandatory=$true, HelpMessage="Name of the log file, e.g. 'FileName'. File extension should not be specified")]
                [ValidateNotNullOrEmpty()]
                [string]$Name,
                [parameter(Mandatory=$true, HelpMessage="Value added to the specified log file")]
                [ValidateNotNullOrEmpty()]
                [string]$Value,
                [parameter(Mandatory=$true, HelpMessage="Choose a location where the log file will be created")]
                [ValidateNotNullOrEmpty()]
                [ValidateSet("UserTemp","WindowsTemp","IsaacLog")]
                [string]$Location
            )
            # Determine log file location
            switch ($Location) {
                "UserTemp" { $LogLocation = ($env:TEMP + "\") }
                "WindowsTemp" { $LogLocation = ($env:SystemRoot + "\Temp\") }
                "IsaacLog" { $LogLocation = ("\\Computer1\d$\Powershell\!SCCM_PS_scripts\!DPs\") }
            }
            # Construct log file name and location
            $LogFile = ($LogLocation + $Name + ".log")
            # Create log file unless it already exists
            if (-not(Test-Path -Path $LogFile -PathType Leaf)) {
                New-Item -Path $LogFile -ItemType File -Force | Out-Null
            }
            # Add timestamp to value
            $Value = (Get-Date).ToShortDateString() + ":" + (Get-Date).ToLongTimeString() + " - " + $Value
     
            # Add value to log file
            Add-Content -Value $Value -LiteralPath $LogFile
        }
 
        # function for pausing the script and prompting the user for confirmation
		Function Pause-Script {
    		[CmdletBinding()]
    		Param(
        		[Parameter(Mandatory=$true)]
        		[ValidateNotNullOrEmpty()]
        		[string]$Message,

        		[Parameter(Mandatory=$false)]
        		[ValidateRange(0,5)]
        		[int]$Buttons = 0,

        		[Parameter(Mandatory=$false)]
        		[switch]$Warning
    		)

    		# Check for Powershell ISE
    		if ($psISE) {
        		Add-Type -AssemblyName System.Windows.Forms
        		$x = [System.Windows.Forms.MessageBox]::Show("$message","Script Execution Paused",$Buttons)
		    } else {
        		#translate buttons
        		switch ($Buttons) {
            		0 { $options = "Type OK to continue" }
            		1 { $options = "OK or Cancel" }
            		2 { $options = "Abort, Retry, or Ignore" }
            		3 { $options = "Yes, No, or Cancel" }
            		4 { $options = "Yes or No" }
            		5 { $options = "Retry or Cancel" }
        		}

        		if ($Warning) {
            		$message = "Warning: $message"
            		$color = "Red"
        		} else {
            		$color = "Yellow"
        		}

        		$invalid = $true
        		while ($invalid) {
            		Write-Host "$message" -ForegroundColor $color
            		$x = Read-Host -Prompt "$options"

            		switch ($Buttons) {
                		0 {
                    		If (($x -contains 'OK')) {
                        		$invalid = $false
                    		} else {
                        		Write-Warning "Invalid input."
                    		}
                		}
                		1 {
                    		If (($x -contains 'OK') -or ($x -contains 'Cancel')) {
                        		$invalid = $false
                    		} else {
                        		Write-Warning "Invalid input."
                    		}
                		}
                		2 {
                    		If (($x -contains 'Abort') -or ($x -contains 'Retry') -or ($x -contains 'Ignore')) {
                        		$invalid = $false
                    		} else {
                        		Write-Warning "Invalid input."
                    		}
                		}
                		3 {
                    		If (($x -contains 'Yes') -or ($x -contains 'No') -or ($x -contains 'Cancel')) {
                        		$invalid = $false
                    		} else {
                        		Write-Warning "Invalid input."
                    		}
                		}
                		4 {
                    		If (($x -contains 'Yes') -or ($x -contains 'No')) {
                        		$invalid = $false
                    		} else {
                        		Write-Warning "Invalid input."
                    		}
                		}
                		5 {
                    		If (($x -contains 'Retry') -or ($x -contains 'Cancel')) {
                        		$invalid = $false
                    		} else {
                        		Write-Warning "Invalid input."
                    		}
                		}
            		}
        		}
    		}

    		return $x
		}
            
        # get list of storage drives in use for current server
        $dataDrives = @(Get-PSDrive -PSProvider FileSystem | ?{$_.Used -gt 0})

        # find SCCMContentLib on server
        $selectedDrive = $null
        foreach ($drive in $dataDrives)
        {
            if (Test-Path "$($drive.Name):\SCCMContentLib")
            {
                $selectedDrive = $drive.Name
            }
        }

        # get package list from PkgLib
        if ($null -eq $selectedDrive) {
            Write-Warning "Failed to locate SCCMContentLib on $Env:COMPUTERNAME"
            return
        } else {
            Write-Host "Getting package list from PkgLib on $Env:COMPUTERNAME ... " -NoNewline
            $path = "$($selectedDrive):\SCCMContentLib\PkgLib"
            $pkgs = @()
            Get-ChildItem -Path $path | Select-Object Name,Basename | %{
                $pkgs = $pkgs + [PSCustomObject]@{
                    FileName = $_.Name
                    PackageID = $_.BaseName
                }
            }
            Write-Host ([string]($pkgs.Count) + " packages found.")

            Write-Host "Refreshing WMI package list from $Env:COMPUTERNAME ... " -NoNewline
            $CurrentPackageList = @(Get-WMIObject -Namespace "root\sccmdp" -Query "Select * from SMS_PackagesInContLib")
            Write-Host ([string]($CurrentPackageList.Count) + " packages found.")

            # compare lists
            $result = @(Compare-Object -ReferenceObject $CurrentPackageList -DifferenceObject $pkgs -Property PackageID -PassThru)
            $InvalidPkgLibPackages = @($result |Where-Object {$_.sideindicator -eq '=>'})
            $missingPkgLibPackages = @($result |Where-Object {$_.sideindicator -eq '<='})

            if ($InvalidPkgLibPackages.Count -eq 0){
                Write-Host "All packages in PkgLib on $Env:COMPUTERNAME are valid" -ForegroundColor Green
            } else {
                $response = $null
                if ($InvalidPkgLibPackages.Count -gt $WarnThreshold) {
                    Write-Host "Number of invalid packages exceeds threshold [$($InvalidPkgLibPackages.Count) invalid]." -ForegroundColor Yellow
                    $InvalidPkgLibPackages.PackageID
                    $response = Pause-Script -Message "Proceed with removing invalid PkgLib packages on $($Env:COMPUTERNAME)?" -Warning -Buttons 4
                } else {
                    Write-Host "Orphaned packages in PkgLib on $Env:COMPUTERNAME :" -ForegroundColor Yellow
                    $InvalidPkgLibPackages.PackageID
                }

                if ($response -eq "No") {
                    Write-Host "Skipping PkgLib package maintenance on $($Env:COMPUTERNAME)." -ForegroundColor Yellow
                } else {
                    $InvalidPkgLibPackages | foreach {
                        $InvalidPackageID = $_.PackageID
                        $InvalidPackageFileName = $_.FileName
                        Write-Host "Removing invalid package $InvalidPackageID from PkgLib on $Env:COMPUTERNAME " -NoNewline
                        Write-LogFile -Name "ReplaceContent" -Location IsaacLog -Value "Removing invalid package $InvalidPackageID from PkgLib on $Env:COMPUTERNAME"
                        try{
                            Remove-Item -Path "$path\$InvalidPackageFileName" -Force
                        } catch {
                            Write-Warning "Failed to remove $InvalidPackageFileName from PkgLib on $Env:COMPUTERNAME"
                        }
                        Write-Host "-Done"
                    }
                }
            }

            # finally, if any package IDs exist in WMI but are missing from PkgLib, prompt user
            if ($missingPkgLibPackages.Count -gt 0) {
                Write-Host "Missing packages in PkgLib on $Env:COMPUTERNAME :" -ForegroundColor Yellow
                $missingPkgLibPackages.PackageID
                $null = Pause-Script -Message "Please manually redistribute above packages to $Env:COMPUTERNAME." -Buttons 0
            }
            Write-Host ""
        }
    }
###################################################################################################
}
###################################################################################################
}