$ADateS = Get-Date
Write-Host "`t$min minutes and $sec seconds." -ForegroundColor Magenta
Write-Host "`nPart2 ran for:" -nonewline
$ADateS = Get-Date
$ADate = Get-Date -Format "yyyy_MM-dd_hh-mm-ss"
$LogFolder = "D:\Powershell\!SCCM_PS_scripts\SCCM_PkgLib_Check_PowerShell7_Parallel"
  $DPsFile = "D:\Powershell\!SCCM_PS_scripts\SCCM_PkgLib_Check_PowerShell7_Parallel\DPs.txt"
 $DPFolder = "D:\Powershell\!SCCM_PS_scripts\SCCM_PkgLib_Check_PowerShell7_Parallel\DPs__$ADate"
 # Create C:\Temp if is doesn't exist
    If (!(Test-Path "$LogFolder")){New-Item -ItemType Directory -Path "$LogFolder" -Force | Out-Null}
    If (!(Test-Path "$DPFolder")){New-Item -ItemType Directory -Path "$DPFolder" -Force | Out-Null}
#####################################################################################################################################
[int]$Timeout = '1800'
[int]$Throttle = '10'
#####################################################################################################################################
(Get-Content $DPsFile) | ForEach-Object -Parallel {
Function Ignore-SelfSignedCerts
{
    try
    {
        Write-Host "Adding TrustAllCertsPolicy type." -ForegroundColor White
        Add-Type -TypeDefinition  @'
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy
        {
             public bool CheckValidationResult(
             ServicePoint srvPoint, X509Certificate certificate,
             WebRequest request, int certificateProblem)
             {
                 return true;
            }
        }
'@
        Write-Host "TrustAllCertsPolicy type added." -ForegroundColor White
    }
    catch
    {
        Write-Host $_ -ForegroundColor "Yellow"
    }
    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
}
#####################################################################################################################################  
    $DP = $_.replace('\\','')

    $SDate = Get-Date
    Write-host "Starting...$DP`t$SDate" -foregroundcolor green
    $ADate = Get-Date -Format "yyyy_MM-dd_hh-mm-ss"
    $LogFolder = "D:\Powershell\!SCCM_PS_scripts\SCCM_PkgLib_Check_PowerShell7_Parallel"
     $DPFolder = "D:\Powershell\!SCCM_PS_scripts\SCCM_PkgLib_Check_PowerShell7_Parallel\DP"
# Create C:\Temp if is doesn't exist
    If (!(Test-Path "$LogFolder")){New-Item -ItemType Directory -Path "$LogFolder" -Force | Out-Null}
    If (!(Test-Path "$DPFolder")){New-Item -ItemType Directory -Path "$DPFolder" -Force | Out-Null}
    # Invoke the web-request
    #############################################################################################
    D:
    If (Test-Path "\\$DP\C$\SCCMContentLib\PkgLib"){$PLIB = Get-ChildItem "\\$DP\C$\SCCMContentLib\PkgLib" -Filter '*.ini'}
    ElseIf (Test-Path "\\$DP\D$\SCCMContentLib\PkgLib"){$PLIB = Get-ChildItem "\\$DP\D$\SCCMContentLib\PkgLib" -Filter '*.ini'}
    ElseIf (Test-Path "\\$DP\E$\SCCMContentLib\PkgLib"){$PLIB = Get-ChildItem "\\$DP\E$\SCCMContentLib\PkgLib" -Filter '*.ini'}
    $PLIB | Out-File "$DPFolder\$DP--PKGLIB.txt"
    ForEach ($INIFile in $PLIB)
    {
        $INI = $INIFile.FullName
        $ININame = $INIFile.Name
        $INIContent = Get-Content $INI
        $i = 0
        ForEach ($line in $INIContent)
        {
            If ($line -match 'Content')
            {  
                $Content = $line.split('=')[0]
                Try
                {
#####################################################################################################################################
                    $Username = 'DOMAIN\SVCUSER1'
                    $Password = '(password)' | ConvertTo-SecureString -AsPlainText -Force 
                    $Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $Password
                    #Ignore-SelfSignedCerts
                    #####################################################################################################################################
                    $URL = "http://$DP/sms_dp_smspkg$"
                    $Results = Invoke-WebRequest -uri "$URL/$Content" -Credential $Cred -AllowUnencryptedAuthentication
                    $StatusCode = $Results.StatusCode
                }
                Catch
                {
                    $Results = $_.Exception.Message
                    "$i`t$ININame`t$Content`t$Results" | Add-Content "$DPFolder\SCCM_PkgLib_Check--$DP--Results.txt"                  
                    # echo '### Inside catch ###'
                    # $ErrorMessage = $_.Exception.Message
                    # echo '## ErrorMessage ##' $ErrorMessage
                    # $FailedItem = $_.Exception.ItemName
                    # echo '## FailedItem ##' $FailedItem
                    # $result = $_.Exception.Response.GetResponseStream()
                    # echo '## result2 ##' $result
                    # $reader = New-Object System.IO.StreamReader($result)
                    # echo '## reader ##' $reader
                    # $responseBody = $reader.ReadToEnd();
                    # echo '## responseBody ##' $responseBody
                }
                "$i`t$ININame`t$Content`t$StatusCode" | Add-Content "$DPFolder\SCCM_PkgLib_Check--$DP--Results.txt"
            }
            $i++
        }
    }
} -ThrottleLimit $Throttle -TimeoutSeconds $Timeout
# FINALLY - Write Time
$ADateE = Get-Date
$t = NEW-TIMESPAN –Start $ADateS –End $ADateE | Select Minutes,Seconds
$min = $t.Minutes
$sec = $t.seconds
Write-Host "`nPart2 ran for:" -nonewline
Write-Host "`t$min minutes and $sec seconds." -ForegroundColor Magenta
