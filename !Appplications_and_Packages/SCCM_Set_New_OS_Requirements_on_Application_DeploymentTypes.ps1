$SSDate = (GET-DATE)
Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
$Sec = $Span.Seconds
$SSDate = (GET-DATE)
# STATIC INFO
$siteCode = "XX1"
$siteServer = "SERVER.DOMAIN.COM"
$OSReqsPairs = 'All Windows 10 (32-bit),Windows/All_x86_Windows_10_and_higher_Clients', `
              'All Windows 10 (64-bit),Windows/All_x64_Windows_10_and_higher_Clients', `
              'All Windows 10 (ARM64),Windows/All_ARM64_Windows_10_and_higher_Clients', `
              'All Windows 10 Enterprise multi-session,Windows/All_MultiSession_Enterprise_Windows_10_higher', `
              'All Windows 11 (64-bit),Windows/All_x64_Windows_11_and_higher_Clients', `
              'All Windows 11 (ARM64),Windows/All_ARM64_Windows_11_and_higher_Clients', `
              'All Windows 11 Enterprise multi-session,Windows/All_MultiSession_Enterprise_Windows_11_higher', `
              'All Windows Server 2003 (Non-R2) (32-bit),Windows/All_x86_Windows_Server_2003_Non_R2', `
              'All Windows Server 2003 (Non-R2) (64-bit),Windows/All_x64_Windows_Server_2003_Non_R2', `
              'All Windows Server 2003 R2 (32-bit),Windows/All_x86_Windows_Server_2003_R2', `
              'All Windows Server 2003 R2 (64-bit),Windows/All_x64_Windows_Server_2003_R2', `
              'All Windows Server 2008 (32-bit),Windows/All_x86_Windows_Server_2008', `
              'All Windows Server 2008 (Non-R2) (64-bit),Windows/All_x64_Windows_Server_2008', `
              'All Windows Server 2008 R2 (64-bit),Windows/All_x64_Windows_Server_2008_R2', `
              'All Windows Server 2012 (64-bit),Windows/All_x64_Windows_Server_8', `
              'All Windows Server 2012 R2 (64-bit),Windows/All_x64_Windows_Server_2012_R2', `
              'All Windows Server 2016 and higher (64-bit),Windows/All_x64_Windows_Server_2016', `
              'All Windows Server 2019 and higher (64-bit),Windows/All_x64_Windows_Server_2019_and_higher', `
              'All Windows Server 2022 and higher (64-bit),Windows/All_x64_Windows_Server_2022_and_higher', `
              'Windows Server 2003 R2 SP2 (32-bit),Windows/x86_Windows_Server_2003_R2_SP2', `
              'Windows Server 2003 R2 SP2 (64-bit),Windows/x64_Windows_Server_2003_R2_SP2', `
              'Windows Server 2003 SP2 (32-bit),Windows/x86_Windows_Server_2003_SP2', `
              'Windows Server 2003 SP2 (64-bit),Windows/x64_Windows_Server_2003_SP2', `
              'Windows Server 2008 R2 (64-bit),Windows/x64_Windows_Server_2008_R2', `
              'Windows Server 2008 R2 Core (64-bit),Windows/x64_Windows_Server_2008_R2_CORE', `
              'Windows Server 2008 R2 SP1 (64-bit),Windows/x64_Windows_Server_2008_R2_SP1', `
              'Windows Server 2008 R2 SP1 Core (64-bit),Windows/x64_Windows_Server_2008_R2_SP1_Core', `
              'Windows Server 2008 SP2 (32-bit),Windows/x86_Windows_Server_2008_SP2', `
              'Windows Server 2008 SP2 (64-bit),Windows/x64_Windows_Server_2008_SP2', `
              'Windows Server 2008 SP2 Core (64-bit),Windows/x64_Windows_Server_2008_SP2_Core'

############################################################################################
############################################################################################

$SiteCode = "XX1"
$SiteServer = "SERVER.DOMAIN.COM"

$SCCMPaths = 'C:\Program Files (x86)\Microsoft Endpoint Manager\AdminConsole\bin\ConfigurationManager.psd1', "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"            
$SCCMPaths | % { If (Test-Path "$_") { Import-Module "$_"  -Force }}

if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
New-PSDrive -name $SiteCode -psprovider CMSite  -Root $SiteServer 
}
Set-Location "$($SiteCode):\"


############################################################################################
############################################################################################
# VARIABLES

$AppNames = 'Eclipse Enterprise Java 4.18.0', `
'Eclipse Neon', `
'e-Form RS', `
'Elastica Auth Plugin_1.0.2.0', `
'Empyrean ALM 20.5.2.374', `
'Empyrean ALM 21.12.0.332', `
'Encompass 360 2018', `
'Encompass 360 Installation File', `
'Entrust IdentityGuard Soft Token', `
'Epson TM-S9000 Multifunction APP2 Device', `
'Epson TM-S9000 Multifunction APP2 Device 3.04', `
'eSignal', `
'EVP Office', `
'EVP Office 8.5.1', `
'FactSet', `
'FactSet 2016.25', `
'FactSet 2016.31', `
'FECFile', `
'FileZilla FTP Client', `
'Firefox - (Current)', `
'FIS Authenticator 2.2.3', `
'Five9 - Contact Center Install', `
'Five9 - Contact Center Install for TS', `
'Five9 - Contact Center Install v2 for TS', `
'Five9 - Non-Contact Center Install', `
'Five9 Cloud Bridge', `
'Five9 Cloud Bridge for TS', `
'Five9 Connectivity Assessment Test', `
'Five9 installs - with Softphone', `
'Five9 installs - without Softphone', `
'Five9 Plus Adapter for Agent Desktop Toolkit - Extensions', `
'Five9 Screenpop Connector', `
'Five9 Screenpop Connector for TS', `
'Five9 Softphone', `
'Five9 Softphone Disable - Enable', `
'FlexTerm 64-bit', `
'FlexTerm RemoteLocale', `
'FlexTerm License', `
'FlexTerm Optimus RemoteLocale', `
'FOSCAM HD IP Camera Components', `
'Fuzzy Lookup Add-In for Excel', `
'Gasper Exchange', `
'Git for Windows 2.30.2', `
'Google Chrome 32-bit', `
'Google Chrome 64-bit', `
'Google Earth', `
'Google Earth Pro', `
'DOMAIN Part2 COWAM Session', `
'DOMAIN Part2 PepPlus Sessions', `
'DOMAIN Part2 Test Sessions', `
'DOMAIN Part2 Training Sessions', `
'Handbrake', `
'HEIF-Image-Extensions', `
'HID Approve for Windows', `
'HP DisplayLink Core Software', `
'HP Quality Center Excel AddIn 12.55', `
'HP Sprinter 14.1', `
'HPE Unified Functional Testing', `
'HSF Client', `
'DOMAIN Treasury Access', `
'DOMAIN Treasury Access Browser Cert', `
'DOMAIN Treasury Access Prod', `
'HxD', `
'Hyland ActiveX', `
'Hyland App Enabler for AP', `
'Hyland OnBase Client', `
'Hyland OnBase Test Client', `
'Hyland Unity Client', `
'IBM DB2', `
'IdeaMax', `
'iGel Universal Management Suite', `
'InfeauxNet', `
'INFO-ACCESS', `
'InfoPrint AFP Workbench Viewer', `
'InstEd', `
'IntelliJ IDEA Community Edition 2022.2', `
'InterSystemsCacheODBC32bit', `
'InterSystemsCacheODBC64bit', `
'ISIS', `
'Java 8.x 32-bit - (Current)', `
'Java 8.x 64-bit - (Current)', `
'Java SE Dev Kit 8', `
'Katalon Studio', `
'LaserPro RDP', `
'LeasePlus V3 Prod', `
'LexisNexis CounselLink for Microsoft Outlook', `
'Maestro Desktop 6.0.5i', `
'Maestro Integrator and SDK', `
'Market Axess', `
'Maven', `
'MiCollab', `
'Micro Focus Sprinter', `
'Microsoft Access Database Engine 2016 x64', `
'Microsoft Command Line Utilities 15 for SQL Server', `
'Microsoft ODBC Driver 17 for SQL Server', `
'Microsoft Office Pro Plus 2016 x64', `
'Microsoft Power BI Desktop', `
'Microsoft Remote Server Administration Tools', `
'Microsoft SQL Server 2016 ADOMD.NET', `
'Microsoft SQL Server 2016 ADOMD.NET 32bit', `
'Microsoft SQL Server 2016 Analysis Management Objects', `
'Microsoft SQL Server 2016 Analysis Management Objects 32bit', `
'Microsoft Visual C PlusPlus 2005 x86 8.0.61001', `
'Microsoft Visual C PlusPlus 2010 x86 10.0.30319', `
'Microsoft Visual C PlusPlus 2012', `
'Microsoft Visual C PlusPlus 2013 x64', `
'Microsoft Visual C PlusPlus 2013 x86', `
'Microsoft Visual C PlusPlus 2015 x64', `
'Microsoft Visual C PlusPlus 2015 x86', `
'Microsoft Visual C PlusPlus 2017 x86', `
'Microsoft Visual Studio Pro 2013', `
'Monarch 2022', `
'Moody Portfolio Manager', `
'Moodys Add-In for Excel', `
'Morningstar Add-in 9.0.2', `
'Morningstar Direct 3.20.017', `
'Mozilla Firefox 72.0.1', `
'MRWin6530', `
'MS Script Debugger', `
'Nasdaq OfficeSuite', `
'NCR Transfer Manager', `
'Neo4j', `
'Noble SIPhone Biz Agent', `
'Noble SIPhone Biz Manager', `
'Notepad++ - (Current)', `
'Office 365 Current Channel v2201', `
'Office Professional Plus 2016 (64-bit)', `
'Office Professional Plus 2016 (64-bit) for TS', `
'OneSource Income Tax Excel Addin', `
'Open XML SDK 2.5 for Microsoft Office', `
'OpenJDK 11', `
'OpenText eDOCS DM 16.4 Extensions (x64)', `
'Oracle Hyperion Smart View 11.1.2.2.310', `
'Oracle ODBC x64', `
'Oracle SQL Developer', `
'OracleODBC32bit', `
'PAYplus Connect BSA Prod', `
'PAYplus Connect BSA Test', `
'PAYplus Connect GFX Prod', `
'PAYplus Connect GFX Test', `
'PAYplus PM Client Prod', `
'PAYplus PM Client Test', `
'PC Meter Connect', `
'PDF Password Remover', `
'PentaCalc Pro', `
'PeopleImport', `
'PeopleSoft PeopleTools ODBC', `
'PF Batch Export', `
'Piktochart', `
'Plantronics Hub', `
'Plotagon Studio', `
'Polycom RealPresence Desktop', `
'Power BI Desktop', `
'Power BI Desktop RS May 2022', `
'Power Query for Excel', `
'PowerShell 7-x64', `
'Printer Installer Client', `
'Printer Logic Client', `
'Privilege Management for Windows (x64) 21.6.153.0', `
'Project Pro 2016 64bit', `
'PSexec', `
'Putty .73 64 bit', `
'PuTTY release 0.66', `
'Python', `
'Python 3.9.0', `
'R for Windows 4.2.1', `
'Rapid7 Insight Agent', `
'RazorSQL 10.3', `
'reaConverter 7 Pro', `
'Real-Time Monitoring Tool', `
'Reboot', `
'Redirector 2017', `
'Remove Zoom From Startup', `
'Report Builder 3.0', `
'RSA SecurID', `
'RStudio 1.1.383', `
'Safari 5.1', `
'SageLamp ZoomIn', `
'SalesForce bookmarks', `
'Salesforce CLI', `
'Salesforce Data Loader', `
'Salesforce DevTools', `
'Salesforce Inspector', `
'SecureCRT', `
'SecureCRTSecureFX', `
'SecureFX', `
'SkyHigh Client Proxy', `
'Smart View for Office', `
'Smartcrypt Reader', `
'SnagIt 12.4', `
'SnagIt 2018', `
'Snow Inventory Agent_Test_6.5.0', `
'SoapUI 5.3 64bit', `
'SoapUI 5.6', `
'SolarWinds 2000 Professional Plus', `
'SolarWinds Toolset v11.0.1', `
'Sourcetree', `
'SpeechExec Pro Dictate', `
'SpeechExec Transcription', `
'SQL Developer 20.2', `
'SQL Management Studio 17.2', `
'SQL Mobile Report Publisher', `
'SQL Server Data Tools VS 2017', `
'SQL Server Mgt Studio 18', `
'SQL Sys CLR Types', `
'SSMA for Access', `
'Stata 16', `
'SuperTRUMP', `
'Synkronizer 11.1', `
'SYSB for Attachmate Extra', `
'SYSB for Reflection Desktop', `
'Tableau 10.3', `
'Tableau 10.3 Oracle Driver', `
'Tableau 2022.2', `
'Tableau Creator', `
'Tableau Desktop 2018', `
'Tableau Reader 2022.2', `
'TCC Client', `
'TDconnect', `
'TeamMate AM 12.3 Audit Prod', `
'TeamMate AM 12.3 Audit Test', `
'TeamMate AM 12.3 Desktop', `
'Teammate AM 12.3 EWP Reader', `
'TeamMate AM 12.3 Risk Prod', `
'TeamMate AM 12.3 Risk Test', `
'TeamMate Analytics', `
'TeamMate R11.1U3 EWP Reader', `
'Teams', `
'APP2 H', `
'TelSpanWeb Screen Sharing', `
'Thomson Reuters ONESOURCE Excel Addin', `
'Tic Tie Calculate', `
'TortoiseSVN 64bit', `
'TortoiseSVN with CLI', `
'Trellix Agent', `
'Trust Wealth Mgmt URLs', `
'TrustDesk', `
'TrustDesk Update 12.15.00', `
'Turboswift', `
'UFT Add-in for ALM', `
'UltiPro for WNB', `
'UniConvertor', `
'VBI Recorder', `
'Vector Cash 4.2.1', `
'Verifone Driver', `
'VerifoneUnifiedDriverInstaller64 Build 3', `
'Veritas Enterprise Vault Discovery Accelerator Client 12.4.0.1105', `
'Veritas Enterprise Vault Discovery Accelerator Client 14.1.1.1165', `
'Veritas Enterprise Vault Outlook Add-in 12.4', `
'Veritas Enterprise Vault Outlook Add-in 14.2.0.1226', `
'Vid-Center', `
'Video Inspector', `
'Viking IP Programming', `
'VIP Access', `
'Virtual Observer Agent Client', `
'Virtual Observer Agent Client USER MUST BE LOGGED OUT', `
'VirtualBox', `
'Visio Standard 2016 32bit', `
'Visio Standard 2016 64bit', `
'Visual Studio Code 1.67.0', `
'Visual Studio Professional 2017', `
'VLC Media Player 3.0.11 (x64)', `
'WalkMe', `
'WalkMe Editor', `
'WalkMe IE and Chrome extensions', `
'WinMerge 2.16.6', `
'WinSCP 5.17', `
'WinSQL Lite', `
'WinZip 27.0', `
'WNB Law SQL Alias', `
'Workshare Professional', `
'Workshare Professional', `
'X Series Assistant', `
'XL-Connector', `
'XMLSpy 2020 Pro', `
'Zephyr StyleADVISOR'

$OSReqs = 'All Windows 11 (64-bit)'

############################################################################################
############################################################################################
$i = 1
# CHECK APPLICATION(s)
$total  = $appnames.count
ForEach ($AppName in $AppNames) {
    $SDate = (GET-DATE)
    $Appdt = Get-CMApplication -Name $appName
      $xml = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::DeserializeFromString($appdt.SDMPackageXML,$True)
    
    $numDTS = $xml.DeploymentTypes.count
       $dts = $xml.DeploymentTypes
Write-Host "$i of $total`t$AppName" -ForegroundColor Yellow
# CHECK OS REQUIREMENT(S)
    ForEach ($OSReq in $OSReqs) {

# CHECK LIST OF OS 
        ForEach ($Pair in $OSReqsPairs)
        {
             $Name = $Pair.split(',')[0]
            $Value = $Pair.split(',')[1]
            If ($OSReq -eq $Name)
            {

                # Write-Host "Operand: $Name" -ForegroundColor Cyan
                # Write-Host "Value:   $Value" -ForegroundColor Yellow
                foreach ($dt in $dts)
                {
                    foreach($requirement in $dt.Requirements)
                    {
                        if($requirement.Expression.gettype().name -eq 'OperatingSystemExpression') 
                        {
                            # Write-Host "$AppName -- Found OperatingSystemExpression"
                            If ($requirement.Name -Notlike "*$OSReq*" -and $requirement.Name)
                            {
                                Write-Host "Found an OS Requirement, appending value to it"
                                $requirement.Expression.Operands.Add("$Value")
                                $requirement.Name = [regex]::replace($requirement.Name, '(?<=Operating system One of {)(.*)(?=})', "`$1, $Name")
                                $null = $dt.Requirements.Remove($requirement)
                                $requirement.RuleId = "Rule_$([guid]::NewGuid())"
                                $null = $dt.Requirements.Add($requirement)
                                Break
                            }
                        }
                    }
                }
                $UpdatedXML = [Microsoft.ConfigurationManagement.ApplicationManagement.Serialization.SccmSerializer]::SerializeToString($XML, $True) 
                $appdt.SDMPackageXML = $UpdatedXML 
                $appdt.put()
                $t = Set-CMApplication -InputObject $appDT -PassThru
            }
    }}
$EDate = (GET-DATE)
$Span = NEW-TIMESPAN –Start $SDate –End $EDate
$Min = $Span.minutes
$Sec = $Span.Seconds
Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
$i++
}

############################################################################################
Set-Location c:

$SEDate = (GET-DATE)
$Span = NEW-TIMESPAN –Start $SDate –End $EDate
$Min = $Span.minutes
$Sec = $Span.Seconds
Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
