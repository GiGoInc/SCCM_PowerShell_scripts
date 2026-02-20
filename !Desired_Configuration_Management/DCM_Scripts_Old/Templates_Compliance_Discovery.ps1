# Determine OS Architecture
else {write-host "Not Compliant"}
    {write-host "Compliant"}
# Determine OS Architecture
$OSArch = Get-WmiObject -Class win32_operatingsystem | select -ExpandProperty OSArchitecture
 
# Set local template location
$ProviderName = "COM" # Change
$x86RootPath = "C:\Program Files\Microsoft Office\Templates\$ProviderName"
$x64RootPath = "C:\Program Files (x86)\Microsoft Office\Templates\$ProviderName"
 
$Compliance = 0
 
$x86FilesToCheck = @(
    "COM_PP_Preview_2016.PNG", # Change
    "COM_PP_Template_2016.potx", # Change
    "COM_PP_Thumb_2016.PNG", # Change
    "COM_PP_x86_2016.xml", # Change
    "HW_PP_Preview_2016.PNG", # Change
    "HW_PP_Template_2016.potx", # Change
    "HW_PP_Thumb_2016.PNG" # Change
    )
 
$x64FilesToCheck = @(
    "COM_PP_Preview_2016.PNG", # Change
    "COM_PP_Template_2016.potx", # Change
    "COM_PP_Thumb_2016.PNG", # Change
    "COM_PP_x64_2016.xml", # Change
    "HW_PP_Preview_2016.PNG", # Change
    "HW_PP_Template_2016.potx", # Change
    "HW_PP_Thumb_2016.PNG" # Change
    )
 
if ($OSArch -eq "64-bit")
    {
        foreach ($file in $x64FilesToCheck)
            {
                if (test-path -Path $x64RootPath\$file)
                    {$Compliance ++}
            }
    }
 
if ($OSArch -eq "32-bit")
    {
        foreach ($file in $x86FilesToCheck)
            {
                if (test-path -Path $x86RootPath\$file)
                    {$Compliance ++}
            }
    }
 
if ($Compliance -eq 7)
    {write-host "Compliant"}
else {write-host "Not Compliant"}
