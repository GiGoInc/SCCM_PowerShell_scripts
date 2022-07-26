# "Firefox Deployment Files" Remediation Script #

$ErrorActionPreference = "Stop"

IF (Test-Path 'C:\Program Files\Mozilla Firefox')
{   
 # check if mozilla.cfg file exists, and create/recreate it
    if ((Test-Path 'C:\Program Files\Mozilla Firefox\mozilla.cfg') -eq $true)
      {
      try
        { Remove-Item 'C:\Program Files\Mozilla Firefox\mozilla.cfg' -Force -ErrorAction Stop | Out-Null }
      catch
        { $_.Exception.Message }
      }
    try
      {
      New-Item -Path 'C:\Program Files\Mozilla Firefox' -Name mozilla.cfg -ItemType File -Force -Value `
    '//Firefox Default Settings
    
    // Disable updater
    lockPref("app.update.enabled", false);
    // make absolutely sure it is really off
    lockPref("app.update.auto", false);
    lockPref("app.update.mode", 0);
    lockPref("app.update.service.enabled", false);
    
    // Disable Add-ons compatibility checking
    clearPref("extensions.lastAppVersion"); 
    
    // Do NOT show KNOW YOUR RIGHTS on first run
    pref("browser.rights.3.shown", true);
    
    // Do NOT show WhatsNew on first run after every update
    pref("browser.startup.homepage_override.mstone","ignore");
    
    // Set default homepage - users can change
    // Requires a complex preference
    defaultPref("browser.startup.homepage","data:text/plain,browser.startup.homepage=http://thesource");
    
    // Disable the internal PDF viewer
    pref("pdfjs.disabled", true);
    
    // Disable the flash to javascript converter
    pref("shumway.disabled", true);
    
    // Do NOT ask to install the Flash plugin
    pref("plugins.notifyMissingFlash", false);
    
    // Disable health reporter
    lockPref("datareporting.healthreport.service.enabled", false);
    
    // Disable all data upload (Telemetry and FHR)
    lockPref("datareporting.policy.dataSubmissionEnabled", false);
    
    // Disable crash reporter
    lockPref("toolkit.crashreporter.enabled", false);
    Components.classes["@mozilla.org/toolkit/crash-reporter;1"].getService(Components.interfaces.nsICrashReporter).submitReports = false; 
    
    // Default NLTM Authentication
    defaultPref("network.automatic-ntlm-auth.trusted-uris", "http://hbonline,http://thesource");
    
    // Disable check for Firefox as default browser
    lockPref("browser.shell.checkDefaultBrowser", false);' | Out-Null
      }
      catch
      { $_.Exception.Message }
    
  
 # check if C:\Program Files\Mozilla Firefox\browser exists, if not create it
    if ((Test-Path 'C:\Program Files\Mozilla Firefox\browser') -eq $false)
      {
    #  write-host "C:\Program Files\Mozilla Firefox\browser doesn't exist.  Let's create it..."
      try
        { New-Item -Path 'C:\Program Files\Mozilla Firefox\browser' -ItemType Directory -Force -ErrorAction Stop | Out-Null }
      catch
        { $_.Exception.Message }
      }
    else
      {}
    
    # check if override.ini file exists, and create/recreate it
    if ((Test-Path 'C:\Program Files\Mozilla Firefox\browser\override.ini') -eq $true)
      {
      try
        { Remove-Item 'C:\Program Files\Mozilla Firefox\browser\override.ini' -Force -ErrorAction Stop | Out-Null }
      catch
        { $_.Exception.Message }
      }
    try
      {
      New-Item -Path 'C:\Program Files\Mozilla Firefox\browser' -Name override.ini -ItemType File -Force -Value `
    '[XRE]
    EnableProfileMigrator=false' | Out-Null
      }
      catch
      { $_.Exception.Message }


 # check if C:\Program Files\Mozilla Firefox\defaults\pref exists, if not create it
    if ((Test-Path 'C:\Program Files\Mozilla Firefox\defaults\pref') -eq $false)
      {
    #  write-host "C:\Program Files\Mozilla Firefox\defaults\pref doesn't exist.  Let's create it..."
      try
        { New-Item -Path 'C:\Program Files\Mozilla Firefox\defaults\pref' -ItemType Directory -Force -ErrorAction Stop | Out-Null }
      catch
        { $_.Exception.Message }
      }
    else
      {}
    
    # check if override.ini file exists, and create/recreate it
    if ((Test-Path 'C:\Program Files\Mozilla Firefox\defaults\pref\local-settings.js') -eq $true)
      {
      try
        { Remove-Item 'C:\Program Files\Mozilla Firefox\defaults\pref\local-settings.js' -Force -ErrorAction Stop | Out-Null }
      catch
        { $_.Exception.Message }
      }
    try
      {
      New-Item -Path 'C:\Program Files\Mozilla Firefox\defaults\pref' -Name local-settings.js -ItemType File -Force -Value `
    'pref("general.config.filename", "mozilla.cfg");
pref("general.config.obscure_value", 0);' | Out-Null
      }
      catch
      { $_.Exception.Message }
}



IF (Test-Path 'C:\Program Files (x86)\Mozilla Firefox')
{   
 # check if mozilla.cfg file exists, and create/recreate it
    if ((Test-Path 'C:\Program Files (x86)\Mozilla Firefox\mozilla.cfg') -eq $true)
      {
      try
        { Remove-Item 'C:\Program Files (x86)\Mozilla Firefox\mozilla.cfg' -Force -ErrorAction Stop | Out-Null }
      catch
        { $_.Exception.Message }
      }
    try
      {
      New-Item -Path 'C:\Program Files (x86)\Mozilla Firefox' -Name mozilla.cfg -ItemType File -Force -Value `
    '//Firefox Default Settings
    
    // Disable updater
    lockPref("app.update.enabled", false);
    // make absolutely sure it is really off
    lockPref("app.update.auto", false);
    lockPref("app.update.mode", 0);
    lockPref("app.update.service.enabled", false);
    
    // Disable Add-ons compatibility checking
    clearPref("extensions.lastAppVersion"); 
    
    // Do NOT show KNOW YOUR RIGHTS on first run
    pref("browser.rights.3.shown", true);
    
    // Do NOT show WhatsNew on first run after every update
    pref("browser.startup.homepage_override.mstone","ignore");
    
    // Set default homepage - users can change
    // Requires a complex preference
    defaultPref("browser.startup.homepage","data:text/plain,browser.startup.homepage=http://thesource");
    
    // Disable the internal PDF viewer
    pref("pdfjs.disabled", true);
    
    // Disable the flash to javascript converter
    pref("shumway.disabled", true);
    
    // Do NOT ask to install the Flash plugin
    pref("plugins.notifyMissingFlash", false);
    
    // Disable health reporter
    lockPref("datareporting.healthreport.service.enabled", false);
    
    // Disable all data upload (Telemetry and FHR)
    lockPref("datareporting.policy.dataSubmissionEnabled", false);
    
    // Disable crash reporter
    lockPref("toolkit.crashreporter.enabled", false);
    Components.classes["@mozilla.org/toolkit/crash-reporter;1"].getService(Components.interfaces.nsICrashReporter).submitReports = false; 
    
    // Default NLTM Authentication
    defaultPref("network.automatic-ntlm-auth.trusted-uris", "http://hbonline,http://thesource");
    
    // Disable check for Firefox as default browser
    lockPref("browser.shell.checkDefaultBrowser", false);' | Out-Null
      }
      catch
      { $_.Exception.Message }
    
  
 # check if C:\Program Files (x86)\Mozilla Firefox\browser exists, if not create it
    if ((Test-Path 'C:\Program Files (x86)\Mozilla Firefox\browser') -eq $false)
      {
    #  write-host "C:\Program Files (x86)\Mozilla Firefox\browser doesn't exist.  Let's create it..."
      try
        { New-Item -Path 'C:\Program Files (x86)\Mozilla Firefox\browser' -ItemType Directory -Force -ErrorAction Stop | Out-Null }
      catch
        { $_.Exception.Message }
      }
    else
      {}
    
    # check if override.ini file exists, and create/recreate it
    if ((Test-Path 'C:\Program Files (x86)\Mozilla Firefox\browser\override.ini') -eq $true)
      {
      try
        { Remove-Item 'C:\Program Files (x86)\Mozilla Firefox\browser\override.ini' -Force -ErrorAction Stop | Out-Null }
      catch
        { $_.Exception.Message }
      }
    try
      {
      New-Item -Path 'C:\Program Files (x86)\Mozilla Firefox\browser' -Name override.ini -ItemType File -Force -Value `
    '[XRE]
    EnableProfileMigrator=false' | Out-Null
      }
      catch
      { $_.Exception.Message }


 # check if C:\Program Files (x86)\Mozilla Firefox\defaults\pref exists, if not create it
    if ((Test-Path 'C:\Program Files (x86)\Mozilla Firefox\defaults\pref') -eq $false)
      {
    #  write-host "C:\Program Files (x86)\Mozilla Firefox\defaults\pref doesn't exist.  Let's create it..."
      try
        { New-Item -Path 'C:\Program Files (x86)\Mozilla Firefox\defaults\pref' -ItemType Directory -Force -ErrorAction Stop | Out-Null }
      catch
        { $_.Exception.Message }
      }
    else
      {}
    
    # check if override.ini file exists, and create/recreate it
    if ((Test-Path 'C:\Program Files (x86)\Mozilla Firefox\defaults\pref\local-settings.js') -eq $true)
      {
      try
        { Remove-Item 'C:\Program Files (x86)\Mozilla Firefox\defaults\pref\local-settings.js' -Force -ErrorAction Stop | Out-Null }
      catch
        { $_.Exception.Message }
      }
    try
      {
      New-Item -Path 'C:\Program Files (x86)\Mozilla Firefox\defaults\pref' -Name local-settings.js -ItemType File -Force -Value `
    'pref("general.config.filename", "mozilla.cfg");
pref("general.config.obscure_value", 0);' | Out-Null
      }
      catch
      { $_.Exception.Message }
}
