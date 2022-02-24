Insert into CONFIGURATION_KEY ([KEY],DESCRIPTION,KEY_TYPE)
VALUES('CO_SYSLOG_SERVER','Syslog server for CO','String')

Insert into CONFIGURATION_KEY ([KEY],DESCRIPTION,KEY_TYPE)
VALUES('CO_NTP_SERVER','NTP server for CO','String')

INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES ((select ID from CONFIGURATION_KEY where [KEY] = 'CO_SYSLOG_SERVER'),(select id from datacenter where code = 'LDC'),'dev-syslog.cotestdev.local'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_SYSLOG_SERVER'),(select id from datacenter where code = 'GSL'),'dev-syslog.cotestdev.local'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_SYSLOG_SERVER'),(select id from datacenter where code = 'CMH'),'cmh-syslog.od.local'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_SYSLOG_SERVER'),(select id from datacenter where code = 'DSM'),'dsm-syslog.od.local'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_SYSLOG_SERVER'),(select id from datacenter where code = 'AMS'),'ams-syslog.od.local'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_SYSLOG_SERVER'),(select id from datacenter where code = 'PCM'),'copci-syslog.copci.local')
		
		
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES ((select ID from CONFIGURATION_KEY where [KEY] = 'CO_NTP_SERVER'),(select id from datacenter where code = 'LDC'),'dev-time.cotestdev.local'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_NTP_SERVER'),(select id from datacenter where code = 'GSL'),'dev-time.cotestdev.local'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_NTP_SERVER'),(select id from datacenter where code = 'CMH'),'cmh-time.od.local'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_NTP_SERVER'),(select id from datacenter where code = 'DSM'),'dsm-time.od.local'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_NTP_SERVER'),(select id from datacenter where code = 'AMS'),'ams-time.od.local'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_NTP_SERVER'),(select id from datacenter where code = 'PCM'),'copci-time.copci.local')