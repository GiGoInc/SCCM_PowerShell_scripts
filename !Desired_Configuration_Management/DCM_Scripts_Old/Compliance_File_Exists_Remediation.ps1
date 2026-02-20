# Compliance Check if file exists - Remediation
    { $_.Exception.Message }
    catch
# Compliance Check if file exists - Remediation

$Path1 = "$env:windir\System32\Macromed\Flash"
$Path2 = "$env:windir\SYSWOW64\Macromed\Flash"
$File1 = "mms.cfg"

$FilePath1 = "$Path1\$File1"
$FilePath2 = "$Path2\$File1"

$Text1 = "AutoUpdateDisable = 1
AutoUpdateInterval = 365
SilentAutoUpdateEnable = false"


# check if $Path1 exists, if not create it
    if ((Test-Path $Path1) -eq $false)
    {
    #  write-host "$Path1 does not exist. Create it..."
    try
    { New-Item -Path $Path1 -ItemType Directory -Force -ErrorAction Stop | Out-Null }
    catch
    { $_.Exception.Message }
    }
    else
    {}
    # check if $File1 file exists, and create/recreate it
    if ((Test-Path $FilePath1) -eq $true)
    {
    try
    { Remove-Item $FilePath1 -Force -ErrorAction Stop | Out-Null }
    catch
    { $_.Exception.Message }
    }
    try
    {
    New-Item -Path $Path1 -Name $File1 -ItemType File -Force -Value $Text1 | Out-Null
    }
    catch
    { $_.Exception.Message }

# check if $Path2 exists, if not create it
    if ((Test-Path $Path2) -eq $false)
    {
    #  write-host "$Path2 does not exist. Create it..."
    try
    { New-Item -Path $Path2 -ItemType Directory -Force -ErrorAction Stop | Out-Null }
    catch
    { $_.Exception.Message }
    }
    else
    {}
    # check if $File1 file exists, and create/recreate it
    if ((Test-Path $FilePath2) -eq $true)
    {
    try
    { Remove-Item $FilePath2 -Force -ErrorAction Stop | Out-Null }
    catch
    { $_.Exception.Message }
    }
    try
    {
    New-Item -Path $Path2 -Name $File1 -ItemType File -Force -Value $Text1 | Out-Null
    }
    catch
    { $_.Exception.Message }
