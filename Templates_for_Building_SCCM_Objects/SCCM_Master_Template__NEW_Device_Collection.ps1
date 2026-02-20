$CollNames = "Workstations - Non-RemoteLocale - Group 21", `
}
    $DCollID = (Get-CMCollection -Name $DCollName).CollectionID
$CollNames = "Workstations - Non-RemoteLocale - Group 21", `
             "Workstations - Non-RemoteLocale - Group 22", `
             "Workstations - Non-RemoteLocale - Group 23", `
             "Workstations - Non-RemoteLocale - Group 24", `
             "Workstations - Non-RemoteLocale - Group 25", `
             "Workstations - Non-RemoteLocale - Group 26", `
             "Workstations - Non-RemoteLocale - Group 27", `
             "Workstations - Non-RemoteLocale - Group 28", `
             "Workstations - Non-RemoteLocale - Group 29"



$Comments = 'Divided Non-RemoteLocale machines into smaller groups, 100 approx each'

# Load SCCM Module
    C:
    CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
    Import-Module ".\ConfigurationManager.psd1"
    Set-Location XX1:
    CD XX1:


ForEach ($DCollName in $CollNames)
{
    # Static Variables
        $LimitingColl = "All Windows Workstation or Professional Systems (DC0)"
    
        # DEVICE Collection - New-CMDeviceCollection Static Variables
    
            $DSchedule = New-CMSchedule -Start "$(get-date -format MM/dd/yyy) 12:00 AM" -RecurCount 1 -RecurInterval Days
            # $Comments = "Created automagically by PowerShell on $(get-date -format MM/dd/yyy)"
    
    # DEVICE Collection
        New-CMDeviceCollection `
            -Name $DCollName `
            -LimitingCollectionName $LimitingColl `
            -RefreshSchedule $DSchedule `
            -RefreshType Both `
            -Comment $Comments
        Write-Host ""
        Write-Host "Created SCCM DEVICE Collection named: " -NoNewline
        Write-Host "$DCollName" -ForegroundColor Green
    
    $DCollID = (Get-CMCollection -Name $DCollName).CollectionID
}
