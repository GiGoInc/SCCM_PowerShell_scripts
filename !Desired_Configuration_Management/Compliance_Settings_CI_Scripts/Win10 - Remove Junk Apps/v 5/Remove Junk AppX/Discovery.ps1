$Num = 0
If ($Num -eq 0){Write-Host "Compliant"}Else{Write-Host "Not-Compliant"}

$Num = 0
$AppxProvisionedPackage = Get-AppxProvisionedPackage -online | Select PackageName
$AppxPackages = Get-AppxPackage -AllUsers

ForEach ($App in $Apps)
{
$Junk = $App.PackageName
If ($Junk -match '.*Microsoft.3DBuilder.*')                   {$Num++}
If ($Junk -match '.*Microsoft.BingWeather.*')                 {$Num++}
If ($Junk -match '.*Microsoft.DesktopAppInstaller.*')         {$Num++}
If ($Junk -match '.*Microsoft.GetHelp.*')                     {$Num++}
If ($Junk -match '.*Microsoft.Getstarted.*')                  {$Num++}
If ($Junk -match '.*Microsoft.Messaging.*')                   {$Num++}
If ($Junk -match '.*Microsoft.Microsoft3DViewer.*')           {$Num++}
If ($Junk -match '.*Microsoft.MicrosoftOfficeHub.*')          {$Num++}
If ($Junk -match '.*Microsoft.MicrosoftSolitaireCollection.*'){$Num++}
If ($Junk -match '.*Microsoft.MicrosoftStickyNotes.*')        {$Num++}
If ($Junk -match '.*Microsoft.Office.OneNote.*')              {$Num++}
If ($Junk -match '.*Microsoft.OneConnect.*')                  {$Num++}
If ($Junk -match '.*Microsoft.People.*')                      {$Num++}
If ($Junk -match '.*Microsoft.Print3D.*')                     {$Num++}
If ($Junk -match '.*Microsoft.SkypeApp.*')                    {$Num++}
If ($Junk -match '.*Microsoft.StorePurchaseApp.*')            {$Num++}
If ($Junk -match '.*Microsoft.Wallet.*')                      {$Num++}
If ($Junk -match '.*microsoft.windowscommunicationsapps.*')   {$Num++}
If ($Junk -match '.*Microsoft.WindowsFeedbackHub.*')          {$Num++}
If ($Junk -match '.*Microsoft.WindowsMaps.*')                 {$Num++}
If ($Junk -match '.*Microsoft.WindowsStore.*')                {$Num++}
If ($Junk -match '.*Microsoft.Xbox.TCUI.*')                   {$Num++}
If ($Junk -match '.*Microsoft.XboxApp.*')                     {$Num++}
If ($Junk -match '.*Microsoft.XboxGameOverlay.*')             {$Num++}
If ($Junk -match '.*Microsoft.XboxIdentityProvider.*')        {$Num++}
If ($Junk -match '.*Microsoft.XboxSpeechToTextOverlay.*')     {$Num++}
If ($Junk -match '.*Microsoft.ZuneMusic.*')                   {$Num++}
If ($Junk -match '.*Microsoft.ZuneVideo.*')                   {$Num++}
}


ForEach ($AppX in $AppxPackages)
{
$JunkAppX = $AppX.PackageFullName
If ($JunkAppX -match '.*Microsoft.3DBuilder.*')                   {$Num++}
If ($JunkAppX -match '.*Microsoft.BingWeather.*')                 {$Num++}
If ($JunkAppX -match '.*Microsoft.DesktopAppInstaller.*')         {$Num++}
If ($JunkAppX -match '.*Microsoft.GetHelp.*')                     {$Num++}
If ($JunkAppX -match '.*Microsoft.Getstarted.*')                  {$Num++}
If ($JunkAppX -match '.*Microsoft.Messaging.*')                   {$Num++}
If ($JunkAppX -match '.*Microsoft.Microsoft3DViewer.*')           {$Num++}
If ($JunkAppX -match '.*Microsoft.MicrosoftOfficeHub.*')          {$Num++}
If ($JunkAppX -match '.*Microsoft.MicrosoftSolitaireCollection.*'){$Num++}
If ($JunkAppX -match '.*Microsoft.MicrosoftStickyNotes.*')        {$Num++}
If ($JunkAppX -match '.*Microsoft.Office.OneNote.*')              {$Num++}
If ($JunkAppX -match '.*Microsoft.OneConnect.*')                  {$Num++}
If ($JunkAppX -match '.*Microsoft.People.*')                      {$Num++}
If ($JunkAppX -match '.*Microsoft.Print3D.*')                     {$Num++}
If ($JunkAppX -match '.*Microsoft.SkypeApp.*')                    {$Num++}
If ($JunkAppX -match '.*Microsoft.StorePurchaseApp.*')            {$Num++}
If ($JunkAppX -match '.*Microsoft.Wallet.*')                      {$Num++}
If ($JunkAppX -match '.*microsoft.windowscommunicationsapps.*')   {$Num++}
If ($JunkAppX -match '.*Microsoft.WindowsFeedbackHub.*')          {$Num++}
If ($JunkAppX -match '.*Microsoft.WindowsMaps.*')                 {$Num++}
If ($JunkAppX -match '.*Microsoft.WindowsStore.*')                {$Num++}
If ($JunkAppX -match '.*Microsoft.Xbox.TCUI.*')                   {$Num++}
If ($JunkAppX -match '.*Microsoft.XboxApp.*')                     {$Num++}
If ($JunkAppX -match '.*Microsoft.XboxGameOverlay.*')             {$Num++}
If ($JunkAppX -match '.*Microsoft.XboxIdentityProvider.*')        {$Num++}
If ($JunkAppX -match '.*Microsoft.XboxSpeechToTextOverlay.*')     {$Num++}
If ($JunkAppX -match '.*Microsoft.ZuneMusic.*')                   {$Num++}
If ($JunkAppX -match '.*Microsoft.ZuneVideo.*')                   {$Num++}
}

If ($Num -eq 0){Write-Host "Compliant"}Else{Write-Host "Not-Compliant"}
