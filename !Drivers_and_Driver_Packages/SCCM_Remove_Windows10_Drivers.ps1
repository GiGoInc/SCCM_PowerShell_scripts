# Import Module
    $CMModulepath = $Env:SMS_ADMIN_UI_PATH.ToString().Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + "\ConfigurationManager.psd1"
    Import-Module $CMModulepath -force

# Change the site Code
    CD SS1:

# Log File
    $Log = 'D:\Powershell\!SCCM_PS_scripts\!Drivers_and_Driver_Packages\SCCM_Remove_Windows10_Drivers--Results.csv'
    "ObjectPath,LocalizedDisplayName,DriverClass,LocalizedCategoryInstanceNames,DriverVersion,DriverProvider,DriverDate,CreatedBy,LastModifiedBy,DateCreated,DateLastModified,ContentSourcePath" | Set-Content $Log


$Cats = Get-CMDriver | select LocalizedCategoryInstanceNames
$Cats = $Cats.LocalizedCategoryInstanceNames | Sort-Object -Unique
$Cats | Out-File 'D:\Powershell\!SCCM_PS_scripts\!Drivers_and_Driver_Packages\Driver_Categories.txt'
####################################################################################################################################
####################################################################################################################################

$Categories = 'Dell Win10 PE A15', `
              'VMware', `
              'WinPE 10 x64 Dell', `
              'WinPE 5.0 x32'

ForEach ($C in $Categories)
{
    $SDate = Get-Date
    Write-Host "$SDate -- Removing drivers that are in category: $C" -ForegroundColor Cyan
    # Get-CMDriver  | Where-Object {(($_.LocalizedCategoryInstanceNames -like $C) -and ($_.ContentSourcePath -like 'E7440'))} #| Remove-CMDriver -Force
    Get-CMDriver  | Where-Object {($_.LocalizedCategoryInstanceNames -like $C)} | Remove-CMDriver -Force
    $EDate = (GET-DATE)
    $Span = NEW-TIMESPAN –Start $SDate –End $EDate
    $Min = $Span.minutes
    $Sec = $Span.Seconds
    Write-host "Ending... $EDate" -foregroundcolor green
    Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n" -ForegroundColor Cyan
}

####################################################################################################################################
####################################################################################################################################
<#
    7040
    9020
    Dell
    Dell - 7050 - Win7x64 - A11
    Dell - 7050 - Win7x86 - A01
    Dell - E6540 - Win7x64 - A13
    Dell 5480 - Win7x64 - A05
    Dell 7440 AIO - Win7x64 - A11
    Dell E5540 - Win7x64 - A10
    Dell E5540 - Win7x86 - A10
    Dell E5550 - Win7x32 - A02
    Dell E5550 - Win7x64 - A02
    Dell E5570 - Win7x64 - A04
    Dell E5570 - Win7x86 - A04
    Dell E5580 - Win7x32 - A00
    Dell E5580 - Win7x64 - A00
    Dell E7450 - Win7x64 - A09
    Dell E7480 - Win7x64 - A00
    Dell E7480 - Win7x86 - A00
    Dell Optiplex 990 - Win7x64 - A10
    Dell Win10 PE A15
    E5540
    E5550
    E7440
    Latitude
    Latitude E5540 - Win7x64 - A08
    Latitude E5540 - Win7x86 - A08
    Latitude E7440 - Win7x64 - A08
    Latitude E7440 - Win7x86 - A08
    Latitude E7450 - Win7x64 - A03
    Latitude E7450 - Win7x86 - A03
    Optiplex
    Optiplex 7010 - Win7x64 - A09
    Optiplex 7010 - Win7x86 - A09
    Optiplex 9020 - Win7x64 - A09
    Optiplex 9020 - Win7x86 - A09
    VMware
    Win10 - D15 - Dock
    Win10 - Dell 5290 - 2n1 - XCTO
    Win10 - Dell AIO 7450
    Win10 - Dell Latitude 5480
    Win10 - Dell Latitude 5500
    Win10 - Dell Latitude 5540
    Win10 - Dell Latitude 5590
    Win10 - Dell Latitude 7390
    Win10 - Dell Latitude E5550
    Win10 - Dell Latitude E5570
    Win10 - Dell Latitude E5580
    Win10 - Dell Latitude E7440
    Win10 - Dell Optiplex 7010
    Win10 - Dell Optiplex 7040
    Win10 - Dell Optiplex 7050
    Win10 - Dell Optiplex 7060
    Win10 - Dell Optiplex 7070
    Win10 - Dell Optiplex 9020
    Win10 - Dell XPS 13 - 9365
    Win10 - Dell XPS 15 - 9575
    Win10 - Newline
    Win7 - D15 - Dock
    Win7x64 - 7040 - A02
    Win7x64 - E5550 - A05
    Win7x64 - E7440 - A09
    Win7x86 - 7040 - A02
    Win7x86 - E5550 - A05
    Win7x86 - E7440 - A09
    WinPE 10 x64 Dell
    WinPE 5.0 x32
    x64
#>