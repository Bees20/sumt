/* Creating CO_UDA_WIN_DB_SYSADMINS configuration key */

IF NOT EXISTS(SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] ='CO_UDA_WIN_DB_SYSADMINS')
Insert into CONFIGURATION_KEY ([KEY],DESCRIPTION,KEY_TYPE)
VALUES('CO_UDA_WIN_DB_SYSADMINS','UDA SQL logins for Windows','String')
GO

/*
IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'CO_UDA_WIN_DB_SYSADMINS') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'LDC'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_UDA_WIN_DB_SYSADMINS'),(select id from datacenter where code = 'LDC'),'cotestdev\\svc_automate,cotestdev\\svc_opssql,cotestdev\\svc_sqladmin-dev,cotestdev\\application-admins,cotestdev\\dev_dba')
GO
IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'CO_UDA_WIN_DB_SYSADMINS') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'GSL'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_UDA_WIN_DB_SYSADMINS'),(select id from datacenter where code = 'GSL'),'cotestdev\\svc_automate,cotestdev\\svc_opssql,cotestdev\\svc_sqladmin-gsl,cotestdev\\application-admins,cotestdev\\dev_dba')
GO
*/
IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'CO_UDA_WIN_DB_SYSADMINS') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'CMH'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_UDA_WIN_DB_SYSADMINS'),(select id from datacenter where code = 'CMH'),'od\\svc_automate,OD\\svc_opssql,OD\\svc_Rubrik,OD\\svc_sqladmin,OD\\svc_sentyOne,OD\\od_application_admins,od\\od_dba')
GO
IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'CO_UDA_WIN_DB_SYSADMINS') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'DSM'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_UDA_WIN_DB_SYSADMINS'),(select id from datacenter where code = 'DSM'),'od\\svc_automate,OD\\svc_opssql,OD\\svc_Rubrik,OD\\svc_sqladmin,OD\\svc_sentyOne,OD\\od_application_admins,od\\od_dba')
GO
IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'CO_UDA_WIN_DB_SYSADMINS') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'AMS'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_UDA_WIN_DB_SYSADMINS'),(select id from datacenter where code = 'AMS'),'od\\svc_automate,OD\\svc_opssql,OD\\svc_Rubrik,OD\\svc_sqladmin,OD\\svc_sentyOne,OD\\od_application_admins,od\\od_dba')
GO
IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'CO_UDA_WIN_DB_SYSADMINS') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'PCM'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_UDA_WIN_DB_SYSADMINS'),(select id from datacenter where code = 'PCM'),'COPCI\\od_application_admins_PCI,COPCI\\od_dba_PCI,COPCI\\svc_accounts_uda_pci,copci\\svc_automate_pci,COPCI\\svc_opsSQL_pci,COPCI\\svc_sqladmin_pci,COPCI\\svc_sqladmin_pci2')
GO


/*

Insert into CONFIGURATION_KEY ([KEY],DESCRIPTION,KEY_TYPE)
VALUES('CO_UDA_WIN_DB_SYSADMINS','UDA SQL logins for Windows','String')


INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES ((select ID from CONFIGURATION_KEY where [KEY] = 'CO_UDA_WIN_DB_SYSADMINS'),(select id from datacenter where code = 'LDC'),'cotestdev\\svc_automate,cotestdev\\svc_opssql,cotestdev\\svc_sqladmin-dev,cotestdev\\application-admins,cotestdev\\dev_dba'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_UDA_WIN_DB_SYSADMINS'),(select id from datacenter where code = 'GSL'),'cotestdev\\svc_automate,cotestdev\\svc_opssql,cotestdev\\svc_sqladmin-gsl,cotestdev\\application-admins,cotestdev\\dev_dba'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_UDA_WIN_DB_SYSADMINS'),(select id from datacenter where code = 'CMH'),'od\\svc_automate,OD\\svc_opssql,OD\\svc_Rubrik,OD\\svc_sqladmin,OD\\svc_sentyOne,OD\\od_application_admins,od\\od_dba'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_UDA_WIN_DB_SYSADMINS'),(select id from datacenter where code = 'DSM'),'od\\svc_automate,OD\\svc_opssql,OD\\svc_Rubrik,OD\\svc_sqladmin,OD\\svc_sentyOne,OD\\od_application_admins,od\\od_dba'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_UDA_WIN_DB_SYSADMINS'),(select id from datacenter where code = 'AMS'),'od\\svc_automate,OD\\svc_opssql,OD\\svc_Rubrik,OD\\svc_sqladmin,OD\\svc_sentyOne,OD\\od_application_admins,od\\od_dba'),
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_UDA_WIN_DB_SYSADMINS'),(select id from datacenter where code = 'PCM'),'COPCI\\od_application_admins_PCI,COPCI\\od_dba_PCI,COPCI\\svc_accounts_uda_pci,copci\\svc_automate_pci,COPCI\\svc_opsSQL_pci,COPCI\\svc_sqladmin_pci,COPCI\\svc_sqladmin_pci2')
*/