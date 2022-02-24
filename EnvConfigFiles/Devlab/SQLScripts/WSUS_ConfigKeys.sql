Insert into CONFIGURATION_KEY ([KEY],DESCRIPTION,KEY_TYPE)
VALUES('CO_WSUS_SERVER','WSUS server for CO','String')


INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES ((select ID from CONFIGURATION_KEY where [KEY] = 'CO_WSUS_SERVER'),(select id from datacenter where code = 'LDC'),'devutlupv041.cotestdev.local:8530'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_WSUS_SERVER'),(select id from datacenter where code = 'GSL'),'devutlupv041.cotestdev.local:8530'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_WSUS_SERVER'),(select id from datacenter where code = 'CMH'),'dsmutlupv067.od.local:8530'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_WSUS_SERVER'),(select id from datacenter where code = 'DSM'),'dsmutlupv067.od.local:8530'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_WSUS_SERVER'),(select id from datacenter where code = 'AMS'),'dsmutlupv067.od.local:8530'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_WSUS_SERVER'),(select id from datacenter where code = 'PCM'),'pcmhutlupv002.copci.local:8530')
