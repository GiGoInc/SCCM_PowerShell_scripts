<#
 
 
<#
.Synopsis
    Get Application and Package - Program information regarding Task Sequence support
.DESCRIPTION
   The script checks all applications and packages if they are allowed to be installed from a TS without being deployed
.EXAMPLE
   Get-TSInstallEnabled -Site Lab
.NOTES
    Version 1.0
    Written by Alex Verboon
#>


[CmdletBinding()]


param( 
    # ConfigMgr Site
    [Parameter(Mandatory = $true, ValueFromPipeline=$true)]
    [String[]] $Site
    )

if ($Site.Length -eq 0)
     {    
     Throw "ConfigMgr Site code required"
     } 
Else
    {
    $SiteCode = $Site
    }


function Get-TSInstallEnabled ()
{
    # Check that youre not running X64
    if ([Environment]::Is64BitProcess -eq $True)
         {    
         Throw "Need to run at a X86 PowershellPrompt"
         } 
    # Load ConfigMgr module if it isn't loaded already
    if (-not(Get-Module -name ConfigurationManager))
        {        
        Import-Module ($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')
        } 
       
    # Change to site
    Push-Location
    Set-Location ${SiteCode}:

########################################################
    Function Get-AppTSInfo()
    {
        $Apps = @() 
        foreach ($Application in Get-CMApplication)
            {
            $AppMgmt = ([xml]$Application.SDMPackageXML).AppMgmtDigest
            $AppName = $AppMgmt.Application.DisplayInfo.FirstChild.Title
            $AllowTs =  $AppMgmt.Application.AutoInstall
            $object = New-Object -TypeName PSObject
            $object | Add-Member -MemberType NoteProperty -Name "Application Name" -Value $Appname

            if ($AllowTs -ne "true") {$AllowTs = "false"}

            $object | Add-Member -MemberType NoteProperty -Name "Allowed TS Install" -Value $AllowTs
            $Apps += $object
             }
        $Apps 
    }
########################################################
    Function Get-PackageTSInfo()
    {
        $Progs = @() 
        foreach ($Prog in Get-CMProgram)
        {
            If ($Prog.SupportedOperatingSystems -match 'Win NT')
            {
                   $ProgName = $Prog.ProgramName
                $PackageName = $Prog.PackageName
                        $SOS = $Prog.SupportedOperatingSystems
                     $SOSMin = $Prog.SupportedOperatingSystems.MinVersion
                     $SOSMax = $Prog.SupportedOperatingSystems.MaxVersion
                    $SOSName = $Prog.SupportedOperatingSystems.Name
                    $SOSPlat = $Prog.SupportedOperatingSystems.Platform   
                    $AllowTs = $Prog.ProgramFlags -band [math]::pow(0,0)
                $object = New-Object -TypeName PSObject
                    $object | Add-Member -MemberType NoteProperty -Name "Program Name" -Value $ProgName
                    $object | Add-Member -MemberType NoteProperty -Name "Package Name" -value $Packagename
                    $object | Add-Member -MemberType NoteProperty -Name "Supported OS" -value $SOS
                    $object | Add-Member -MemberType NoteProperty -Name "Supported OS Min Ver" -value $SOSMin
                    $object | Add-Member -MemberType NoteProperty -Name "Supported OS Max Ver" -value $SOSMax
                    $object | Add-Member -MemberType NoteProperty -Name "Supported OS Name" -value $SOSName
                    $object | Add-Member -MemberType NoteProperty -Name "Supported OS Platform" -value $SOSPlat                            
                    if ($AllowTs -ne "1") {$AllowTs = "false"} Else {$AllowTs = "true"}
                    $object | Add-Member -MemberType NoteProperty -Name "Allowed TS Install" -Value $AllowTs
                $Progs += $object
            }
        $Progs
        }
    }
########################################################

Get-AppTSInfo | Format-Table -AutoSize 
Get-PackageTSInfo | Format-Table -AutoSize 
Pop-Location
}

Get-TSInstallEnabled
 
 
 
 
 
 
 
