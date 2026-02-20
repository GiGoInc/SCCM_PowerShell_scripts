D:
CD E:

D:
CD 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location XX1:
CD XX1:

# Change Collection Name
Set-CMDeviceCollection -Name 192.31.170.0 -NewName "IP Range - 192.31.170.0"

CD E:
