<#
$object.Computer,$object.Responding,$object.Data -join ","

<#
.Synopsis
This script is intended to be called by another script with a list of machinenames, which will add a header and build a CSV file.
The output is required to be a single line of information per computername, so it can be passed as an object to Invoke-Parallel.ps1

The data follows comma separated order:
PC Name,Online,Result,Version

.Example
PS C:\> .\SCCM_Check_PkgLib--bsub.ps1 -computer 'Computer1'
	Computer1,Yes,Computer1,no 'Application Data' folders found
#>
[CmdletBinding()]
param(
    # Support for multiple computers from the pipeline
    [Parameter(Mandatory=$True,
                ValueFromPipeline=$True,
                ValueFromPipelineByPropertyName=$True,
                HelpMessage='Type in computer name and press Enter to execute')]
    [string]$computer,

    # Switch to turn on Error Logging
    [Switch]$ErrorLog,
    [String]$LogFile = 'C:\Temp\errorlog.txt',
	$command=$nothing
	)

$Data =$Null
$DP = $DP.replace('\\','')
if(Test-Connection $computer -count 1 -quiet -BufferSize 16)
{
$object = [pscustomobject] @{
Computer=$computer;
Responding="Yes";
Data=$(


    $ADateS = Get-Date
    $SDate = Get-Date
    Write-Host "Starting... $SDate" -ForegroundColor Green
    #################################################################################################################################
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
                    $global:CPURL = "http://$DP/sms_dp_smspkg$"
                    $Results = Invoke-WebRequest -uri "$CPURL/$Content" -Credential $cred
                    $StatusCode = $Results.StatusCode
                }
                Catch
                {
                    $Results = $_.Exception.Message
                    "$i`t$ININame`t$Content`t$Results" | Add-Content "$LogFolder\SCCM_PkgLib_Check--$DP--Results.txt"                  
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
                "$i`t$ININame`t$Content`t$StatusCode" | Add-Content "$LogFolder\SCCM_PkgLib_Check--$DP--Results.txt"
            }
            $i++
        }
    }
    # FINALLY - Write Time
    $ADateE = Get-Date
    $t = NEW-TIMESPAN –Start $ADateS –End $ADateE | Select Minutes,Seconds
    $min = $t.Minutes
    $sec = $t.seconds
    Write-Host "`nScript ran against $DP" -nonewline
    write-host ":`t$min minutes and $sec seconds." -ForegroundColor Magenta
    Start-Sleep -seconds 8

"$Data"

)
}
}
else
{
	$object = [pscustomobject] @{
	Computer=$computer;
	Responding="No";
	Data="Couldn't ping PC"
}

}

$object.Computer,$object.Responding,$object.Data -join ","
