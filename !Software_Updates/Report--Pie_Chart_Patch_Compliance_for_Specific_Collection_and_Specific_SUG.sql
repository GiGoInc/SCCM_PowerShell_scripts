select CASE WHEN ucs.status=3 or ucs.status=1  then 'success'
When ucs.status=2 Then 'Missing'
When ucs.status=0 Then 'Unknown' end as 'Status',ucs.status [Status ID],coll.CollectionID
From v_Update_ComplianceStatusAll UCS
    left join v_r_system sys on ucs.resourceid=sys.resourceid
    left join v_FullCollectionMembership fcm on ucs.resourceid=fcm.resourceid
    left join v_collection coll on coll.CollectionID=fcm.CollectionID
    left join v_GS_OPERATING_SYSTEM os on ucs.resourceid=os.resourceid
    left join v_gs_workstation_status ws on ucs.resourceid=ws.resourceid
    left join v_updatescanstatus uss on ucs.ResourceId=uss.ResourceID
    left join v_AuthListInfo LI on li.ci_id=ucs.ci_id
where li.title='ADR: Software Updates - Servers' and coll.CollectionID='SS1008BB'
and os.Caption0 not like '%2003%'
order by 1