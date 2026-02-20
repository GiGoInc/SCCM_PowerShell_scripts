$Server = "SERVER"
}
    $array
$Server = "SERVER"
$site = "XX1"

Function Get-Collections 
{
    <# 
            .SYNOPSIS 
                Determine the SCCM collection membership    
            .DESCRIPTION
                This function allows you to determine the SCCM collection membership of a given user/computer
            .PARAMETER  Type 
                Specify the type of member you are querying. Possible values : 'User' or 'Computer'
            .PARAMETER  ResourceName 
                Specify the name of your member : username or computername
            .EXAMPLE 
                Get-Collections -Type computer -ResourceName PC001
                Get-Collections -Type user -ResourceName User01
            .Notes 
                Author : Antoine DELRUE 
                WebSite: http://obilan.be 
    #> 

    param(
    [Parameter(Mandatory=$true,Position=1)]
    [ValidateSet("User", "Computer")]
    [string]$type,

    [Parameter(Mandatory=$true,Position=2)]
    [string]$resourceName
    ) #end param

    Switch ($type)
        {
            User {
                Try {
                    $ErrorActionPreference = 'Stop'
                    $resource = Get-WmiObject -ComputerName $server -Namespace "root\sms\site_$site" -Class "SMS_R_User" | ? {$_.Name -ilike "*$resourceName*"}                            
                }
                catch {
                    Write-Warning ('Failed to access "{0}" : {1}' -f $server, $_.Exception.Message)
                }

            }

            Computer {
                Try {
                    $ErrorActionPreference = 'Stop'
                    $resource = Get-WmiObject -ComputerName $server -Namespace "root\sms\site_$site" -Class "SMS_R_System" | ? {$_.Name -ilike "$resourceName"}                           
                }
                catch {
                    Write-Warning ('Failed to access "{0}" : {1}' -f $server, $_.Exception.Message)
                }
            }
        }

    $ids = (Get-WmiObject -ComputerName $server -Namespace "root\sms\site_$site" -Class SMS_CollectionMember_a -filter "ResourceID=`"$($Resource.ResourceId)`"").collectionID
    # A little trick to make the function work with SCCM 2012
    if ($ids -eq $null)
    {
            $ids = (Get-WmiObject -ComputerName $server -Namespace "root\sms\site_$site" -Class SMS_FullCollectionMembership -filter "ResourceID=`"$($Resource.ResourceId)`"").collectionID
    }

    $array = @()

    foreach ($id in $ids)
    {
        $Collection = get-WMIObject -ComputerName $server -namespace "root\sms\site_$site" -class sms_collection -Filter "collectionid=`"$($id)`""
        $Object = New-Object PSObject
        $Object | Add-Member -MemberType NoteProperty -Name "Collection Name" -Value $Collection.Name
        $Object | Add-Member -MemberType NoteProperty -Name "Collection ID" -Value $id
        $Object | Add-Member -MemberType NoteProperty -Name "Comment" -Value $Collection.Comment
        $array += $Object
    }

    $array
}
