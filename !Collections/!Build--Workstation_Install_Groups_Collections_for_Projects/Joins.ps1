# Load Modules
    .'C:\Scripts\!Modules\Join-Object.ps1'

    # Load SCCM Module
    C:
    CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
    Import-Module ".\ConfigurationManager.psd1"
    Set-Location SS1:
    CD SS1:


###########################################################################################################
### Variables
     $DeploymentStartDate = '08/22/2017'
       $DeploymentEndDate = '09/14/2017'

    $CollNameStart = 'WMF 5.1'


###########################################################################################################
### Create Collections using text file with static names list

# Variables
    $AvailableTime = Get-Date -Format "MM/dd/yyyy hh:mm tt"      
    $Schedule1 = New-CMSchedule -Start "$AvailableTime" -RecurCount 14 -RecurInterval Days
     $Comments = "Created by Automated PowerShell script - $AvailableTime - Isaac"

# Get Deploy dates
    $DeployDates = @()
    $Start = $DeploymentStartDate | Get-Date
    $End = $DeploymentEndDate | Get-Date
    
    #define a counter
        $i=0
    
    # Test every date between start and end to see if it is a Sunday, Friday, or Saturday
        For ($d=$start;$d -le $end;$d=$d.AddDays(1))
        {
            If ($d.DayOfWeek -notmatch "Sunday|Friday|Saturday")
            {
                #if the day of the week is not a Saturday or Sunday
                #increment the counter
                $Date = $d.Date
                $DeployDates += $Date | Get-Date -Format "MM/dd/yyyy"
                $i++
            }
        }


# Counter
    $CollArray = @()
    $Num=1
    Do
    {
        $CollName = "$CollNameStart" + '  deployment - Group ' + "{0:D2}" -f $Num
        $CollArray += $CollName
    }While (($Num = $Num + 1) -le 28)





# Join-Object -Left $L -Right $R -LeftJoinProperty Name -RightJoinProperty Manager -Type OnlyIfInBoth -RightProperties Department

