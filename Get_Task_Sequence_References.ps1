Function ConvertFrom-CMApplicationCIUniqueID ($CIUniqueID)
{
    $SiteCode = 'SS1'
    $SiteServer = 'sccm1'
    <# .SYNOPSIS Convert a CI Unique ID to Application Name and Version in ConfigMgr 2012 .DESCRIPTION This script will convert a CI Unique ID shown in for example the AppIntentEval.log client log file to an Application Name and Version in ConfigMgr 2012 .PARAMETER SiteServer Site server name with SMS Provider installed .PARAMETER CIUniqueID Specify the CI_UniqueID for the application to be translated .EXAMPLE .\ConvertFrom-CMApplicationCIUniqueID.ps1 -SiteServer CM01 -CIUniqueID "Application_f7cdd400-ed5a-473b-a1ce-d3a0cc6643d2" -Verbose Converts the CI Unique ID (part of) 'Application_f7cdd400-ed5a-473b-a1ce-d3a0cc6643d2' on a Primary Site server called 'CM01': .NOTES Script name: ConvertFrom-CMApplicationCIUniqueID.ps1 Author: Nickolaj Andersen Contact: @NickolajA DateCreated: 2015-02-10 #>
    # [CmdletBinding(SupportsShouldProcess=$true)]
    # [OutputType([PSObject])]
    # param(
    #     [parameter(Mandatory=$true, HelpMessage="Site server where the SMS Provider is installed")]
    #     [ValidateScript({Test-Connection -ComputerName $_ -Count 1 -Quiet})]
    #     [ValidateNotNullOrEmpty()]
    #     [string]$SiteServer,
    #     [parameter(Mandatory=$true, HelpMessage="Specify the CI_UniqueID for the application to be translated")]
    #     [ValidateNotNullOrEmpty()]
    #     [string[]]$CIUniqueID
    # )
    #Begin
    #{
    #    # Determine SiteCode from WMI
    #    try
    #    {
    #        Write-Verbose "Determining SiteCode for Site Server: '$($SiteServer)'"
    #        $SiteCodeObjects = Get-WmiObject -Namespace "root\SMS" -Class SMS_ProviderLocation -ComputerName $SiteServer -ErrorAction Stop
    #        foreach ($SiteCodeObject in $SiteCodeObjects)
    #        {
    #            if ($SiteCodeObject.ProviderForLocalSite -eq $true) 
    #           {
    #                $SiteCode = $SiteCodeObject.SiteCode
    #                Write-Debug "SiteCode: $($SiteCode)"
    #            }
    #        }
    #    }
    #    catch [Exception]
    #    {
    #        Throw "Unable to determine SiteCode"
    #    }
    #}
    
    #Process
    #{
        $ResultsList = New-Object -TypeName System.Collections.ArrayList
        foreach ($ID in $CIUniqueID) {
            Write-Verbose -Message "Query: SELECT * FROM SMS_ApplicationLatest WHERE CI_UniqueID like '%$($ID)%'"
            $Application = Get-WmiObject -Namespace "root\SMS\site_$($SiteCode)" -Class "SMS_ApplicationLatest" -ComputerName $SiteServer -Filter "CI_UniqueID like '%$($ID)%'"
            if ($Application -ne $null) {
                $PSObject = [PSCustomObject]@{
                    DisplayName = $Application.LocalizedDisplayName
                    Version = $Application.SoftwareVersion
                    CI_UniqueID = $Application.CI_UniqueID
                }
                $ResultsList.Add($PSObject) | Out-Null
            }
            else {
                Write-Verbose -Message "Unable to find an application matching the CI_UniqueID with '$($ID)'"
            }
        }
        Write-Output $ResultsList
    #}
}

C:
CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location SS1:
CD SS1:


$output = @()
$output += 'Task Sequence Name	PackageID/ObjectID	Reference Name'
$TSes = Get-CMTaskSequence | select Name, References
ForEach ($TS in $TSes)
{
    $Refs = $TS.References
    ForEach ($Ref in $Refs)
    {
        $TSName = $TS.name
        $RefPack = ($Ref.Package)
        If ($Ref.Package -match '/')
        {
            [string]$PackID = ($Ref.package).split('/')[1]
            $ProgramName = ConvertFrom-CMApplicationCIUniqueID -CIUniqueID $PackID
            $ProgramDisplayName = $ProgramName.DisplayName
            Write-Host "$TSName `t-`t $RefPack `t-`t $ProgramDisplayName" -ForegroundColor Yellow
            $output += "$TSName`t$RefPack`t$ProgramDisplayName"
        }
    }
    $SQL_Query = "select v_tasksequenceReferencesInfo.referencepackageid,v_tasksequenceReferencesInfo.referencename  FROM [CM_SS1].[dbo].[v_tasksequenceReferencesInfo] join v_tasksequencePackage On v_tasksequenceReferencesInfo.packageID = v_tasksequencePackage.packageid where v_tasksequencePackage.name =  '$TSName'"
    $SQLInfo = Invoke-Sqlcmd -AbortOnError `
                  -ConnectionTimeout 60 `
                  -Database 'CM_SS1'  `
                  -HostName 'sccmdb1'  `
                  -Query $SQL_Query `
                  -QueryTimeout 600 `
                  -ServerInstance 'sccmdb1'

    ForEach ($SItem in $SQLInfo)
    {
        $SPackID = $SItem.referencepackageid
        $SName = $SItem.referencename
        Write-Host "$TSName `t-`t $SPackID `t-`t $SName" -ForegroundColor Green
        $output += "$TSName`t$SPackID`t$SName"
    }
    $Output | out-file 'D:\Powershell\!SCCM_PS_scripts\Get_Task_Sequence_References---Results.csv'
}