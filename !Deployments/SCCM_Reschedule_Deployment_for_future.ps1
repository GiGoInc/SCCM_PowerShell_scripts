#	2015-04-22	IBL	This script is working as expected.
#>

#	2015-04-22	IBL	This script is working as expected.
#>

#	2015-04-22	IBL	This script is working as expected.
#		This script assumes that you only have one deployment for the Collection Name
#		It takes a Collection Name and rescheduled the deployment enforcement time for one minute in the future, which kicks the deployment off "immediately"
# 

D:
CD 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location XX1:
CD XX1:


$File = "E:\Packages\Powershell_Scripts\CollectionNames.txt"
function RunFunc ($Lines)
{

	$Deployment = Get-CMDeployment -CollectionName $Lines
	
	Set-CMApplicationDeployment -Application (Get-CMApplication -Id $Deployment.CI_ID) -CollectionName $Deployment.CollectionName -DeadlineDate ($Deployment.EnforcementDeadline).AddMinutes(1) -DeadlineTime ($Deployment.EnforcementDeadline).AddMinutes(1)
	
	Write-Output "  "$Deployment.EnforcementDeadline"Deadline" -ForegroundColor Green
	Write-Output "  "($Deployment.EnforcementDeadline).AddMinutes(1)"Deadline updated to" -ForegroundColor Green
	
	Write-Output "  "$Deployment.AssignmentID"CI Deadline Updated" -ForegroundColor Green
}

(Get-Content $File) | foreach-Object {invoke-command -ScriptBlock ${function:RunFunc} -ArgumentList $_}
CD E:


# Set-CMApplicationDeployment -ApplicationName "Track System 2011" -CollectionName "Test - IE 10 fix" -AvaliableDate 2012/10/21 -AvaliableTime 17:25 -DeadlineDate 2013/01/01 -DeadlineTime 13:10
# Set-CMApplicationDeployment -ApplicationName "Track System 2011" -CollectionName "All Users" -AvaliableDate 2012/10/21 -AvaliableTime 17:25 -DeadlineDate 2013/01/01 -DeadlineTime 13:10

<#
AssignmentID        : 16778022
CI_ID               : 17014841
CollectionID        : XX100468
CollectionName      : Test - IE 10 fix
CreationTime        : 4/3/2015 4:00:01 AM
DeploymentID        : {61DDAED7-7B85-4C52-970B-2D50373A3DA0}
DeploymentIntent    : 1
DeploymentTime      : 4/3/2015 11:00:00 PM
DesiredConfigType   : 1
EnforcementDeadline : 4/3/2015 11:05:00 PM
FeatureType         : 1
ModelName           : ScopeId_B524C55D-6E5C-465E-82C3-E2B262C19608/Application_5a82b7c2-296a-4931-87f3-52b5ec4b79f5
ModificationTime    : 4/6/2015 6:33:52 PM
NumberErrors        : 0
NumberInProgress    : 22
NumberOther         : 0
NumberSuccess       : 10
NumberTargeted      : 32
NumberUnknown       : 0
ObjectTypeID        : 200
PackageID           : XX100048
PolicyModelID       : 16807754
ProgramName         :
SoftwareName        : Internet Explorer 10
SummarizationTime   : 4/22/2015 3:51:21 PM
SummaryType         : 1

AssignmentID        : 16778028
CI_ID               : 17014841
CollectionID        : XX100470
CollectionName      : Sunday 4-19
CreationTime        : 4/20/2015 2:04:47 AM
DeploymentID        : {19A493DF-8C2C-49A1-86AB-21F882EB9DA9}
DeploymentIntent    : 1
DeploymentTime      : 4/19/2015 9:00:00 PM
DesiredConfigType   : 1
EnforcementDeadline : 4/19/2015 9:15:00 PM
FeatureType         : 1
ModelName           : ScopeId_B524C55D-6E5C-465E-82C3-E2B262C19608/Application_5a82b7c2-296a-4931-87f3-52b5ec4b79f5
ModificationTime    : 4/20/2015 2:04:47 AM
NumberErrors        : 0
NumberInProgress    : 116
NumberOther         : 0
NumberSuccess       : 2
NumberTargeted      : 121
NumberUnknown       : 3
ObjectTypeID        : 200
PackageID           : XX100048
PolicyModelID       : 16807754
ProgramName         :
SoftwareName        : Internet Explorer 10
SummarizationTime   : 4/22/2015 3:51:21 PM
SummaryType         : 1

AssignmentID        : 16778030
CI_ID               : 17014841
CollectionID        : XX100471
CollectionName      : Tuesday 4-21
CreationTime        : 4/20/2015 2:07:35 AM
DeploymentID        : {2B3F7953-4EB2-4D3C-A2D2-92DC7BF8EC64}
DeploymentIntent    : 1
DeploymentTime      : 4/19/2015 9:00:00 PM
DesiredConfigType   : 1
EnforcementDeadline : 4/21/2015 8:00:00 PM
FeatureType         : 1
ModelName           : ScopeId_B524C55D-6E5C-465E-82C3-E2B262C19608/Application_5a82b7c2-296a-4931-87f3-52b5ec4b79f5
ModificationTime    : 4/20/2015 2:07:35 AM
NumberErrors        : 0
NumberInProgress    : 102
NumberOther         : 0
NumberSuccess       : 11
NumberTargeted      : 118
NumberUnknown       : 5
ObjectTypeID        : 200
PackageID           : XX100048
PolicyModelID       : 16807754
ProgramName         :
SoftwareName        : Internet Explorer 10
SummarizationTime   : 4/22/2015 3:51:21 PM
SummaryType         : 1

AssignmentID        : 16778029
CI_ID               : 17014841
CollectionID        : XX100472
CollectionName      : Thursday 04-23
CreationTime        : 4/20/2015 2:06:29 AM
DeploymentID        : {D1BF8E72-0C44-4981-A7E9-B3A7228E15AB}
DeploymentIntent    : 1
DeploymentTime      : 4/19/2015 9:00:00 PM
DesiredConfigType   : 1
EnforcementDeadline : 4/23/2015 8:00:00 PM
FeatureType         : 1
ModelName           : ScopeId_B524C55D-6E5C-465E-82C3-E2B262C19608/Application_5a82b7c2-296a-4931-87f3-52b5ec4b79f5
ModificationTime    : 4/20/2015 2:06:29 AM
NumberErrors        : 0
NumberInProgress    : 102
NumberOther         : 0
NumberSuccess       : 8
NumberTargeted      : 113
NumberUnknown       : 3
ObjectTypeID        : 200
PackageID           : XX100048
PolicyModelID       : 16807754
ProgramName         :
SoftwareName        : Internet Explorer 10
SummarizationTime   : 4/22/2015 3:51:21 PM
SummaryType         : 1

AssignmentID        : 16778027
CI_ID               : 17014841
CollectionID        : XX100473
CollectionName      : Saturday 4-25
CreationTime        : 4/20/2015 2:03:26 AM
DeploymentID        : {272A8B4F-838F-4BD9-8BC4-858DCB917788}
DeploymentIntent    : 1
DeploymentTime      : 4/19/2015 9:00:00 PM
DesiredConfigType   : 1
EnforcementDeadline : 4/25/2015 2:00:00 PM
FeatureType         : 1
ModelName           : ScopeId_B524C55D-6E5C-465E-82C3-E2B262C19608/Application_5a82b7c2-296a-4931-87f3-52b5ec4b79f5
ModificationTime    : 4/20/2015 2:08:46 AM
NumberErrors        : 1
NumberInProgress    : 95
NumberOther         : 0
NumberSuccess       : 3
NumberTargeted      : 103
NumberUnknown       : 4
ObjectTypeID        : 200
PackageID           : XX100048
PolicyModelID       : 16807754
ProgramName         :
SoftwareName        : Internet Explorer 10
SummarizationTime   : 4/22/2015 3:51:21 PM
SummaryType         : 1

#>
