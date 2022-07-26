# Set PowerPoint exe locations
$x64_PP_2013 ="C:\Program Files (x86)\Microsoft Office\Office15\POWERPNT.EXE"
$x86_PP_2013 ="C:\Program Files\Microsoft Office\Office15\POWERPNT.EXE"
$x64_PP_2010 ="C:\Program Files (x86)\Microsoft Office\Office14\POWERPNT.EXE"
$x86_PP_2010 ="C:\Program Files\Microsoft Office\Office14\POWERPNT.EXE"
 
# Set Reg branch paths / names
$reg_root_path_2010 = "HKCU:\Software\Microsoft\Office\14.0\Common"
$reg_root_path_2013 = "HKCU:\Software\Microsoft\Office\15.0\Common"
$reg_branch_1 = "Spotlight"
$reg_branch_2 = "Providers"
$reg_Key_name = "DOMAIN" # Change
$x64_xml = "DOMAIN_PP_x64_2016.xml" # Change
$x86_xml = "DOMAIN_PP_x86_2016.xml" # Change
 
# Set Reg key values
$newx86xml = "C:\\Program Files\\Microsoft Office\\Templates\\$x86_xml"
$newx64xml = "C:\\Program Files (x86)\\Microsoft Office\\Templates\\$x64_xml"
 
# Function to add the registry key
function AddRegKey
{
    param ($reg_root_path,$reg_key_Name,$xml,$reg_branch_1,$reg_branch_2)
     
    # Does reg branch exist?  If not, create it
    if (!(Test-path $reg_root_path\$reg_branch_1))
        {
            New-Item -Path $reg_root_path -Name $reg_branch_1
        }
    if (!(Test-path $reg_root_path\$reg_branch_1\$reg_branch_2))
    {
        New-Item -Path $reg_root_path\$reg_branch_1 -Name $reg_branch_2
    }
    if (!(Test-path $reg_root_path\$reg_branch_1\$reg_branch_2\$reg_Key_name))
    {
        New-Item -Path $reg_root_path\$reg_branch_1\$reg_branch_2 -Name $reg_Key_name
    }
    # Add reg key
        New-ItemProperty -Path $reg_root_path\$reg_branch_1\$reg_branch_2\$reg_Key_name -Name ServiceURL -Value $xml -Force
}
 
# X64 OS and Office 2013
if (test-path $x64_PP_2013)
{
    AddRegKey -reg_root_path $reg_root_path_2013 -reg_key_Name $reg_Key_name -xml $newx64xml -reg_branch_1 $reg_branch_1 -reg_branch_2 $reg_branch_2
}
 
# X64 OS and Office 2010
if (test-path $x64_PP_2010)
{
    AddRegKey -reg_root_path $reg_root_path_2010 -reg_key_Name $reg_Key_name -xml $newx64xml -reg_branch_1 $reg_branch_1 -reg_branch_2 $reg_branch_2
}
# X86 OS and Office 2013
if (test-path $x86_PP_2013)
{
    AddRegKey -reg_root_path $reg_root_path_2013 -reg_key_Name $reg_Key_name -xml $newx86xml -reg_branch_1 $reg_branch_1 -reg_branch_2 $reg_branch_2
}
 
# X86 OS and Office 2010
if (test-path $x86_PP_2010)
{
    AddRegKey -reg_root_path $reg_root_path_2010 -reg_key_Name $reg_Key_name -xml $newx86xml -reg_branch_1 $reg_branch_1 -reg_branch_2 $reg_branch_2
}