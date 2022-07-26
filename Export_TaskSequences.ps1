cls
. GoGo_SCCM_Module.ps1
$ADateS = Get-Date
Write-Host "Script - Start: $ADateS1" -ForegroundColor Green
############################################################################
# Get Task Sequence Names
    $ADateS1 = Get-Date
    Write-Host "Script - Start: $ADateS1" -ForegroundColor Green
    $TSNames = Get-CMTaskSequence | select name
    $ADateE1 = Get-Date
    $t = NEW-TIMESPAN –Start $ADateS1 –End $ADateE1 | select Minutes,Seconds
    $min = $t.Minutes
    $sec = $t.seconds
    Write-Host "Completed: $ADateE1" -ForegroundColor Cyan
    Write-Host "Runtime: $min minutes and $sec seconds."
############################################################################
# Build Zip files of Task Sequences
    $ADateS2 = Get-Date
    Write-Host "Zip Build - Start: $ADateS2" -ForegroundColor Green
    $total = $TSNames.length
    $i = 1
    $ZipFiles = @()
    ForEach ($TS in $TSNames)
    {
        $ADateS3 = Get-Date
        Write-Host "`tZip - Building: $ADateS3" -ForegroundColor Yellow
        $N = $TS.name
        $Folder = $($TS.name).replace(' ','_').replace('*','-')
        Write-Host "`t$N"
        $P = 'D:\Projects\SCCM_Stuff\Task_Sequences_Exported\' + $Folder + '.zip'
        $ZipFiles += $P
        Write-Host "`t$i of $total -- Exporting $N to $P" -ForegroundColor magenta
        Export-CMTaskSequence -WithDependence $False -WithContent $False -Name "$N" -ExportFilePath "$P"
        $i++
        $ADateE3 = Get-Date
        $t = NEW-TIMESPAN –Start $ADateS3 –End $ADateE3 | select Minutes,Seconds
        $min = $t.Minutes
        $sec = $t.seconds
        Write-Host "`tZip - Completed: $ADateE3" -ForegroundColor Red
        Write-Host "`tZip - Rutime: $min minutes and $sec seconds."
    }
    $ADateE2 = Get-Date
    $t = NEW-TIMESPAN –Start $ADateS2 –End $ADateE2 | select Minutes,Seconds
    $min = $t.Minutes
    $sec = $t.seconds
    Write-Host "Zip Build - Completed: $ADateE2" -ForegroundColor Cyan
    Write-Host "Zip Build - Runtime: $min minutes and $sec seconds."
############################################################################
# EXTRACT ZIP FILES
    ###########################################################  
    # AUTHOR  : Marius / Hican - http://www.hican.nl - @hicannl   
    # DATE    : 26-06-2012   
    # COMMENT : Search zip files for specific files and extract 
    #           them to a (temp) directory. 
    ########################################################### 
     
    #ERROR REPORTING ALL 
    Set-StrictMode -Version latest 
     
    #---------------------------------------------------------- 
    #STATIC VARIABLES 
    #---------------------------------------------------------- 
    $search = "AppReferencesInfo.xml" 
    $dest   = "D:\Projects\SCCM_Stuff\Task_Sequences_Exported\ZipFiles" 
    $zips   = "D:\Projects\SCCM_Stuff\Task_Sequences_Exported" 
     
    #---------------------------------------------------------- 
    #FUNCTION GetZipFileItems 
    #---------------------------------------------------------- 
    Function GetZipFileItems 
    { 
      Param([string]$zip) 
       
      $split = $split.Split(".") 
      $dest = $dest + "\" + $split[0] 
      If (!(Test-Path $dest)) 
      { 
        Write-Host "Created folder : $dest" 
        $strDest = New-Item $dest -Type Directory 
      } 
     
      $shell   = New-Object -Com Shell.Application 
      $zipItem = $shell.NameSpace($zip) 
      $items   = $zipItem.Items() 
      GetZipFileItemsRecursive $items 
    } 
     
    #---------------------------------------------------------- 
    #FUNCTION GetZipFileItemsRecursive 
    #---------------------------------------------------------- 
    Function GetZipFileItemsRecursive 
    { 
      Param([object]$items) 
     
      ForEach($item In $items) 
      { 
        If ($item.GetFolder -ne $Null) 
        { 
          GetZipFileItemsRecursive $item.GetFolder.items() 
        } 
        $strItem = [string]$item.Name 
        If ($strItem -Like "*$search*") 
        { 
          If ((Test-Path ($dest + "\" + $strItem)) -eq $False) 
          { 
            Write-Host "Copied file : $strItem from zip-file : $zipFile to destination folder" 
            $shell.NameSpace($dest).CopyHere($item) 
          } 
          Else 
          { 
            Write-Host "File : $strItem already exists in destination folder" 
          } 
        } 
      } 
    } 
     
    #---------------------------------------------------------- 
    #FUNCTION GetZipFiles 
    #---------------------------------------------------------- 
    Function GetZipFiles 
    { 
      $zipFiles = Get-ChildItem -Path $zips -Recurse -Filter "*.zip" | % { $_.DirectoryName + "\$_" } 
       
      ForEach ($zipFile In $zipFiles) 
      { 
        $split = $zipFile.Split("\")[-1] 
        Write-Host "Found zip-file : $split" 
        GetZipFileItems $zipFile 
      } 
    } 
    #RUN SCRIPT  
    GetZipFiles 
############################################################################
$ADateE = Get-Date
$t = NEW-TIMESPAN –Start $ADateS –End $ADateE | select Minutes,Seconds
$min = $t.Minutes
$sec = $t.seconds
Write-Host "Script - Completed: $ADateE" -ForegroundColor Cyan
Write-Host "Total Runtime: $min minutes and $sec seconds."