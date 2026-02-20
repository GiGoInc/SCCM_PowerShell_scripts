# Variables
#>

# Variables
#Get current working paths
$CurrentDirectory = split-path $MyInvocation.MyCommand.Path
$ScriptName = $MyInvocation.MyCommand.Name
$ADate = Get-Date -Format "yyyy-MM-dd__hh.mm.ss.tt"

########################################################################################################################################
########################################################################################################################################
# Use saved password are $Cred
########################################################################################################################################
$user = 'DOMAIN\aUSER1'
$PassFile = "C:\Scripts\ats_securestring.txt"
# Check for Password file
    If (!(Test-Path $PassFile))
                                                                                    {
    Write-Host ""
    Write-Host "Hey, dum dum it doesn't look like the password file " -NoNewline -ForegroundColor Cyan  
    Write-host "C:\Scripts\ats_securestring.txt " -ForegroundColor Green  -NoNewline
    Write-Host "exists..." -ForegroundColor Cyan  
    Write-Host ""
    Write-Host "You need to either generate it like this: " -ForegroundColor Cyan
    Write-Host ""
    Write-Host '# Create encrypted password'
    Write-Host "Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File `"$PassFile`""
    Write-Host ""
    Write-Host "....or modify it's location in this script!!!" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Also, make sure you change the username for the file from " -NoNewline -ForegroundColor Green
    Write-Host "`"$user`" " -NoNewline -ForegroundColor Red
    Write-Host "to yours!!!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Action cancelled." -ForegroundColor Red
    Read-Host -Prompt 'Press Enter to exit...'
    Exit
}

$ErrorActionPreference = 'Stop'
Try { $Global:cred = New-Object System.Management.Automation.PsCredential $user,(Get-Content $PassFile | ConvertTo-SecureString) }
                        Catch { 
    $errr = [string]$error[0]
    Write-Host "`n`nERROR: $errr"  -ForegroundColor Red
    Write-Host 'Recreate encrypted password:'
    Write-Host "Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File `"$PassFile`"" -ForegroundColor Green
    Exit
}
Finally { $ErrorActionPreference = 'Continue' }
########################################################################################################################################
########################################################################################################################################

# Variables for file log creation
$SCCMFile = "$CurrentDirectory\SCCM_Report.csv"

  $ReportingURL = 'http://SERVER/ReportServer?%2FConfigMgr_XX1%2F'
        $Folder = 'DOMAIN%20Part2%2F'
   $ReportPart1 = 'COM%20-%20Computers%20with%20specific%20software%20(with%20Product%20Version)&filterwildcard='
    $Parameter1 = 'Intel(R) Management Engine Components'
   $ReportPart2 = '&CollID='
    $Parameter2 = 'XX100010'
   #$ReportPart3 = '&rs%3AParameterLanguage=en-US'
        $URLEnd = '&rs:ParameterLanguage=en-US&rs:Command=Render&rs:Format=CSV&rc:Toolbar=False'


# Generate SCCM Report to current directory
#Invoke-WebRequest "http://SERVER/ReportServer?%2fConfigMgr_XX1%2fDOMAIN+Part2%2fCOM+-+The+Works+(PC+to+User+to+Model+to+OS+to+Client+Status)&rs:Command=Render&rs:Format=CSV&rc:Toolbar=False" -credential $creds -outfile $SCCMFile

$CompleteURL = "$ReportingURL$Folder$ReportPart1$Parameter1$ReportPart2$Parameter2$URLEnd"

Invoke-WebRequest $CompleteURL -credential $creds -outfile $SCCMFile -TimeoutSec 600

#'http://SERVER/ReportServer?%2FConfigMgr_XX1%2FSoftware%20Distribution%20-%20Application%20Monitoring%2FAll%20application%20deployments%20(basic)&FourthParameter=0&ThirdParameter=XX100504&TimeFrame=30&ChooseBy='+$CollectionName+'&SecondParameter=%25&SuccessPct=0&Administrator=All&rs%3AParameterLanguage=en-US&rs:Command=Render&rs:Format=CSV&rc:Toolbar=False' -credential $creds -outfile $SCCMFile

#Invoke-WebRequest 'http://SERVER/ReportServer?%2FConfigMgr_XX1%2FSoftware%20Distribution%20-%20Application%20Monitoring%2FAll%20application%20deployments%20(basic)&FourthParameter=0&ThirdParameter=XX100504&TimeFrame=30&ChooseBy=Collection&SecondParameter=%25&SuccessPct=0&Administrator=All&rs%3AParameterLanguage=en-US'

<#
Adobe Reader 11.10 - Group 01	XX100504
Adobe Reader 11.10 - Group 02	XX100505
Adobe Reader 11.10 - Group 03	XX100506
Adobe Reader 11.10 - Group 04	XX100508
Adobe Reader 11.10 - Group 05	XX123456
Adobe Reader 11.10 - Group 06	XX100509
Adobe Reader 11.10 - Group 07	XX10050B
Adobe Reader 11.10 - Group 08	XX10050C
Adobe Reader 11.10 - Group 09	XX123456

http://SERVER/ReportServer?%2FConfigMgr_XX1%2FSoftware%20Distribution%20-%20Application%20Monitoring%2FAll%20application%20deployments%20(basic)&FourthParameter=0&ThirdParameter=XX100504&TimeFrame=30&ChooseBy=Collection&SecondParameter=%25&SuccessPct=0&Administrator=All&rs%3AParameterLanguage=en-US

#>
