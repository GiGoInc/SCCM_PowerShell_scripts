# Server Actions
    Enable-PSRemoting -Force
    Enable-WSManCredSSP -Role Server -Force
    Restart-Service -Name WinRM -Force


# Client Actions
    # Enable-WSManCredSSP -Role Client -DelegateComputer *.domain.com -Force
    Enable-WSManCredSSP  -Role Client –DelegateComputer $Computer -Force



#################################################
#
# REBOOT BOTH CLIENT AND SERVER
#
#################################################



# RUN THIS FROM CLIENT
    # Create encrypted password
    $Pfile = "D:\Powershell\securestring.txt"
    $username = "domain\user1"
    Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File $Pfile



# USE CRED
    $Pfile = "D:\Powershell\securestring.txt"
    $username = "domain\user1"
    $password = cat $Pfile | convertto-securestring
    $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
# RUN COMMAND 
    $Computer = 'scorch.domain.com'
    Test-WSMan -ComputerName $Computer -Authentication CredSSP -Credential $cred

    $Computer = 'scorch2.domain.com'
    Test-WSMan -ComputerName $Computer -Authentication CredSSP -Credential $cred
    
    $Computer = 'scorch01.domain.com'
    Test-WSMan -ComputerName $Computer -Authentication Credssp -Credential $cred
    
    $Computer = 'scorch02.domain.com'
    Test-WSMan -ComputerName $Computer -Authentication Credssp -Credential $cred
