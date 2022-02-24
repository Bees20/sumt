/* Creating TimeZone configuration key */

IF NOT EXISTS(SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] ='TimeZone')
Insert into CONFIGURATION_KEY ([KEY],DESCRIPTION,KEY_TYPE)
VALUES('TimeZone','TimeZone for each DC','String')
GO

/*
IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'TimeZone') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'LDC'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'TimeZone'),(select id from datacenter where code = 'LDC'),'America/New_York')
GO
IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'TimeZone') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'GSL'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'TimeZone'),(select id from datacenter where code = 'GSL'),'America/New_York')
GO
*/
IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'TimeZone') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'CMH'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'TimeZone'),(select id from datacenter where code = 'CMH'),'America/New_York')
GO
IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'TimeZone') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'DSM'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'TimeZone'),(select id from datacenter where code = 'DSM'),'America/Chicago')
GO
IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'TimeZone') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'AMS'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'TimeZone'),(select id from datacenter where code = 'AMS'),'Europe/Berlin')
GO
IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'TimeZone') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'PCM'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'TimeZone'),(select id from datacenter where code = 'PCM'),'America/New_York')
GO

/*
Insert into CONFIGURATION_KEY ([KEY],DESCRIPTION,KEY_TYPE)
VALUES('TimeZone','TimeZone for each DC','String')


INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES ((select ID from CONFIGURATION_KEY where [KEY] = 'TimeZone'),(select id from datacenter where code = 'LDC'),'America/New_York'),
((select ID from CONFIGURATION_KEY where [KEY] = 'TimeZone'),(select id from datacenter where code = 'GSL'),'America/New_York'),
((select ID from CONFIGURATION_KEY where [KEY] = 'TimeZone'),(select id from datacenter where code = 'CMH'),'America/New_York'),
((select ID from CONFIGURATION_KEY where [KEY] = 'TimeZone'),(select id from datacenter where code = 'DSM'),'America/Chicago'),
((select ID from CONFIGURATION_KEY where [KEY] = 'TimeZone'),(select id from datacenter where code = 'AMS'),'Europe/Berlin'),
((select ID from CONFIGURATION_KEY where [KEY] = 'TimeZone'),(select id from datacenter where code = 'PCM'),'America/New_York')