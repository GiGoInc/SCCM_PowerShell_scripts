# Determine OS Architecture
}
    CopyTemplateFiles -rootpath $x64RootPath -templatearray $newx64Array -newTemplateRootPath $newTemplateRootPath -oldArray $oldArray
# Determine OS Architecture
$OSArch = Get-WmiObject -Class win32_operatingsystem | select -ExpandProperty OSArchitecture
 
# Set local template location
$ProviderName = "COM" # Change
$x86RootPath = "C:\Program Files\Microsoft Office\Templates\$ProviderName"
$x64RootPath = "C:\Program Files (x86)\Microsoft Office\Templates\$ProviderName"
 
# Set old  file names
  $oldtemplate = "HW_PP_Template_2015.potx" # Change
$oldPreviewPNG = "HW_PP_Preview_2015.png" # Change
  $oldThumbPNG = "HW_PP_Thumb_2015.png" # Change

  $old2template = "COM_PP_Template_2015.potx" # Change
$old2PreviewPNG = "COM_PP_Preview_2015.PNG" # Change
  $old2ThumbPNG = "COM_PP_Thumb_2015.PNG" # Change

$oldx86xml = "COM_PP_x86_2015.xml" # Change
$oldx64xml = "COM_PP_x64_2015.xml" # Change
 
# Set new file names
$newTemplateRootPath = "." # Change
  $newtemplate = "HW_PP_Template_2016.potx" # Change
$newPreviewPNG = "HW_PP_Preview_2016.PNG" # Change
  $newThumbPNG = "HW_PP_Thumb_2016.PNG" # Change

  $new2template = "COM_PP_Template_2016.potx" # Change
$new2PreviewPNG = "COM_PP_Preview_2016.PNG" # Change
  $new2ThumbPNG = "COM_PP_Thumb_2016.PNG" # Change

$newx86xml  = "COM_PP_x86_2016.xml" # Change
$newx64xml  = "COM_PP_x64_2016.xml" # Change
 
$oldArray = @($oldtemplate,$oldPreviewPNG,$oldThumbPNG,$old2template,$old2PreviewPNG,$old2ThumbPNG,$oldx86xml,$oldx64xml)
$newx86Array = @($newtemplate,$newPreviewPNG,$newThumbPNG,$new2template,$new2PreviewPNG,$new2ThumbPNG,$newx86xml)
$newx64Array = @($newtemplate,$newPreviewPNG,$newThumbPNG,$new2template,$new2PreviewPNG,$new2ThumbPNG,$newx64xml)
 
# Function to copy the template files
function CopyTemplateFiles
{
    param($rootpath,$templatearray,$newTemplateRootPath,$oldArray)

    # If template directory doesn't exist, create it
    if (!(test-path -Path $rootpath))
    {
        New-Item -Path $rootpath -ItemType Directory -Force
    }
    # Otherwise delete old template files if they exist
    Else
    {
        foreach ($item in $oldarray)
        {
            $ItemPath = "$rootpath\$item"
            if (Test-path -Path $ItemPath)
            {
                Write-Host "Found item: $ItemPath, deleting!"
                Remove-Item $ItemPath -Force
            }
        }
    }
    #  Copy new template files
    foreach ($item in $templatearray)
    {
        Copy-Item -Path $newTemplateRootPath\$item -Destination $rootpath -Force
    }
}
 
# Let's do it!
if ($OSArch -eq "32-bit")
{
    CopyTemplateFiles -rootpath $x86RootPath -templatearray $newx86Array -newTemplateRootPath $newTemplateRootPath -oldArray $oldArray
}
 
if ($OSArch -eq "64-bit")
{
    CopyTemplateFiles -rootpath $x64RootPath -templatearray $newx64Array -newTemplateRootPath $newTemplateRootPath -oldArray $oldArray
}
