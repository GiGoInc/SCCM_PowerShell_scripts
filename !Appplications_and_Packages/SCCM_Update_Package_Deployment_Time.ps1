cls

}
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

$PKGInfo = 
'Latitude 5500 IME A11;Latitude 5500 IME A11;Pilot - Dell BIOS Latitude 5500 1.25.0', 
'Latitude 5510 IME A11;Install IME;Pilot - Dell BIOS Latitude 5510 1.23.0', 
'Latitude 5520 IME A09;Latitude 5520 A09;Pilot - Dell BIOS Latitude 5520 1.32.1', 
'Latitude 5530 IME 2230.3.20.0_A04;Install - Latitude_5530_2230.3.20.0_A04;Pilot - Dell BIOS Latitude 5530 1.18.0', 
'Latitude 5540 IME 2251.3.41.0_A00;Latitude_5540-IMECI_3.41.0_A00.;Pilot - Dell BIOS Latitude 5540 1.9.0', 
'Latitude 5580 IME A15;Latitude 5580 IME A15;Pilot - Dell BIOS Latitude 5580 1.32.2', 
'Latitude 7420 IME 3.16.0_A09;Install - IME Latitude_7420 3.16.0_A09;Pilot - Dell BIOS Latitude 7420 1.30.0', 
'Latitude 7430 IME 2230.3.20.0_A04;Install IME - Latitude_7430-2230.3.20.0_A04;Pilot - Dell BIOS Latitude 7430 1.18.0', 
'Optiplex 7010 IME 2302.4.5.0_A01;Optiplex_7010-IME-VC601_2302.4.5.0_A01;Pilot - Dell BIOS Optiplex 7010 SFF 1.13.1', 
'Optiplex 7040 IME A10;Install IME;Pilot - Dell BIOS Optiplex 7040 1.24.0', 
'Optiplex 7050 IME A15;Install IME;Pilot - Dell BIOS Optiplex 7050 1.24.0', 
'Optiplex 7070 IME 3.16.0_A11;Optiplex 7070 IME 3.16.0_A11;Pilot - Dell BIOS Optiplex 7070 1.22.0', 
'Optiplex 7090 IME 4.5.0_A10_01;Optiplex 7090 IME 4.5.0_A10_01;Pilot - Dell BIOS Optiplex 7090 1.19.0', 
'Precision 7740 IME 2313.4.16.0_A12_02;Install IME Precision 7740_2313.4.16.0_A12_02;Pilot - Dell BIOS Precision 7740 1.27.0'


ForEach ($Item in $PKGInfo)
{
    $PackageName = $item.split(';')[0]
    $ProgramName = $item.split(';')[1]
     $Collection = $item.split(';')[2]
        
    "Setting: $PackageName...."
    $ProgramDeployTime = $(Get-Date).Date + '18:30:00'
    $NewScheduleDeadline = New-CMSchedule -Start $ProgramDeployTime -Nonrecurring
    Set-CMPackageDeployment -PackageName "$PackageName" -StandardProgramName "$ProgramName" -CollectionName "$Collection" -Schedule $NewScheduleDeadline
}

