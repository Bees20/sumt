Insert into CONFIGURATION_KEY ([KEY],DESCRIPTION,KEY_TYPE)
VALUES('CO_ESET_SERVER','ESET server for CO','String')

INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES ((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_SERVER'),(select id from datacenter where code = 'LDC'),'172.26.75.61'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_SERVER'),(select id from datacenter where code = 'GSL'),'172.26.75.61'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_SERVER'),(select id from datacenter where code = 'CMH'),'172.23.75.24'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_SERVER'),(select id from datacenter where code = 'DSM'),'172.23.75.24'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_SERVER'),(select id from datacenter where code = 'AMS'),'172.23.75.24'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_SERVER'),(select id from datacenter where code = 'PCM'),'172.23.75.24')
		
Insert into CONFIGURATION_KEY ([KEY],DESCRIPTION,KEY_TYPE)
VALUES('CO_ESET_PORT','ESET Port for CO','String')
		
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES ((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_PORT'),(select id from datacenter where code = 'LDC'),'2222'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_PORT'),(select id from datacenter where code = 'GSL'),'2222'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_PORT'),(select id from datacenter where code = 'CMH'),'2222'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_PORT'),(select id from datacenter where code = 'DSM'),'2222'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_PORT'),(select id from datacenter where code = 'AMS'),'2222'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_PORT'),(select id from datacenter where code = 'PCM'),'2222')

Insert into CONFIGURATION_KEY ([KEY],DESCRIPTION,KEY_TYPE)
VALUES('CO_ESET_WEBCONSOLE_PORT','ESET Webconsole Port for CO','String')

INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES 
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_WEBCONSOLE_PORT'),(select id from datacenter where code = 'LDC'),'2223'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_WEBCONSOLE_PORT'),(select id from datacenter where code = 'GSL'),'2223'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_WEBCONSOLE_PORT'),(select id from datacenter where code = 'CMH'),'2223'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_WEBCONSOLE_PORT'),(select id from datacenter where code = 'DSM'),'2223'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_WEBCONSOLE_PORT'),(select id from datacenter where code = 'AMS'),'2223'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_WEBCONSOLE_PORT'),(select id from datacenter where code = 'PCM'),'2223')


Insert into CONFIGURATION_KEY ([KEY],DESCRIPTION,KEY_TYPE)
VALUES('CO_ESET_WEBCONSOLE_RESOURCENAME','ESET Resourcename for CO','String')

INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES 
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_WEBCONSOLE_RESOURCENAME'),(select id from datacenter where code = 'LDC'),'ESET_LDC'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_WEBCONSOLE_RESOURCENAME'),(select id from datacenter where code = 'GSL'),'ESET_LDC'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_WEBCONSOLE_RESOURCENAME'),(select id from datacenter where code = 'CMH'),'ESET'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_WEBCONSOLE_RESOURCENAME'),(select id from datacenter where code = 'DSM'),'ESET'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_WEBCONSOLE_RESOURCENAME'),(select id from datacenter where code = 'AMS'),'ESET'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_WEBCONSOLE_RESOURCENAME'),(select id from datacenter where code = 'PCM'),'ESET')
		
Insert into CONFIGURATION_KEY ([KEY],DESCRIPTION,KEY_TYPE)
VALUES('CO_ESET_WEBCONSOLE_ACCOUNTNAME','ESET Accountname CO','String')
		
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES 
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_WEBCONSOLE_ACCOUNTNAME'),(select id from datacenter where code = 'LDC'),'Administrator'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_WEBCONSOLE_ACCOUNTNAME'),(select id from datacenter where code = 'GSL'),'Administrator'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_WEBCONSOLE_ACCOUNTNAME'),(select id from datacenter where code = 'CMH'),'Administrator'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_WEBCONSOLE_ACCOUNTNAME'),(select id from datacenter where code = 'DSM'),'Administrator'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_WEBCONSOLE_ACCOUNTNAME'),(select id from datacenter where code = 'AMS'),'Administrator'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_ESET_WEBCONSOLE_ACCOUNTNAME'),(select id from datacenter where code = 'PCM'),'Administrator')