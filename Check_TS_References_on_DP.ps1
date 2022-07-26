﻿[CmdletBinding()]
############################################################################
$DPPKGs = Get-CMDeploymentPackage -DistributionPointName $DP
$DPPKGs | % {$_.Name + "`t" + $_.packageid}
############################################################################
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