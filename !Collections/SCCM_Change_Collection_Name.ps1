CD 'C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin'
CD E:

CD 'C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location XX1:
CD XX1:

# Change Collection Name
Set-CMDeviceCollection -Name 'TEST - Dell BIOS IME Upgrade - Latitude 5510'   -NewName 'TEST - BIOS and IMECI Upgrade - Dell Latitude 5510'
Set-CMDeviceCollection -Name 'Test - Dell BIOS IME Upgrade for Latitude 7390' -NewName 'TEST - BIOS and IMECI Upgrade - Dell Latitude 7390'
Set-CMDeviceCollection -Name 'Test - Dell BIOS IME Upgrade for Optiplex 7040' -NewName 'TEST - BIOS and IMECI Upgrade - Dell Optiplex 7040'
Set-CMDeviceCollection -Name 'Test - Dell BIOS IME Upgrade for Optiplex 7050' -NewName 'TEST - BIOS and IMECI Upgrade - Dell Optiplex 7050'
Set-CMDeviceCollection -Name 'TEST - Dell BIOS Latitude 5500 1.25.0'          -NewName 'TEST - BIOS and IMECI Upgrade - Dell Latitude 5500'
Set-CMDeviceCollection -Name 'Test - Dell BIOS Latitude 5520 1.27.0'          -NewName 'TEST - BIOS and IMECI Upgrade - Dell Latitude 5520'
Set-CMDeviceCollection -Name 'TEST - Dell BIOS Latitude 5580 1.32.2'          -NewName 'TEST - BIOS and IMECI Upgrade - Dell Latitude 5580'
Set-CMDeviceCollection -Name 'Test - Dell BIOS Latitude 7400'                 -NewName 'TEST - BIOS and IMECI Upgrade - Dell Latitude 7400'
Set-CMDeviceCollection -Name 'TEST - Dell BIOS Latitude 7400 2-in-1 1.25.0'   -NewName 'TEST - BIOS and IMECI Upgrade - Dell Latitude 7400 2-in-1'
Set-CMDeviceCollection -Name 'Test - Dell BIOS Opitiplex 7080 1.21.0'         -NewName 'TEST - BIOS and IMECI Upgrade - Dell Optiplex 7080'
Set-CMDeviceCollection -Name 'Test - Dell BIOS Optiplex 7070 1.21.0'          -NewName 'TEST - BIOS and IMECI Upgrade - Dell Optiplex 7070'
Set-CMDeviceCollection -Name 'TEST - Dell BIOS Optiplex 9020 A25'             -NewName 'TEST - BIOS and IMECI Upgrade - Dell Optiplex 9020'
Set-CMDeviceCollection -Name 'TEST - Lenovo BIOS Thinkpad P43s 1.80'          -NewName 'TEST - BIOS and IMECI Upgrade - Lenovo Thinkpad P43s'



CD E:
