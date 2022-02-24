
IF NOT EXISTS(SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] ='SOLARWINDS_ORION_HOST')
insert into CONFIGURATION_KEY ([key],DESCRIPTION,DEFAULT_VALUE,KEY_TYPE,IS_SECURE,SHOW_ON_UI) values
('SOLARWINDS_ORION_HOST', 'OrionDB host', 'NULL', 'String', 0, 1)
GO

IF NOT EXISTS(SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] ='SOLARWINDS_ORION_DB_NAME')
insert into CONFIGURATION_KEY ([key],DESCRIPTION,DEFAULT_VALUE,KEY_TYPE,IS_SECURE,SHOW_ON_UI) values
('SOLARWINDS_ORION_DB_NAME', 'OrionDB DB name', 'NULL', 'String', 0, 1)
GO

IF NOT EXISTS(SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] ='SOLARWINDS_ORION_INSTANCE_NAME')
insert into CONFIGURATION_KEY ([key],DESCRIPTION,DEFAULT_VALUE,KEY_TYPE,IS_SECURE,SHOW_ON_UI) values
('SOLARWINDS_ORION_INSTANCE_NAME', 'OrionDB Instance name', 'NULL', 'String', 0, 1)
GO

IF NOT EXISTS(SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] ='SOLARWINDS_ORION_PORT')
insert into CONFIGURATION_KEY ([key],DESCRIPTION,DEFAULT_VALUE,KEY_TYPE,IS_SECURE,SHOW_ON_UI) values
('SOLARWINDS_ORION_PORT', 'OrionDB Port', 'NULL', 'String', 0, 1)
GO


IF NOT EXISTS(SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] ='SOLARWINDS_ORION_USERNAME')
insert into CONFIGURATION_KEY ([key],DESCRIPTION,DEFAULT_VALUE,KEY_TYPE,IS_SECURE,SHOW_ON_UI) values
('SOLARWINDS_ORION_USERNAME', 'OrionDB User', 'NULL', 'String', 0, 1)
GO



IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SOLARWINDS_ORION_HOST') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'AMS'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SOLARWINDS_ORION_HOST'),(select id from datacenter where code = 'AMS'),'cmhoriondpv002.od.local')
GO

IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SOLARWINDS_ORION_HOST') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'DSM'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SOLARWINDS_ORION_HOST'),(select id from datacenter where code = 'DSM'),'cmhoriondpv002.od.local')
GO


IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SOLARWINDS_ORION_HOST') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'PCM'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SOLARWINDS_ORION_HOST'),(select id from datacenter where code = 'PCM'),'cmhoriondpv002.od.local')
GO

IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SOLARWINDS_ORION_HOST') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'CMH'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SOLARWINDS_ORION_HOST'),(select id from datacenter where code = 'CMH'),'cmhoriondpv002.od.local')
GO



IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SOLARWINDS_ORION_DB_NAME') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'AMS'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SOLARWINDS_ORION_DB_NAME'),(select id from datacenter where code = 'AMS'),'NetPerfMon')
GO

IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SOLARWINDS_ORION_DB_NAME') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'DSM'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SOLARWINDS_ORION_DB_NAME'),(select id from datacenter where code = 'DSM'),'NetPerfMon')
GO


IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SOLARWINDS_ORION_DB_NAME') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'PCM'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SOLARWINDS_ORION_DB_NAME'),(select id from datacenter where code = 'PCM'),'NetPerfMon')
GO

IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SOLARWINDS_ORION_DB_NAME') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'CMH'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SOLARWINDS_ORION_DB_NAME'),(select id from datacenter where code = 'CMH'),'NetPerfMon')
GO



IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SOLARWINDS_ORION_INSTANCE_NAME') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'AMS'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SOLARWINDS_ORION_INSTANCE_NAME'),(select id from datacenter where code = 'AMS'),'LOCAL')
GO

IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SOLARWINDS_ORION_INSTANCE_NAME') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'DSM'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SOLARWINDS_ORION_INSTANCE_NAME'),(select id from datacenter where code = 'DSM'),'LOCAL')
GO


IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SOLARWINDS_ORION_INSTANCE_NAME') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'PCM'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SOLARWINDS_ORION_INSTANCE_NAME'),(select id from datacenter where code = 'PCM'),'LOCAL')
GO

IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SOLARWINDS_ORION_INSTANCE_NAME') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'CMH'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SOLARWINDS_ORION_INSTANCE_NAME'),(select id from datacenter where code = 'CMH'),'LOCAL')
GO




IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SOLARWINDS_ORION_PORT') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'AMS'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SOLARWINDS_ORION_PORT'),(select id from datacenter where code = 'AMS'),'1433')
GO

IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SOLARWINDS_ORION_PORT') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'DSM'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SOLARWINDS_ORION_PORT'),(select id from datacenter where code = 'DSM'),'1433')
GO


IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SOLARWINDS_ORION_PORT') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'PCM'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SOLARWINDS_ORION_PORT'),(select id from datacenter where code = 'PCM'),'1433')
GO

IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SOLARWINDS_ORION_PORT') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'CMH'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SOLARWINDS_ORION_PORT'),(select id from datacenter where code = 'CMH'),'1433')
GO





IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SOLARWINDS_ORION_USERNAME') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'AMS'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SOLARWINDS_ORION_USERNAME'),(select id from datacenter where code = 'AMS'),'SolarWindsDatabaseUser')
GO

IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SOLARWINDS_ORION_USERNAME') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'DSM'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SOLARWINDS_ORION_USERNAME'),(select id from datacenter where code = 'DSM'),'SolarWindsDatabaseUser')
GO


IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SOLARWINDS_ORION_USERNAME') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'PCM'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SOLARWINDS_ORION_USERNAME'),(select id from datacenter where code = 'PCM'),'SolarWindsDatabaseUser')
GO

IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SOLARWINDS_ORION_USERNAME') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'CMH'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SOLARWINDS_ORION_USERNAME'),(select id from datacenter where code = 'CMH'),'SolarWindsDatabaseUser')
GO

