$CollNames = "Workstations - Non-Branch - Group 21", `
             "Workstations - Non-Branch - Group 22", `
             "Workstations - Non-Branch - Group 23", `
             "Workstations - Non-Branch - Group 24", `
             "Workstations - Non-Branch - Group 25", `
             "Workstations - Non-Branch - Group 26", `
             "Workstations - Non-Branch - Group 27", `
             "Workstations - Non-Branch - Group 28", `
             "Workstations - Non-Branch - Group 29"



$Comments = 'Divided Non-Branch machines into smaller groups, 100 approx each'

# Load SCCM Module
    C:
    CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
    Import-Module ".\ConfigurationManager.psd1"
    Set-Location SS1:
    CD SS1:


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