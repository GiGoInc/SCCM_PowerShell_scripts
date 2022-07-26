# Use saved password are $Cred
$user = 'DOMAIN\user1'
# Check for Password file
    If (!(Test-Path 'D:\Powershell\tsa_securestring.txt'))
    {
        Write-Host ""
        Write-Host "Hey, dum dum it doesn't look like the password file " -NoNewline -ForegroundColor Cyan  
        Write-host "D:\Powershell\tsa_securestring.txt " -ForegroundColor Green  -NoNewline
        Write-Host "exists..." -ForegroundColor Cyan  
        Write-Host ""
        Write-Host "You need to either generate it like this: " -ForegroundColor Cyan
        Write-Host ""
        Write-Host '# Create encrypted password'
        Write-Host 'Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File "D:\Powershell\tsa_securestring.txt"'
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
$cred = New-Object System.Management.Automation.PsCredential $user,(Get-Content 'D:\Powershell\tsa_securestring.txt' | ConvertTo-SecureString)

$Log = 'D:\Powershell\!SCCM_PS_scripts\!Appplications_and_Packages\Get_Application_Name_and_APPID_from_SQL--Results.txt'

$GetRowInfo_DB =       'CM_SS1'
$GetRowInfo_Server =   'sccmserver'
$GetRowInfo_Query =    "SELECT DISTINCT ApplicationName,APPCI FROM fn_appdtclientsummarizedstate(1033) Order By ApplicationName"
$GetRowInfo_Instance = 'sccmserver'


# Run SQl
$GetRowInfo_QueryInvoke = Invoke-Sqlcmd -AbortOnError `
    -ConnectionTimeout 60 `
    -Database $GetRowInfo_DB  `
    -HostName $GetRowInfo_Server  `
    -Query $GetRowInfo_Query `
    -QueryTimeout 600 `
    -ServerInstance $GetRowInfo_Instance




$GetRowInfo_QueryInvoke | Out-File $Log