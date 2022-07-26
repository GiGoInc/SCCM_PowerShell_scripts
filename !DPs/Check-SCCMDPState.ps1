<#
.SYNOPSIS
 	<PS to check all or dedicate DP Package Distributionsstate WMI and Content Lib State>
.DESCRIPTION
	<>
.PARAMETER <Parameter_Name>
	<
		$DPType (DPALL, DPSingle)		Parameter for ALL DP or only one dedicate DP
		$SiteServer						Parameter for SCCM Primary or CAS Server (use FQDN)		
		$SiteCode						Parameter for SCCM Primary or CAS Server Site Code, 3 Letters
		$DPFQDN							optional Parameter for Single DP, only if DPType=DPSingle
		$DefaultContentLibDriveLetter 	optional to check the DP Content Lib Volume (Default is set to D:)
		$LogFile 						optional to set the logfile, Default is set to "C:\windows\temp\DP_CleanUP_Action_Log"
		$GridView						optional to set to summary to gridview 
	>
.INPUTS
	<>
.OUTPUTS
	<Log File, Default C:\windows\temp\DP_CleanUP_Action_Log_%ExecutionTime.log>
.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2019 v5.6.160
	 Created on:   	29.03.2019 13:56
	 Created by:   	Klaus Bilger (Klaus.Bilger@C-S-L.BIZ
	 Organization: 	C-S-L K.Bilger
	 Filename:     	Check-SCCMDPState.ps1
	===========================================================================
#>
#---------------------------------------------------------[Initialisations]--------------------------------------------------------
[cmdletbinding()]
param
(
	[ValidateSet('DPALL', 'DPSingle')]
	[Parameter(Mandatory = $true, HelpMessage = "Please enter the the DP Type 'DPALL/DPSingle'")]
	[ValidateNotNullOrEmpty()]
	[String]$DPType,
	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[String]$SiteServer,
	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[String]$SiteCode,
	[parameter(Mandatory = $False)]
	[switch]$GridView,
	[Parameter(Mandatory = $false)]
	[string]$DPFQDN,
	[Parameter(Mandatory = $false)]
	$DefaultContentLibDriveLetter = "D:",
	[Parameter(Mandatory = $false)]
	$LogFile = "C:\windows\temp\DP_CleanUP_Action_Log"
)
switch ($DPType)
{
	'DPALL' { $DPSearch = "select * from SMS_DistributionPointInfo where ResourceType = 'Windows NT Server'" }
	'DPSingle' { $DPSearch = "select * from SMS_DistributionPointInfo where Name like '" + $DPFQDN + "'" }
}
#endregion
#---------------------------------------------------------[Declarations]-----------------------------------------------------------
#region Declarations

$Namespace = "root\SMS\Site_" + $SiteCode
$LogFile = $LogFile + "_" + (Get-Date -Format "yyyy_MM_dd_HH_MM") + ".log"
$DPResults = @()
#endregion
#---------------------------------------------------------[Execution]--------------------------------------------------------------

## check Powershell Version 
if ($PSVersionTable.PSVersion.Major -lt 3)
{
	$errmsg = "wrong Powershell Version. Version = [" + $PSVersionTable.PSVersion.Major + "], Powershell Version 3.0 is required !!"
	Write-Host $errmsg -ForegroundColor Red
	Exit 9999
}


## start working
Start-Transcript -Path $LogFile -Force -IncludeInvocationHeader
if ([string]::IsNullOrEmpty($DPFQDN) -and ($DPType -eq "DPSingle"))
{
	$errmsg = "FQDN for Single DP missing, please use the parameter -$DPFQDN 'your DP FQDN'"
	write-host $errmsg -ForegroundColor Red
	Exit 9999
}

$DPSearch = "select * from SMS_DistributionPointInfo where ResourceType = 'Windows NT Server'"
$DistributionPoints = Get-WMIObject -ComputerName $SiteServer -Namespace $Namespace -Query $DPSearch -ErrorAction SilentlyContinue
if ([string]::IsNullOrEmpty($DistributionPoints))
{
	$errmsg = "List of Distributionsserver is empty !!"
	write-host $errmsg -ForegroundColor Red
	Exit 9999
}

Write-Host "getting all valid distribution points... " -NoNewline -ForegroundColor Green
Write-Host ([string]($DistributionPoints.count) + " distribution points found.") -ForegroundColor Green
Write-Host ""
$DPTotalCount = $DistributionPoints.count

## loop trough List of DP's
foreach ($DistributionPoint in $DistributionPoints)
{
	$DistributionPointName = $DistributionPoint.ServerName
	if (-not (Test-Connection $DistributionPointName -Quiet -Count 1))
	{
		Write-error "Could not connect to DistributionPoint $DistributionPoint - Skipping this server..."
	}
	else
	{
		$List_of_Missing_Pkg_WMI = ""
		$List_of_too_mmuch_Pkg_WMI = ""
		$List_of_Missing_Pkg_ContenLib = ""
		$List_of_too_much_Pkg_ContenLib = ""
		$ValidPackagesforDP = ""
		$Search4DistributionPoint = "%" + $DistributionPointName + "%"
		
		## load all Pkg from central DB
		$ValidPackagesforDP = Get-WMIObject -ComputerName $SiteServer -Namespace $Namespace -Query "select distinct PackageID from SMS_PackageStatus where PkgServer like '$Search4DistributionPoint'" | Select -ExpandProperty PackageID | Sort-Object
		Write-Host ""
		Write-host  "working on DP [$($DistributionPointName)],# total:"($DPTotalCount--) -ForegroundColor Green
		Write-Host "$DistributionPointName is online." -ForegroundColor Green
		Write-Host (" +-- " + [string]($ValidPackagesforDP.count) + " packages found for DP $DistributionPointName")
		Write-Host " +-- Getting packages from $DistributionPointName"
		$WMIPkgList = Get-WmiObject -ComputerName $DistributionPointName -Namespace Root\SCCMDP -Class SMS_PackagesInContLib | Select -ExpandProperty PackageID | Sort-Object
		
		## load the Content Disk Info, some DP are not set by default "G:\"
		$ContentLib = Invoke-Command -ComputerName $DistributionPointName { (Get-ItemProperty -path HKLM:SOFTWARE\Microsoft\SMS\DP -Name ContentLibraryPath) }
		$PkgLibPath = ($ContentLib.ContentLibraryPath) + "\PkgLib"
		Write-Host " +-- path to the local content lib $($PkgLibPath)"
		if ($PkgLibPath -notmatch $DefaultContentLibDriveLetter) { Write-Host " +-- **** content lib path wrong ****" -ForegroundColor Red -BackgroundColor Gray }
		$ScriptBlockContent = { $PkgLibPath = $args[0]; Get-ChildItem $PkgLibPath | Select -ExpandProperty Name | Sort-Object | ForEach-Object { $_.replace(".INI", "") } }
		$PkgLibList = Invoke-Command -ComputerName $DistributionPointName -ScriptBlock $ScriptBlockContent -ArgumentList $PkgLibPath
		Write-Host (" +-- " + [string]($WMIPkgList.count) + " packages found WMI DP $DistributionPointName ")
		Write-Host (" +-- " + [string]($PkgLibList.count) + " packages found Content LIB DP $DistributionPointName ")
		
		# compare 
		$List_of_Missing_Pkg_WMI = Compare-Object -ReferenceObject $ValidPackagesforDP -DifferenceObject $WMIPkgList -PassThru | Where-Object { $_.SideIndicator -eq "<=" }
		$List_of_too_mmuch_Pkg_WMI = Compare-Object -ReferenceObject $ValidPackagesforDP -DifferenceObject $WMIPkgList -PassThru | Where-Object { $_.SideIndicator -eq "=>" }
		$List_of_Missing_Pkg_ContenLib = Compare-Object -ReferenceObject $ValidPackagesforDP -DifferenceObject $PkgLibList -PassThru | Where-Object { $_.SideIndicator -eq "<=" }
		$List_of_too_much_Pkg_ContenLib = Compare-Object -ReferenceObject $ValidPackagesforDP -DifferenceObject $PkgLibList -PassThru | Where-Object { $_.SideIndicator -eq "=>" }
		
		
		## check for $NULL 
		if ([string]::IsNullOrEmpty($List_of_Missing_Pkg_WMI)) { $List_of_Missing_Pkg_WMI = "no" }
		if ([string]::IsNullOrEmpty($List_of_too_mmuch_Pkg_WMI)) { $List_of_too_mmuch_Pkg_WMI = "no" }
		if ([string]::IsNullOrEmpty($List_of_Missing_Pkg_ContenLib)) { $List_of_Missing_Pkg_ContenLib = "no" }
		if ([string]::IsNullOrEmpty($List_of_too_much_Pkg_ContenLib)) { $List_of_too_much_Pkg_ContenLib = "no" }
		
		# Add to a PS object
		$DPResult = New-Object psobject
		Add-Member -InputObject $DPResult -MemberType NoteProperty -Name "DP FQDN Name" -Value $DistributionPointName
		Add-Member -InputObject $DPResult -MemberType NoteProperty -Name "WMI missing values" -Value $List_of_Missing_Pkg_WMI
		Add-Member -InputObject $DPResult -MemberType NoteProperty -Name "WMI to much Values" -Value $List_of_too_mmuch_Pkg_WMI
		Add-Member -InputObject $DPResult -MemberType NoteProperty -Name "Content Lib missing values" -Value $List_of_Missing_Pkg_ContenLib
		Add-Member -InputObject $DPResult -MemberType NoteProperty -Name "Content Lib to much Values" -Value $List_of_too_much_Pkg_ContenLib
		$DPResults += $DPResult
	}
}


write-host " **** DONE ****" -ForegroundColor Green
Stop-Transcript

if ($GridView)
{
	if ($DPResults -ne $null)
	{ $DPResults | Out-GridView -Title "ConfigMgr Failed Package Distributions" }
	Else { Write-Warning "No results were returned!" }
}
else
{
	if ($DPResults -ne $null)
	{ $DPResults | ft -AutoSize }
	Else { Write-Warning "No results were returned!" }
}
