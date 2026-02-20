# "mozilla.cfg Content" Remediation Script
  {$_}
catch
# "mozilla.cfg Content" Remediation Script

$list = '//Firefox Default Settings

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
lockPref("browser.shell.checkDefaultBrowser", false);'

try
  {
  If (Test-Path 'C:\Program Files\Mozilla Firefox')
  {
  $list | Out-file 'C:\Program Files\Mozilla Firefox\mozilla.cfg'-Encoding ASCII -Force
  }
  
  If (Test-Path 'C:\Program Files (x86)\Mozilla Firefox')
  {
  $list | Out-file 'C:\Program Files (x86)\Mozilla Firefox\mozilla.cfg'-Encoding ASCII -Force
  }
  } 
catch
  {$_}
