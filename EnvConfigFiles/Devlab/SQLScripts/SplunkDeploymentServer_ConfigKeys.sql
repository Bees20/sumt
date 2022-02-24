Insert into CONFIGURATION_KEY ([KEY],DESCRIPTION,KEY_TYPE)
VALUES('CO_SPLUNK_DEPLOYMENT_SERVER','Splunk Deployment server for CO','String')

INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES ((select ID from CONFIGURATION_KEY where [KEY] = 'CO_SPLUNK_DEPLOYMENT_SERVER'),(select id from datacenter where code = 'LDC'),'devsplupv011.cotestdev.local:8089'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_SPLUNK_DEPLOYMENT_SERVER'),(select id from datacenter where code = 'GSL'),'devsplupv011.cotestdev.local:8089'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_SPLUNK_DEPLOYMENT_SERVER'),(select id from datacenter where code = 'CMH'),'cmhsplupv011.od.local:8089'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_SPLUNK_DEPLOYMENT_SERVER'),(select id from datacenter where code = 'DSM'),'cmhsplupv011.od.local:8089'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_SPLUNK_DEPLOYMENT_SERVER'),(select id from datacenter where code = 'AMS'),'cmhsplupv011.od.local:8089'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_SPLUNK_DEPLOYMENT_SERVER'),(select id from datacenter where code = 'PCM'),'cmhsplupv011.od.local:8089')
