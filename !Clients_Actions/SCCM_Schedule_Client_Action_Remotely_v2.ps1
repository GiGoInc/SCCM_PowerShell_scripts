‘Discovery Data Collection Cycle’
WMIC /node:%computername% /namespace:\\root\ccm path sms_client CALL TriggerSchedule "{00000000-0000-0000-0000-000000000003}" /NOINTERACTIVE