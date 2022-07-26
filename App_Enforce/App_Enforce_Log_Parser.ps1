$Computers = 'computer1'

$ADateStart = $(get-date -format yyyy_MM_dd)+'__'+ $(get-date -UFormat %R).Replace(':','.')
ForEach ($computer in $computers)
{
    If (Test-Connection $computer -count 1 -quiet -BufferSize 16)
    {
        "Checking $computer..."
        ######################################################################
        $Scriptblock = {
                $AppEnforceLog = Get-Content "C:\Windows\CCM\Logs\AppEnforce.log"
                If(!(Test-Path -Path 'C:\Temp')){New-Item -ItemType directory -Path 'C:\Temp'}
                $OutputFile = 'C:\Temp\AppEnforce_log--Results.csv'
                 $ArrayFile = 'C:\Temp\AppEnforce_log--Array.txt'
                'CCM Folder,Start Date,Start Time,Application Name,Install Duration,End Date,End Time' | Set-Content $OutputFile

                $StartPattern = 'Starting Install enforcement'
                  $EndPattern = 'App enforcement completed'

                $From =  ($AppEnforceLog | Select-String -pattern "$StartPattern" | Select-Object LineNumber).LineNumber
                $To =  ($AppEnforceLog  | Select-String -pattern "$EndPattern" | Select-Object LineNumber).LineNumber

                [array]$AFrom = @($From)
                [array]$ATo = @($To)
                $Found = $AFrom.Count

                #$From
                #''
                #$To
                #''
                #$Found

                $Num = 0

                Function GetLines
                {
                    $Start = $From[$Num]
                    $Finish = $To[$Num]
                    $LineNumber = 0
                    $Array = @()
                    Foreach ($Line in $AppEnforceLog)
                    {
                        ForEach-Object { $LineNumber++ }
                        If (($LineNumber -ge $Start) -and ($LineNumber -le $Finish))
                        {
                            $Array += $Line   
                            $Array | Set-Content $ArrayFile
                        }
                    }

                    $X = @()
                    Foreach ($Line in $Array)
                    {
                        $CCMFolder = $Null
                        $StartDate = $Null
                        $StartTime = $Null
                        $InstallDuration = $Null
                        $AppName = $Null
                        $EndDate = $Null
                        $EndTime = $Null

                        If ($line -match 'Prepared working directory')
                        {
                            #"Found Start Pattern"
                            $CCMFolder = $line.split('[')[2].split(']')[0].trim().split(' ')[3].trim()
                            $StartTime = $line.split('<')[2].split('"')[1].split('.')[0].trim()
                            $StartDate = $line.split('<')[2].split('"')[3].trim()
                            $X += "$CCMFolder,$StartDate,$StartTime"
                        }#Else{$CCMFolder = $Null;$StartDate = $Null;$StartTime = $Null}

                        #$Finish
                        If ($line -match 'App enforcement completed')
                        {
                            #"Found End Pattern"
                            $InstallDuration = $line.split('[')[2].split('(')[1].split(')')[0].trim()
                            $AppName = $line.split('[')[2].split('"')[1].trim()
                            $EndTime = $line.split('<')[2].split('"')[1].split('.')[0].trim()
                            $EndDate = $line.split('<')[2].split('"')[3].trim()
                            $X += "$AppName,$InstallDuration,$EndDate,$EndTime"
                        }#Else{$InstallDuration = $Null;$AppName = $Null;$EndDate = $Null;$EndTime = $Null}
                    }
                    $X -join ',' | Add-Content $OutputFile
                }
                Do 
                {
                    GetLines
                    $Num++
                }
                While ($Num -lt $Found)
        ######################################################################
        }
        Invoke-Command -ComputerName $Computer -ScriptBlock $ScriptBlock
        Copy-Item "\\$Computer\C$\Temp\AppEnforce_log--Results.csv" "\\D7B0M9Z2\D$\Powershell\!SCCM_PS_scripts\App_Enforce\$Computer--$ADateStart--AppEnforce_log--Results.csv" -Recurse -Force
        "D:\Powershell\!SCCM_PS_scripts\App_Enforce\$Computer--$ADateStart--AppEnforce_log--Results.csv"
    }
    ELSE
    {
        "$computer`tCouldn't ping PC"
    }
}