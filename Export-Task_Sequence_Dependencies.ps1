<#
.SYNOPSIS
Exports a CSV of all the depedencies for a given Task Sequence.
    
.DESCRIPTION
Exports a CSV of all the depedencies for a given Task Sequence.

Author: Daniel Classon
Version: 1.0
Date: 2015/05/12
    
.EXAMPLE
.\Export-Task_Sequence_Dependencies.ps1 -TSID P0000061
Exports a CSV of all the depedencies for Task Sequence with ID P0000061.
    
.DISCLAIMER
All scripts and other powershell references are offered AS IS with no warranty.
These script and functions are tested in my environment and it is recommended that you test these scripts in a test environment before using in your production environment.
#>
        Write-Warning "You are not running this as local administrator. Run it again in an elevated prompt." ; break
    }
        Write-Warning -Message "Access denied" ; break
    }