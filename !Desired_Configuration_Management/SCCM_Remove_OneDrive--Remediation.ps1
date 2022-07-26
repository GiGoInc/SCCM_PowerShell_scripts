# Remediation
# Thanks to raydric, this function should be used instead of `mkdir -force`.
# While `mkdir -force` works fine when dealing with regular folders, it behaves strange when using it at registry level. If the target registry key is already present, all values within that key are purged.

Function Force-mkdir($path)
{
If (!(Test-Path $path)){New-Item -ItemType Directory -Force -Path $path}
}

Function Takeown-Registry($key) {
# TODO does not work for all root keys yet
switch ($key.split('\')[0]) {
"HKEY_CLASSES_ROOT" {
$reg = [Microsoft.Win32.Registry]::ClassesRoot
$key = $key.substring(18)
}
"HKEY_CURRENT_USER" {
$reg = [Microsoft.Win32.Registry]::CurrentUser
$key = $key.substring(18)
}
"HKEY_LOCAL_MACHINE" {
$reg = [Microsoft.Win32.Registry]::LocalMachine
$key = $key.substring(19)
}
}

# get administraor group
$admins = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
$admins = $admins.Translate([System.Security.Principal.NTAccount])

# set owner
$key = $reg.OpenSubKey($key, "ReadWriteSubTree", "TakeOwnership")
$acl = $key.GetAccessControl()
$acl.SetOwner($admins)
$key.SetAccessControl($acl)

# set FullControl
$acl = $key.GetAccessControl()
$rule = New-Object System.Security.AccessControl.RegistryAccessRule($admins, "FullControl", "Allow")
$acl.SetAccessRule($rule)
$key.SetAccessControl($acl)
}

Function Takeown-File($path) {
takeown.exe /A /F $path
$acl = Get-Acl $path

# get administraor group
$admins = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
$admins = $admins.Translate([System.Security.Principal.NTAccount])

# add NT Authority\SYSTEM
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule($admins, "FullControl", "None", "None", "Allow")
$acl.AddAccessRule($rule)

Set-Acl -Path $path -AclObject $acl
}

Function Takeown-Folder($path) {
Takeown-File $path
foreach ($item in Get-ChildItem $path) {
if (Test-Path $item -PathType Container) {
Takeown-Folder $item.FullName
} else {
Takeown-File $item.FullName
}
}
}

Function Elevate-Privileges {
param($Privilege)
$Definition = @"
using System;
using System.Runtime.InteropServices;

public class AdjPriv {
[DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
internal static extern bool AdjustTokenPrivileges(IntPtr htok, bool disall, ref TokPriv1Luid newst, int len, IntPtr prev, IntPtr rele);

[DllImport("advapi32.dll", ExactSpelling = true, SetLastError = true)]
internal static extern bool OpenProcessToken(IntPtr h, int acc, ref IntPtr phtok);

[DllImport("advapi32.dll", SetLastError = true)]
internal static extern bool LookupPrivilegeValue(string host, string name, ref long pluid);

[StructLayout(LayoutKind.Sequential, Pack = 1)]
internal struct TokPriv1Luid {
public int Count;
public long Luid;
public int Attr;
}

internal const int SE_PRIVILEGE_ENABLED = 0x00000002;
internal const int TOKEN_QUERY = 0x00000008;
internal const int TOKEN_ADJUST_PRIVILEGES = 0x00000020;

public static bool EnablePrivilege(long processHandle, string privilege) {
bool retVal;
TokPriv1Luid tp;
IntPtr hproc = new IntPtr(processHandle);
IntPtr htok = IntPtr.Zero;
retVal = OpenProcessToken(hproc, TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, ref htok);
tp.Count = 1;
tp.Luid = 0;
tp.Attr = SE_PRIVILEGE_ENABLED;
retVal = LookupPrivilegeValue(null, privilege, ref tp.Luid);
retVal = AdjustTokenPrivileges(htok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero);
return retVal;
}
}
"@
$ProcessHandle = (Get-Process -id $pid).Handle
$type = Add-Type $definition -PassThru
$type[0]::EnablePrivilege($processHandle, $Privilege)
}

#   Description:
# This script will remove and disable OneDrive integration.

# Import-Module -DisableNameChecking .\force-mkdir.psm1
# Import-Module -DisableNameChecking .\take-own.psm1

Write-Host "Kill OneDrive process"
taskkill.exe /F /IM "OneDrive.exe"
# taskkill.exe /F /IM "explorer.exe"

Write-Host "Remove OneDrive"
if (Test-Path "$env:systemroot\System32\OneDriveSetup.exe")
{
& "$env:systemroot\System32\OneDriveSetup.exe" /uninstall
}
if (Test-Path "$env:systemroot\SysWOW64\OneDriveSetup.exe")
{
& "$env:systemroot\SysWOW64\OneDriveSetup.exe" /uninstall
}
Start-Sleep -Seconds 10

Write-Host "Removing OneDrive leftovers"
rm -Recurse -Force -ErrorAction SilentlyContinue "$env:localappdata\Microsoft\OneDrive"
rm -Recurse -Force -ErrorAction SilentlyContinue "$env:programdata\Microsoft OneDrive"
rm -Recurse -Force -ErrorAction SilentlyContinue "C:\OneDriveTemp"

Write-Host "Disable OneDrive via Group Policies"
mkdir -Force "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive"
sp "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive" "DisableFileSyncNGSC" 1

Write-Host "Remove Onedrive from explorer sidebar"
New-PSDrive -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" -Name "HKCR"
mkdir -Force "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
sp "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0
mkdir -Force "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}"
sp "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" "System.IsPinnedToNameSpaceTree" 0
Remove-PSDrive "HKCR"

# Thank you Matthew Israelsson
Write-Host "Removing run hook for new users"
reg load "hku\Default" "C:\Users\Default\NTUSER.DAT"
reg delete "HKEY_USERS\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f
reg unload "hku\Default"

Write-Host "Removing startmenu entry"
rm -Force -ErrorAction SilentlyContinue "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk"

Write-Host "Restarting explorer"
# start "explorer.exe"

Write-Host "Waiting for explorer to complete loading"
Start-Sleep -Seconds 10

Write-Host "Removing additional OneDrive leftovers"
foreach ($item in (ls "$env:WinDir\WinSxS\*onedrive*")) {
Takeown-Folder $item.FullName
rm -Recurse -Force $item.FullName

$Path1 = "$env:systemroot\System32\OneDriveSetup.exe"
$Path2 = "$env:systemroot\SysWOW64\OneDriveSetup.exe"
If (Test-Path $Path1)
{
Write-Host $Path1
Takeown-Folder $Path1
Remove-Item -Recurse -Force $Path1
}
If (Test-Path $Path2)
{
Write-Host $Path2
Takeown-Folder $Path2
Remove-Item -Recurse -Force $Path2
}
}