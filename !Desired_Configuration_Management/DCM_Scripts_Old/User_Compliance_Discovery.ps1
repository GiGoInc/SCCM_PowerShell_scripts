# Set PowerPoint exe locations
}
    CheckRegKey -office_path $Office_2010_path -RemoteLocale_Name $Provider_Name -key_value $x86_key -xml $x86_xml
# Set PowerPoint exe locations
$x64_PP_2013 ="C:\Program Files (x86)\Microsoft Office\Office15\POWERPNT.EXE"
$x86_PP_2013 ="C:\Program Files\Microsoft Office\Office15\POWERPNT.EXE"
$x64_PP_2010 ="C:\Program Files (x86)\Microsoft Office\Office14\POWERPNT.EXE"
$x86_PP_2010 ="C:\Program Files\Microsoft Office\Office14\POWERPNT.EXE"
 
# Set Registry key paths
$Office_2010_path = "HKCU:\Software\Microsoft\Office\14.0\Common\Spotlight\Providers"
$Office_2013_path = "HKCU:\Software\Microsoft\Office\15.0\Common\Spotlight\Providers"
$Provider_Name = "COM" # Change
 
# Set Registry key values
$x64_key = "C:\\Program Files (x86)\\Microsoft Office\\Templates\\"
$x86_key = "C:\\Program Files\\Microsoft Office\\Templates\\"
$x64_xml = "COM_PP_x64_2016.xml" # Change
$x86_xml = "COM_PP_x86_2016.xml" # Change
 
# Function to check the registry key value
function CheckRegKey {
 
param ($office_path,$RemoteLocale_Name,$key_value,$xml)
    $key = Get-ItemProperty -Path $office_path\$RemoteLocale_Name -Name ServiceURL -ErrorAction SilentlyContinue | Select -ExpandProperty ServiceURL
    if (!$key)
    {
        Write-Host "Not Compliant"; break
    }
    if ($key -eq "$key_value" + "$xml")
    {
        Write-Host "Compliant"
    }
    if ($key -ne "$key_value" + "$xml")
    {
        Write-Host "Not Compliant"
    }
}
 
# Let's do it!
if (Test-Path $x64_PP_2013)
{
    CheckRegKey -office_path $Office_2013_path -RemoteLocale_Name $Provider_Name -key_value $x64_key -xml $x64_xml
}
 
if (Test-Path $x86_PP_2013)
{
    CheckRegKey -office_path $Office_2013_path -RemoteLocale_Name $Provider_Name -key_value $x86_key -xml $x86_xml
}
 
if (Test-Path $x64_PP_2010)
{
    CheckRegKey -office_path $Office_2010_path -RemoteLocale_Name $Provider_Name -key_value $x64_key -xml $x64_xml
}
 
if (Test-Path $x86_PP_2010)
{
    CheckRegKey -office_path $Office_2010_path -RemoteLocale_Name $Provider_Name -key_value $x86_key -xml $x86_xml
}
