D:
(Get-Content $File) | foreach-Object {invoke-command -ScriptBlock ${function:RunFunc} -ArgumentList $_}
				
D:
CD 'D:\Program Files\Microsoft Configuration Manager\AdminConsole\bin'
Import-Module ".\ConfigurationManager.psd1"
Set-Location XX1:
CD XX1:

    $File = "E:\Packages\Powershell_Scripts\SCCM_Collection_Cleanup_Direct_Membership_list.txt"

	
function RunFunc($CollectionID)
{
    # Get collection from WMI
    $coll = Get-WmiObject -Namespace root\sms\site_XX1 -Class sms_collection -Filter "CollectionID = '$CollectionID'"

    # Continue if we got a collection
    if ($coll) {

        Write-Output "Found collection $($coll.Name)"

        # Load lazy properties
        $coll.get()

        # Create arrays for holding members
        $members = @()
        $directmembers = @()

        # Get all ResourceIDs that are member by a DirectRule
        $directmembers += Get-WmiObject -Namespace root\sms\site_XX1 -Query "SELECT * FROM SMS_CollectionMember_A WHERE CollectionID = '$CollectionID'" | Where IsDirect -eq $True | Select ResourceID
        Write-Output "Found $($directmembers.count) direct members"

        # Continue if there are any direct members
        if ($directmembers.Count -gt 0) {

            # Get all collection rules
            foreach ($item in $coll.CollectionRules) {

                # Continue if the rule is a query based rule
                if ($item.__CLASS -eq "SMS_CollectionRuleQuery") {

                    # Get the query
                    $query = $item.queryExpression
                    Write-Output "Found query rule called $($item.RuleName)"

                    # Get the result of the query from SCCM
                    $result = Get-WmiObject -Namespace root\sms\site_XX1 -Query $query
                    Write-Output "Got result of query"

                    # Loop through all resources in the result
                    foreach ($resource in $result) {
                        
                        # If the resourceID is not yet in the members array
                        if ($members -notcontains $resource.ResourceId) {
                            
                            # Add it to the array
                            $members += $resource.ResourceID
                        }
                    }
                }   
            }

            # Summary for the query based rules
            Write-Output "Found $($members.count) members using queries"

            # Loop through all direct rules 
            foreach ($item in $coll.CollectionRules) {
                if ($item.__CLASS -eq "SMS_CollectionRuleDirect") {
                    Write-Output "Found direct rule for $($Item.ResourceID)"

                    # If the ResourceID is found in members
                    #if ($members -contains $item.ResourceID) {

                        # Remove the direct rule for this resourceID
                        $coll.DeleteMembershipRule($item) | Out-Null
                        Write-Output "DirectRule for $($member.ResourceID) was deleted"
                    #}
                }
            }

            # Finally request a refresh of the Collection just for good measure
            $Coll.RequestRefresh($true) | Out-Null
            Write-Output "Collection refresh for $($Coll.Name) was requested"

        } else {
            # No direct memberships where found
            Write-Output "No direct memberships found"
        }
    }
}

				
(Get-Content $File) | foreach-Object {invoke-command -ScriptBlock ${function:RunFunc} -ArgumentList $_}
