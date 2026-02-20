$AppxProvisionedPackage = Get-AppxProvisionedPackage -online | Select PackageName
}
If ($JunkAppX -match '.*Microsoft.ZuneVideo.*')                   {Remove-AppxPackage -Package $JunkAppX -AllUsers}
$AppxProvisionedPackage = Get-AppxProvisionedPackage -online | Select PackageName
$AppxPackages = Get-AppxPackage -AllUsers

ForEach ($App in $Apps)
{
$Junk = $App.PackageName
If ($Junk -match '.*Microsoft.3DBuilder.*')                   {Remove-AppxProvisionedPackage -Online -PackageName $Junk -AllUsers}
If ($Junk -match '.*Microsoft.BingWeather.*')                 {Remove-AppxProvisionedPackage -Online -PackageName $Junk -AllUsers}
If ($Junk -match '.*Microsoft.DesktopAppInstaller.*')         {Remove-AppxProvisionedPackage -Online -PackageName $Junk -AllUsers}
If ($Junk -match '.*Microsoft.GetHelp.*')                     {Remove-AppxProvisionedPackage -Online -PackageName $Junk -AllUsers}
If ($Junk -match '.*Microsoft.Getstarted.*')                  {Remove-AppxProvisionedPackage -Online -PackageName $Junk -AllUsers}
If ($Junk -match '.*Microsoft.Messaging.*')                   {Remove-AppxProvisionedPackage -Online -PackageName $Junk -AllUsers}
If ($Junk -match '.*Microsoft.Microsoft3DViewer.*')           {Remove-AppxProvisionedPackage -Online -PackageName $Junk -AllUsers}
If ($Junk -match '.*Microsoft.MicrosoftOfficeHub.*')          {Remove-AppxProvisionedPackage -Online -PackageName $Junk -AllUsers}
If ($Junk -match '.*Microsoft.MicrosoftSolitaireCollection.*'){Remove-AppxProvisionedPackage -Online -PackageName $Junk -AllUsers}
If ($Junk -match '.*Microsoft.MicrosoftStickyNotes.*')        {Remove-AppxProvisionedPackage -Online -PackageName $Junk -AllUsers}
If ($Junk -match '.*Microsoft.Office.OneNote.*')              {Remove-AppxProvisionedPackage -Online -PackageName $Junk -AllUsers}
If ($Junk -match '.*Microsoft.OneConnect.*')                  {Remove-AppxProvisionedPackage -Online -PackageName $Junk -AllUsers}
If ($Junk -match '.*Microsoft.People.*')                      {Remove-AppxProvisionedPackage -Online -PackageName $Junk -AllUsers}
If ($Junk -match '.*Microsoft.Print3D.*')                     {Remove-AppxProvisionedPackage -Online -PackageName $Junk -AllUsers}
If ($Junk -match '.*Microsoft.SkypeApp.*')                    {Remove-AppxProvisionedPackage -Online -PackageName $Junk -AllUsers}
If ($Junk -match '.*Microsoft.StorePurchaseApp.*')            {Remove-AppxProvisionedPackage -Online -PackageName $Junk -AllUsers}
If ($Junk -match '.*Microsoft.Wallet.*')                      {Remove-AppxProvisionedPackage -Online -PackageName $Junk -AllUsers}
If ($Junk -match '.*microsoft.windowscommunicationsapps.*')   {Remove-AppxProvisionedPackage -Online -PackageName $Junk -AllUsers}
If ($Junk -match '.*Microsoft.WindowsFeedbackHub.*')          {Remove-AppxProvisionedPackage -Online -PackageName $Junk -AllUsers}
If ($Junk -match '.*Microsoft.WindowsMaps.*')                 {Remove-AppxProvisionedPackage -Online -PackageName $Junk -AllUsers}
If ($Junk -match '.*Microsoft.WindowsStore.*')                {Remove-AppxProvisionedPackage -Online -PackageName $Junk -AllUsers}
If ($Junk -match '.*Microsoft.Xbox.TCUI.*')                   {Remove-AppxProvisionedPackage -Online -PackageName $Junk -AllUsers}
If ($Junk -match '.*Microsoft.XboxApp.*')                     {Remove-AppxProvisionedPackage -Online -PackageName $Junk -AllUsers}
If ($Junk -match '.*Microsoft.XboxGameOverlay.*')             {Remove-AppxProvisionedPackage -Online -PackageName $Junk -AllUsers}
If ($Junk -match '.*Microsoft.XboxIdentityProvider.*')        {Remove-AppxProvisionedPackage -Online -PackageName $Junk -AllUsers}
If ($Junk -match '.*Microsoft.XboxSpeechToTextOverlay.*')     {Remove-AppxProvisionedPackage -Online -PackageName $Junk -AllUsers}
If ($Junk -match '.*Microsoft.ZuneMusic.*')                   {Remove-AppxProvisionedPackage -Online -PackageName $Junk -AllUsers}
If ($Junk -match '.*Microsoft.ZuneVideo.*')                   {Remove-AppxProvisionedPackage -Online -PackageName $Junk -AllUsers}
}


ForEach ($AppX in $AppxPackages)
{
$JunkAppX = $AppX.PackageFullName
If ($JunkAppX -match '.*Microsoft.3DBuilder.*')                   {Remove-AppxPackage -Package $JunkAppX -AllUsers}
If ($JunkAppX -match '.*Microsoft.BingWeather.*')                 {Remove-AppxPackage -Package $JunkAppX -AllUsers}
If ($JunkAppX -match '.*Microsoft.DesktopAppInstaller.*')         {Remove-AppxPackage -Package $JunkAppX -AllUsers}
If ($JunkAppX -match '.*Microsoft.GetHelp.*')                     {Remove-AppxPackage -Package $JunkAppX -AllUsers}
If ($JunkAppX -match '.*Microsoft.Getstarted.*')                  {Remove-AppxPackage -Package $JunkAppX -AllUsers}
If ($JunkAppX -match '.*Microsoft.Messaging.*')                   {Remove-AppxPackage -Package $JunkAppX -AllUsers}
If ($JunkAppX -match '.*Microsoft.Microsoft3DViewer.*')           {Remove-AppxPackage -Package $JunkAppX -AllUsers}
If ($JunkAppX -match '.*Microsoft.MicrosoftOfficeHub.*')          {Remove-AppxPackage -Package $JunkAppX -AllUsers}
If ($JunkAppX -match '.*Microsoft.MicrosoftSolitaireCollection.*'){Remove-AppxPackage -Package $JunkAppX -AllUsers}
If ($JunkAppX -match '.*Microsoft.MicrosoftStickyNotes.*')        {Remove-AppxPackage -Package $JunkAppX -AllUsers}
If ($JunkAppX -match '.*Microsoft.Office.OneNote.*')              {Remove-AppxPackage -Package $JunkAppX -AllUsers}
If ($JunkAppX -match '.*Microsoft.OneConnect.*')                  {Remove-AppxPackage -Package $JunkAppX -AllUsers}
If ($JunkAppX -match '.*Microsoft.People.*')                      {Remove-AppxPackage -Package $JunkAppX -AllUsers}
If ($JunkAppX -match '.*Microsoft.Print3D.*')                     {Remove-AppxPackage -Package $JunkAppX -AllUsers}
If ($JunkAppX -match '.*Microsoft.SkypeApp.*')                    {Remove-AppxPackage -Package $JunkAppX -AllUsers}
If ($JunkAppX -match '.*Microsoft.StorePurchaseApp.*')            {Remove-AppxPackage -Package $JunkAppX -AllUsers}
If ($JunkAppX -match '.*Microsoft.Wallet.*')                      {Remove-AppxPackage -Package $JunkAppX -AllUsers}
If ($JunkAppX -match '.*microsoft.windowscommunicationsapps.*')   {Remove-AppxPackage -Package $JunkAppX -AllUsers}
If ($JunkAppX -match '.*Microsoft.WindowsFeedbackHub.*')          {Remove-AppxPackage -Package $JunkAppX -AllUsers}
If ($JunkAppX -match '.*Microsoft.WindowsMaps.*')                 {Remove-AppxPackage -Package $JunkAppX -AllUsers}
If ($JunkAppX -match '.*Microsoft.WindowsStore.*')                {Remove-AppxPackage -Package $JunkAppX -AllUsers}
If ($JunkAppX -match '.*Microsoft.Xbox.TCUI.*')                   {Remove-AppxPackage -Package $JunkAppX -AllUsers}
If ($JunkAppX -match '.*Microsoft.XboxApp.*')                     {Remove-AppxPackage -Package $JunkAppX -AllUsers}
If ($JunkAppX -match '.*Microsoft.XboxGameOverlay.*')             {Remove-AppxPackage -Package $JunkAppX -AllUsers}
If ($JunkAppX -match '.*Microsoft.XboxIdentityProvider.*')        {Remove-AppxPackage -Package $JunkAppX -AllUsers}
If ($JunkAppX -match '.*Microsoft.XboxSpeechToTextOverlay.*')     {Remove-AppxPackage -Package $JunkAppX -AllUsers}
If ($JunkAppX -match '.*Microsoft.ZuneMusic.*')                   {Remove-AppxPackage -Package $JunkAppX -AllUsers}
If ($JunkAppX -match '.*Microsoft.ZuneVideo.*')                   {Remove-AppxPackage -Package $JunkAppX -AllUsers}
}
