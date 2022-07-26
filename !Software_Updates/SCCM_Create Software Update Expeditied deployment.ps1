<# Expedited Software updates notes

Items needed to deploy update(s):
Bulletin or Article ID(s)- what updates to be deployed
    I.E. = MS15-078
Software Update Group (SUG) - bucket for updates the "Deployment Package" will deploy
    
Collection - what machines to deploy updates (in SUG) too
    Collection Name = ADR Collection - Manual Approvals
    Collection ID = SS100172
Deployment package - criteria for deployment, you can define when to available/deploy updates and whether to ignore maintenance window or not

Bulletin or Article ID(s)		"MS15-078"
Software Update Group (SUG)		"ADR: Workstations - Expedited deployment + current date"
Collection Name					"ADR Collection - Manual Approvals"
Collection ID					"SS100172"
Deployment package				

#>

C:
CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:
CD SS1:

