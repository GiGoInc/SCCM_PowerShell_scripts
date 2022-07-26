$Rules = 'ADR: 3rd Party Servers','ADR: Server Reporting - Critical patches','ADR: Software Updates - Servers','ADR: Workstations - 3rd party Updates','ADR: Workstations - 3rd party Updates - Test Group','ADR: Workstations - 3rd Party Updates - Weekly','ADR: Workstations - Reporting - Critical','ADR: Workstations - Software Updates - All Workstations - Manual','ADR: Workstations - Software Updates - Branch','ADR: Workstations - Software Updates - Non Branch','ADR: Workstations - Software Updates - Non Branch Test Group','Windows 8'

ForEach ($Rule in $Rules){Get-CMSoftwareUpdateAutoDeploymentRule -Name $Rule | Add-Content 'D:\Powershell\!SCCM_PS_scripts\!Software_Updates\ADRRUles_List.txt'}




# Get-CMMaintenanceWindow -CollectionId 'SS100436'