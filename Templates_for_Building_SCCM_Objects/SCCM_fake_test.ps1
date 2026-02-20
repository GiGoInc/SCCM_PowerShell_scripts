        $Appname = Read-Host -Prompt 'Application Name'
      

        $Appname = Read-Host -Prompt 'Application Name'
   $SourceFolder = Read-Host -Prompt 'Source folder name, like "Image Center 2016".'
 $SourceLocation = "\\SERVER\Packages\$SourceFolder"
      $DTRunTime = Read-Host -Prompt 'Approximate runtime for application install (minutes)'
   $DTMaxRunTime = Read-Host -Prompt 'Maximum runtime for application install (minutes)'


# Sanity Check
cls
Write-Host "Based on the information you put in...."
Write-Host ""
Write-Host "You want to create an application named `"" -NoNewline
Write-Host "$Appname" -ForegroundColor Green -NoNewline
Write-Host "`"..."
Write-Host ""
Write-Host "You estimate the install will take " -NoNewline
Write-Host "$DTRunTime " -ForegroundColor Green -NoNewline
Write-Host "minutes to install and should only be allowed to run for " -NoNewline
Write-Host "$DTMaxRunTime " -ForegroundColor Green -NoNewline
Write-Host "minutes..."
Write-Host ""
Write-Host "And you have already copied the installation files to " -NoNewline
Write-Host "$SourceLocation" -ForegroundColor Green -NoNewline
Write-Host "`"?"
Write-Host ""
$DoIt = Read-Host "Is all that information correct and do you want to proceed? [Y/N]"
If($DoIt -ne "Y")
{
	break
}


####################################################################################################
# Recap
    Write-Host ""
    Write-Host ""
    Write-Host "############################################################" -ForegroundColor Green
    Write-Host ""
    Write-Host "So this just happened, in case you missed it...."
    Write-Host ""
    Write-Host ""
    Write-Host "Created SCCM DEVICE Collection named `"" -NoNewline
    Write-Host "$DCollName" -ForegroundColor Green -NoNewline
    Write-Host "`""
    Write-Host ""
    Write-Host "Moved collection to the `"" -NoNewline
    Write-Host "[SCOrch Installs]" -ForegroundColor Red -NoNewline
    Write-Host "`" folder."
    Write-Host ""
    Write-Host ""
    Write-Host "Created and modified SCCM Application named: `"" -NoNewline
    Write-Host "$Appname" -ForegroundColor Green -NoNewline
    Write-Host "`"."
    Write-Host ""
    Write-Host "Created a DeploymentType named `"" -NoNewline
    Write-Host "$DeploymentTypeName" -ForegroundColor Green -NoNewline
    Write-Host "`" and Distributed content to `"" -NoNewline
    Write-Host "$DPGroup" -ForegroundColor Green -NoNewline
    Write-Host "`"."
    Write-Host ""
    Write-Host "Created Application Deployment for the Application to the Collection." -NoNewline
    Write-Host ""
    Write-Host ""
    Write-Host "############################################################" -ForegroundColor Green
    Write-Host ""
    Write-Host "Script completed!"
    Write-Host ""
    Write-Host "*** You will need to manually add members to the new Collection! ***" -ForegroundColor Cyan
    Write-Host ""
Write-Host ""
Read-Host -Prompt 'Press Enter to exit...'

      
