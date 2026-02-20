[CmdletBinding()]
$Output
Set-Location -Path $env:windir
[CmdletBinding()]

param(    
    [Parameter(Mandatory=$True, Helpmessage="Provide the Task Sequence Package ID")]
    [string]$TSID,
    [Parameter(Mandatory=$True, Helpmessage="Provide the Distribution Point to Check")]
    [string]$DP
)  
    
$TSLog = "D:\Powershell\!SCCM_PS_scripts\TS_dependencies.csv"

############################################################################
# GET TS REFERENCES
$SiteCode = Get-PSDrive -PSProvider CMSITE
Set-Location -Path "$($SiteCode.Name):\"
$TS = Get-CMTaskSequence -TaskSequencePackageId $TSID
$TSRefs = $TS.references | select Package
############################################################################
# GET DP PACKAGES
$DPPKGs = Get-CMDeploymentPackage -DistributionPointName $DP
$DPPKGs | % {$_.Name + "`t" + $_.packageid}
############################################################################
# MATCH DP PACKAGES TO TS REFERENCES
$i = 1
$Output = @()
ForEach ($Ref in $TSRefs)
{
    ForEach ($DPPKG in $DPPKGs)
    {
        $PKGName = $($DPPKG.Name).split("`t")[0]
          $PKGID = $($DPPKG.packageid).split("`t")[1]

        IF ($Ref -like $PKGID){$Output += "$PKGName";$i++}
    }
}
##############################################
$MissingRefs = $null
$MissingRefs = $RequiredRefs | ?{$Output -notcontains $_}
If ($MissingRefs -eq $null){$Output += 'All Refs are on DP'}
Else{ForEach ($MissingRef in $MissingRefs){$output += 'Missing --- ' + $MissingRef + ','}}
Set-Location -Path $env:windir
$Output
