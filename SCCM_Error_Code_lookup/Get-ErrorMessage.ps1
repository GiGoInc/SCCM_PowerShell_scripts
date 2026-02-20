Param (
# .\Get-ErrorMessage.ps1 -ExitCode '0x87D00664' -Language 'en-US'

Param (
    [string]$ExitCode = 0x87D00664,
    [string]$Language
)

#Default Path
#$DLLPath = "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\SrsResources.dll"

#Custom Path
$DLLPath = "D:\SCCM_Error_Code_lookup\SrsResources.dll"

Add-Type -Path $DLLPath

If(!($Language)) {
    $Language = "en-US"
}

If($ExitCode) {
    [int]$intCode = $ExitCode
    If ($intCode -eq 0 -or $intCode) {
        $Message = [SrsResources.Localization]::GetErrorMessage($intCode,$Language)
        If($Message) {
            Return $Message
        }
        Else {
            Return "No Result."
        }
    }
    Else {Return "Bad Exit Code."}
}
Else {
    Return "No exit code was specified."
}


# .\Get-ErrorMessage.ps1 -ExitCode '0x87D00664' -Language 'en-US'
