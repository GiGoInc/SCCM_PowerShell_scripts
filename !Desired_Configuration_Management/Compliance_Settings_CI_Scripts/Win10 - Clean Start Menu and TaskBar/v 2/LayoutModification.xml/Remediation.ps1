$sb = {<?xml version="1.0" encoding="utf-8"?>
$sb | Set-Content $Path
$Path = 'C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml'
$sb = {<?xml version="1.0" encoding="utf-8"?>
<LayoutModificationTemplate
xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification"
xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout"
xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout"
xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout"
Version="1">
<LayoutOptions StartTileGroupCellWidth="6" StartTileGroupsColumnCount="1" />
<DefaultLayoutOverride LayoutCustomizationRestrictionType="OnlySpecifiedGroups">
<StartLayoutCollection>
<defaultlayout:StartLayout GroupCellWidth="6" xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout">
<start:Group Name="Edge" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout">
<start:Tile Size="2x2" Column="0" Row="0" AppUserModelID="Microsoft.MicrosoftEdge_8wekyb3d8bbwe!MicrosoftEdge" />
</start:Group>
</defaultlayout:StartLayout>
</StartLayoutCollection>
</DefaultLayoutOverride>
<CustomTaskbarLayoutCollection PinListPlacement="Replace">
<defaultlayout:TaskbarLayout>
<taskbar:TaskbarPinList>
<taskbar:DesktopApp DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\System Tools\File Explorer.lnk" />
<taskbar:DesktopApp DesktopApplicationLinkPath="%APPDATA%\Microsoft\Windows\Start Menu\Programs\Accessories\Internet Explorer.lnk"/>
</taskbar:TaskbarPinList>
</defaultlayout:TaskbarLayout>
</CustomTaskbarLayoutCollection>
</LayoutModificationTemplate>}

$Path = 'C:\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml'
$sb | Set-Content $Path
