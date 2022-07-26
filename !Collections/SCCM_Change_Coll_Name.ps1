D:
CD 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:
CD SS1:

# Change Collection Name
Set-CMDeviceCollection -Name 172.31.170.0 -NewName "IP Range - 172.31.170.0"

CD E: