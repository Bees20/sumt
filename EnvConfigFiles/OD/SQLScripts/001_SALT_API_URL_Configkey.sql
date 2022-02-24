

IF NOT EXISTS(SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] ='SALT_API_URL')
insert into CONFIGURATION_KEY ([key],DESCRIPTION,DEFAULT_VALUE,KEY_TYPE,IS_SECURE,SHOW_ON_UI) values
('SALT_API_URL', 'Saltstack API URL', '', 'String', 0, 1)
GO


IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SALT_API_URL') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'AMS'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SALT_API_URL'),(select id from datacenter where code = 'AMS'),'https://saltstack.sumtotal.host')
GO

IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SALT_API_URL') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'DSM'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SALT_API_URL'),(select id from datacenter where code = 'DSM'),'https://saltstack.sumtotal.host')
GO


IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SALT_API_URL') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'PCM'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SALT_API_URL'),(select id from datacenter where code = 'PCM'),'https://saltstack.sumtotal.host')
GO

IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SALT_API_URL') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'CMH'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SALT_API_URL'),(select id from datacenter where code = 'CMH'),'https://saltstack.sumtotal.host')
GO


