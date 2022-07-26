<#
    Datalib -- where the content is stored
    DCxxx(source version)
    *.ini
    Hash=(HASHID) 
    matches another INI and signature?

    FileLib\(hashid).ini
#> 
#####################################################################################################################################
$ADate = Get-Date -Format "yyyy_MM-dd_hh-mm-ss"
$LogFolder = "D:\Powershell\!SCCM_PS_scripts\SCCM_PkgLib_Check"
 $DPFolder = "D:\Powershell\!SCCM_PS_scripts\SCCM_PkgLib_Check\DP\$ADate"
  $DPsFile = "D:\Powershell\!SCCM_PS_scripts\SCCM_PkgLib_Check\DPs.txt"
 # Create C:\Temp if is doesn't exist
    If (!(Test-Path "$LogFolder")){New-Item -ItemType Directory -Path "$LogFolder" -Force | Out-Null}
    If (!(Test-Path "$DPFolder")){New-Item -ItemType Directory -Path "$DPFolder" -Force | Out-Null}
######################################################################################################################################

$DP = 'sccmserver'

######################################################################################################################################
    $DSDate = Get-Date   
        If (Test-Path "\\$DP\C$\SCCMContentLib\Datalib"){$DLIB = "\\$DP\C$\SCCMContentLib\Datalib"}
    ElseIf (Test-Path "\\$DP\D$\SCCMContentLib\Datalib"){$DLIB = "\\$DP\D$\SCCMContentLib\Datalib"}
    ElseIf (Test-Path "\\$DP\E$\SCCMContentLib\Datalib"){$DLIB = "\\$DP\E$\SCCMContentLib\Datalib"}
    $DLIBFolders = Get-ChildItem "$DLIB" -Filter 'SS1*' -Directory
    $DLIBFolders = $($DLIBFolders).Fullname
    $DLIBFolders | Out-File "$DPFolder\$DP--DLIB.txt"
    ##############################################################################################
    $ErrorActionPreference = 'SilentlyContinue'
    $DOutput = @()
    ForEach ($DFolder in $DLIBFolders)
    {   
            $Hash = $Null  
        $DINIFile = $Null
        $DINIInfo = $Null
        $DINIFile = Get-ChildItem "$DFolder" -Filter '*.ini' -Recurse | Select-Object -First 1
        IF ($DINIFile -ne $Null)
        {
            $DINIFullName = $($DINIFile).FullName
            $DINIInfo = Get-Content $DINIFullName
            $Hash = $DINIInfo | Select-String -pattern "Hash=" | Select-Object  -First 1
            $Hash = $Hash.ToString()
            $Hash = $Hash.split('=')[1]
            #$DINIFile = $DINIFullName.split('\')[6]
            $DOutput += "File,$DINIFullName,$Hash"
        }
        Else
        {
            #$DFolder = $DFolder.split('\')[6]
            $DOutput += "Folder,$DFolder,No INI file"
        }
    }
    $DOutput | Out-File "$DPFolder\$DP--DataLib_Output.txt"  
    $DEDate = (GET-DATE)
    $Span = NEW-TIMESPAN –Start $DSDate –End $DEDate
    $Min = $Span.minutes
    $Sec = $Span.Seconds
    Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
######################################################################################################################################
    $FSDate = Get-Date
    $FLIBFiles = $Null
     $FLIBINIs = $Null
    $FLIBFolder = $DLIB.replace("Datalib","FileLib")


###################################################
    $FSDate = Get-Date
    $FLIBINIs = Get-ChildItem "$FLIBFolder" -Filter '*.ini' -Recurse -Depth 2
    $FFolders = Get-ChildItem "$FLIBFolder" -Directory -Recurse -Depth 2
    $Folders = $FFolders | % {$_.fullname}
    $Folders

        $FEDate = (GET-DATE)
    $Span = NEW-TIMESPAN –Start $FSDate –End $FEDate
    $Min = $Span.minutes
    $Sec = $Span.Seconds
    Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
###################################################
    $FSDate = Get-Date
    $FFolders = Get-ChildItem "$FLIBFolder" -Recurse -Depth 1
        $FEDate = (GET-DATE)
    $Span = NEW-TIMESPAN –Start $FSDate –End $FEDate
    $Min = $Span.minutes
    $Sec = $Span.Seconds
    Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
###################################################



    $FLIBFullName = $($FLIBINIs).FullName

    $($FLIBINIs).FullName


    $FLIBFullName | Out-File "$DPFolder\$DP--FLIB.txt"
    ##############################################################################################
    $ErrorActionPreference = 'SilentlyContinue'
    $FOutput = @()
    ForEach ($FLine in $FLIBFullName)
    {
        $FINIFile = $FLine.split('\')[7]
        $FINI = $FINIFile.split('.')[0]
        $FOutput += "File,$FLine,$FINI"
    }
    $FOutput | Out-File "$DPFolder\$DP--FileLib_Output.txt"  
    $FEDate = (GET-DATE)
    $Span = NEW-TIMESPAN –Start $FSDate –End $FEDate
    $Min = $Span.minutes
    $Sec = $Span.Seconds
    Write-Host "$(Get-Date)`tProcess ran for $min minutes and $sec seconds`n`n" -ForegroundColor Cyan
######################################################################################################################################
$DCheck = Get-Content "$DPFolder\$DP--DataLib_Output.txt"  
$FCheck = Get-Content "$DPFolder\$DP--FileLib_Output.txt"





<#
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
                    "$i`t$ININame`t$Content`t$StatusCode" | Add-Content "$DPFolder\SCCM_PkgLib_Check--$DP--Results.txt"
                }
                Catch
                {
                    $Results = $Error[0].Exception.Message
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
            }
            $i++
        }
    }
#>