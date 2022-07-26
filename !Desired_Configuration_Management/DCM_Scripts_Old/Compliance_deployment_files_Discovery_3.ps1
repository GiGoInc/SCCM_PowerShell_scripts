# "Firefox Deployment Files" Discovery Script

IF (Test-Path 'C:\Program Files\Mozilla Firefox')
{
    IF ((Test-Path 'C:\Program Files\Mozilla Firefox\mozilla.cfg') -eq $true -and (Test-Path 'C:\Program Files\Mozilla Firefox\browser\override.ini') -eq $true -and (Test-Path 'C:\Program Files\Mozilla Firefox\defaults\pref\local-settings.js') -eq $true)
        {write-host "Compliant"}
    ELSE
        {write-host "Not-Compliant"}
}

IF (Test-Path 'C:\Program Files (x86)\Mozilla Firefox')
{
    IF ((Test-Path 'C:\Program Files (x86)\Mozilla Firefox\mozilla.cfg') -eq $true -and (Test-Path 'C:\Program Files (x86)\Mozilla Firefox\browser\override.ini') -eq $true -and (Test-Path 'C:\Program Files (x86)\Mozilla Firefox\defaults\pref\local-settings.js') -eq $true)
        {write-host "Compliant"}
    ELSE
        {write-host "Not-Compliant"}
}