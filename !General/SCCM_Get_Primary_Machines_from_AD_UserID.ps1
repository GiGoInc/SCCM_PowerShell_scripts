# Get-CMUserDeviceAffinity -DeviceName "computername" 


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


$Log = "D:\Powershell\!SCCM_PS_scripts\!General\SCCM_Get_Primary_Machines_from_AD_UserID.txt"
$UserIDs = 'user1','user12','user13'

ForEach ($UserID in $UserIDs)
{
    $GetRowInfo_DB =       'CM_SS1'
    $GetRowInfo_Server =   'sccmserver'
    $GetRowInfo_Query =    "SELECT  SYS.User_Name0,SYS.Netbios_Name0,SYS.User_Domain0,Operating_System_Name_and0,SYS.Resource_Domain_OR_Workgr0 FROM v_R_System  SYS WHERE User_Name0 LIKE `'$UserID`' ORDER BY SYS.User_Name0, SYS.Netbios_Name0"
    $GetRowInfo_Instance = 'sccmserver'
    
    
    # Run SQl
    $GetRowInfo_QueryInvoke = Invoke-Sqlcmd -AbortOnError `
        -ConnectionTimeout 60 `
        -Database $GetRowInfo_DB  `
        -HostName $GetRowInfo_Server  `
        -Query $GetRowInfo_Query `
        -QueryTimeout 600 `
        -ServerInstance $GetRowInfo_Instance

$GetRowInfo_QueryInvoke
}





# Select SMS_R_SYSTEM.ResourceID,SMS_R_SYSTEM.ResourceType,SMS_R_SYSTEM.Name,SMS_R_SYSTEM.SMSUniqueIdentifier,SMS_R_SYSTEM.ResourceDomainORWorkgroup,SMS_R_SYSTEM.Client FROM SMS_R_System JOIN SMS_UserMachineRelationship ON SMS_R_System.Name=SMS_UserMachineRelationship.ResourceName JOIN SMS_R_User ON SMS_UserMachineRelationship.UniqueUserName=SMS_R_User.UniqueUserName WHERE SMS_UserMachineRelationship.Types=1 AND SMS_R_User.UserGroupName="domain.com\\$ADGroup"
# "SELECT  SYS.User_Name0,SYS.Netbios_Name0,SYS.User_Domain0,Operating_System_Name_and0,SYS.Resource_Domain_OR_Workgr0 FROM v_R_System  SYS WHERE User_Name0 LIKE `'$UserID`' ORDER BY SYS.User_Name0, SYS.Netbios_Name0"
