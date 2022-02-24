Insert into CONFIGURATION_KEY ([KEY],DESCRIPTION,KEY_TYPE)
VALUES('CO_REPO_SERVER','Repo server for CO','String')

INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES ((select ID from CONFIGURATION_KEY where [KEY] = 'CO_REPO_SERVER'),(select id from datacenter where code = 'LDC'),'LDCSALTREP001'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_REPO_SERVER'),(select id from datacenter where code = 'CMH'),'CMHSALGPV001'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_REPO_SERVER'),(select id from datacenter where code = 'DSM'),'DSMSALGPV001'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_REPO_SERVER'),(select id from datacenter where code = 'AMS'),'AMSSALGPV001'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_REPO_SERVER'),(select id from datacenter where code = 'PCM'),'PCMSALGPV001')
