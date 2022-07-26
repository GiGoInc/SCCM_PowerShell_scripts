$computers = 'MSPCSP01', `
        'MSDHET02', `
        'LAG7ET02', `
        'LAG7SP04'


ForEach ($Computer in $Computers)
{
    If (Test-path "\\$Computer\C$\Windows\CCM\Logs\LocationServices.log"){$LogFile = "\\$Computer\C$\Windows\CCM\Logs\LocationServices.log"}
    # ElseIf (Test-path "\\$Computer\D$\SMS_DP$\sms\log\smsdpmon.logs"){$LogFile = "\\$Computer\D$\SMS_DP$\sms\logs\smsdpmon.log"}
    # ElseIf (Test-path "\\$Computer\E$\SMS_DP$\sms\logs\smsdpmon.log"){$LogFile = "\\$Computer\E$\SMS_DP$\sms\logs\smsdpmon.log"}
    Else {"$Computer - LocationServices.log not found"}
    $Contents = Get-Content $logfile
    $i = 1
    $Result1 = @()
    $Result2 = @()
    $Regex1 = [Regex]::new("(?<=Current AD site of machine is )(.*)(?=`]LOG]`!`>)")
    $Regex2 = [Regex]::new("(?<=Distribution Point='http://)(.*)(?=/SMS_DP_SMSPKG)")          
    ForEach ($line in $Contents)
    {
        #$Match1 = $Regex1.Match($line)
        $Match2 = $Regex2.Match($line)
        #If($Match1.Success)
        #{
        #    $Result1 += $Match1.Value + " $i"
        #}
        If($Match2.Success)
        {
            $Result2 += $Match2.Value + " $i"
        }
        $i++
    }
    #$Result1
    $Count = $Result2.count
    $charCount1 = ($Result2 | Where-Object {$_ -match 'sccm1.domain.com'} | Measure-Object).Count
    Write-Host $charCount1
    $charCount2 = ($Result2 | Where-Object {$_ -notmatch 'sccm1.domain.com'} | Measure-Object).Count
    Write-Host "$charCount2 of $Count lines that are not 'sccm1'." -ForegroundColor Magenta
}





<#
    $i = 1
    $Regex2 = [Regex]::new("(?<=Distribution Point='http://)(.*)(?=/SMS_DP_SMSPKG)")    
    ForEach ($line in $Contents)
    {
        #$Match1 = $Regex1.Match($line)
        $Match2 = $Regex2.Match($line)
       # If($Match1.Success)
       # {
       #     $Result1 = $Match1.Value + " $i"
       #     $Result1
       # }
       # Else{$Result1 = $null}
        If($Match2.Success)
        {
            $Result2 = $Match2.Value + " $i"
            $Result2
        }
        Else{$Result2 = $null}
        $i++
    }

#>