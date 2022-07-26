select
case Flags
when 1 then 'No Scheduled Update'
when 2 then 'Full Scheduled Update'
when 4 then 'Incremental Update (Only)'
when 6 then 'Incremental and Full Update Scheduled'
when 4100 then 'default collection'
else 'total'
End as  ScheduleType,
count(*) as Total
from v_Collections_G
where siteid not like 'SMS%'
group by flags,flags with rollup