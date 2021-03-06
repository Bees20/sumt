/* Creating CO_UDA_WIN_DB_BACKUPLOCATION configuration key */

IF NOT EXISTS(SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] ='CO_UDA_WIN_DB_BACKUPLOCATION')
Insert into CONFIGURATION_KEY ([KEY],DESCRIPTION,KEY_TYPE)
VALUES('CO_UDA_WIN_DB_BACKUPLOCATION','UDA SQL Backup Location for Windows','String')
GO

/*
IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'CO_UDA_WIN_DB_BACKUPLOCATION') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'LDC'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_UDA_WIN_DB_BACKUPLOCATION'),(select id from datacenter where code = 'LDC'),'\\\\ldcufsp001n001\\UDASHARE\\backups')
GO
IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'CO_UDA_WIN_DB_BACKUPLOCATION') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'GSL'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_UDA_WIN_DB_BACKUPLOCATION'),(select id from datacenter where code = 'GSL'),'\\\\ldcufsp001n001\\UDASHARE\\backups')
GO
*/
IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'CO_UDA_WIN_DB_BACKUPLOCATION') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'CMH'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_UDA_WIN_DB_BACKUPLOCATION'),(select id from datacenter where code = 'CMH'),'\\\\cmhstagenas01\\backups\\dbbackups')
GO
IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'CO_UDA_WIN_DB_BACKUPLOCATION') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'DSM'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_UDA_WIN_DB_BACKUPLOCATION'),(select id from datacenter where code = 'DSM'),'\\\\dsmstagenas01\\backups\\dbbackups')
GO
IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'CO_UDA_WIN_DB_BACKUPLOCATION') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'AMS'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_UDA_WIN_DB_BACKUPLOCATION'),(select id from datacenter where code = 'AMS'),'\\\\amsprodnas01\\backups\\dbbackups')
GO
IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'CO_UDA_WIN_DB_BACKUPLOCATION') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'PCM'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_UDA_WIN_DB_BACKUPLOCATION'),(select id from datacenter where code = 'PCM'),'\\\\pcistagenas01\\backups\\dbbackups')
GO


/*
Insert into CONFIGURATION_KEY ([KEY],DESCRIPTION,KEY_TYPE)
VALUES('CO_UDA_WIN_DB_BACKUPLOCATION','UDA SQL Backup Location for Windows','String')


INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES ((select ID from CONFIGURATION_KEY where [KEY] = 'CO_UDA_WIN_DB_BACKUPLOCATION'),(select id from datacenter where code = 'LDC'),'\\\\ldcufsp001n001\\UDASHARE\\backups'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_UDA_WIN_DB_BACKUPLOCATION'),(select id from datacenter where code = 'GSL'),'\\\\ldcufsp001n001\\UDASHARE\\backups'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_UDA_WIN_DB_BACKUPLOCATION'),(select id from datacenter where code = 'CMH'),'\\\\cmhstagenas01\\backups\\dbbackups'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_UDA_WIN_DB_BACKUPLOCATION'),(select id from datacenter where code = 'DSM'),'\\\\dsmstagenas01\\backups\\dbbackups'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_UDA_WIN_DB_BACKUPLOCATION'),(select id from datacenter where code = 'AMS'),'\\\\amsprodnas01\\backups\\dbbackups'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_UDA_WIN_DB_BACKUPLOCATION'),(select id from datacenter where code = 'PCM'),'\\\\copci.local\\UDASHARE\\PCM-Backups\\dbbackups')
*/