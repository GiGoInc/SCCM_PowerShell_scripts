# Server Actions
    Test-WSMan -ComputerName $Computer -Authentication Credssp -Credential $cred
    $Computer = 'SERVER.DOMAIN.COM'
# Server Actions
    Enable-PSRemoting -Force
    Enable-WSManCredSSP -Role Server -Force
    Restart-Service -Name WinRM -Force


# Client Actions
    # Enable-WSManCredSSP -Role Client -DelegateComputer *.DOMAIN.COM -Force
    Enable-WSManCredSSP  -Role Client –DelegateComputer $Computer -Force



#################################################
#
# REBOOT BOTH CLIENT AND SERVER
#
#################################################



# RUN THIS FROM CLIENT
    # Create encrypted password
    $Pfile = "D:\Powershell\securestring.txt"
    $username = "DOMAIN\SUPERUSER"
    Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File $Pfile



# USE CRED
    $Pfile = "D:\Powershell\securestring.txt"
    $username = "DOMAIN\SUPERUSER"
    $password = cat $Pfile | convertto-securestring
    $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
# RUN COMMAND 
    $Computer = 'SERVER.DOMAIN.COM'
    Test-WSMan -ComputerName $Computer -Authentication CredSSP -Credential $cred

    $Computer = 'SERVER.DOMAIN.COM'
    Test-WSMan -ComputerName $Computer -Authentication CredSSP -Credential $cred
    
    $Computer = 'SERVER.DOMAIN.COM'
    Test-WSMan -ComputerName $Computer -Authentication Credssp -Credential $cred
    
    $Computer = 'SERVER.DOMAIN.COM'
    Test-WSMan -ComputerName $Computer -Authentication Credssp -Credential $cred
