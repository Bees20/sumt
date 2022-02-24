/* Creating SVC_ACCOUNTS_OU configuration key */

IF NOT EXISTS(SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] ='SVC_ACCOUNTS_OU')
Insert into CONFIGURATION_KEY ([KEY],DESCRIPTION,KEY_TYPE)
VALUES('SVC_ACCOUNTS_OU','SVC account OU','String')
GO

/*
IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SVC_ACCOUNTS_OU') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'LDC'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SVC_ACCOUNTS_OU'),(select id from datacenter where code = 'LDC'),'OU=UDA,OU=service_accounts,OU=groups_users,DC=COTESTDEV,DC=LOCAL;CN=svc_accounts_uda,OU=groups,OU=groups_users,DC=COTESTDEV,DC=LOCAL')
GO
IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SVC_ACCOUNTS_OU') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'GSL'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SVC_ACCOUNTS_OU'),(select id from datacenter where code = 'GSL'),'OU=UDA,OU=service_accounts,OU=groups_users,DC=COTESTDEV,DC=LOCAL;CN=svc_accounts_uda,OU=groups,OU=groups_users,DC=COTESTDEV,DC=LOCAL')
GO
*/
IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SVC_ACCOUNTS_OU') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'CMH'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SVC_ACCOUNTS_OU'),(select id from datacenter where code = 'CMH'),'OU=UDA,OU=service_accounts,OU=groups_users,DC=OD,DC=LOCAL;CN=svc_accounts_uda,OU=groups,OU=groups_users,DC=OD,DC=LOCAL')
GO
IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SVC_ACCOUNTS_OU') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'DSM'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SVC_ACCOUNTS_OU'),(select id from datacenter where code = 'DSM'),'OU=UDA,OU=service_accounts,OU=groups_users,DC=OD,DC=LOCAL;CN=svc_accounts_uda,OU=groups,OU=groups_users,DC=OD,DC=LOCAL')
GO
IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SVC_ACCOUNTS_OU') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'AMS'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SVC_ACCOUNTS_OU'),(select id from datacenter where code = 'AMS'),'OU=UDA,OU=service_accounts,OU=groups_users,DC=OD,DC=LOCAL;CN=svc_accounts_uda,OU=groups,OU=groups_users,DC=OD,DC=LOCAL')
GO
IF NOT EXISTS (SELECT ID FROM CONFIGURATION_KEY_TO_DATACENTER WHERE CONFIGURATION_KEY_ID = (SELECT ID FROM CONFIGURATION_KEY WHERE [KEY] = 'SVC_ACCOUNTS_OU') AND DATACENTER_ID = (SELECT ID FROM DATACENTER WHERE CODE = 'PCM'))
INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES
((select ID from CONFIGURATION_KEY where [KEY] = 'SVC_ACCOUNTS_OU'),(select id from datacenter where code = 'PCM'),'OU=UDA,OU=service_accounts,OU=groups_users,DC=COPCI,DC=LOCAL;CN=svc_accounts_uda_pci,OU=groups,OU=groups_users,DC=COPCI,DC=LOCAL')
GO


/*
Insert into CONFIGURATION_KEY ([KEY],DESCRIPTION,KEY_TYPE)
VALUES('SVC_ACCOUNTS_OU','SVC account OU','String')


INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES ((select ID from CONFIGURATION_KEY where [KEY] = 'SVC_ACCOUNTS_OU'),(select id from datacenter where code = 'LDC'),'OU=UDA,OU=service_accounts,OU=groups_users,DC=COTESTDEV,DC=LOCAL;CN=svc_accounts_uda,OU=groups,OU=groups_users,DC=COTESTDEV,DC=LOCAL'),
((select ID from CONFIGURATION_KEY where [KEY] = 'SVC_ACCOUNTS_OU'),(select id from datacenter where code = 'GSL'),'OU=UDA,OU=service_accounts,OU=groups_users,DC=COTESTDEV,DC=LOCAL;CN=svc_accounts_uda,OU=groups,OU=groups_users,DC=COTESTDEV,DC=LOCAL'),
((select ID from CONFIGURATION_KEY where [KEY] = 'SVC_ACCOUNTS_OU'),(select id from datacenter where code = 'CMH'),'OU=UDA,OU=service_accounts,OU=groups_users,DC=OD,DC=LOCAL;CN=svc_accounts_uda,OU=groups,OU=groups_users,DC=OD,DC=LOCAL'),
((select ID from CONFIGURATION_KEY where [KEY] = 'SVC_ACCOUNTS_OU'),(select id from datacenter where code = 'DSM'),'OU=UDA,OU=service_accounts,OU=groups_users,DC=OD,DC=LOCAL;CN=svc_accounts_uda,OU=groups,OU=groups_users,DC=OD,DC=LOCAL'),
((select ID from CONFIGURATION_KEY where [KEY] = 'SVC_ACCOUNTS_OU'),(select id from datacenter where code = 'AMS'),'OU=UDA,OU=service_accounts,OU=groups_users,DC=OD,DC=LOCAL;CN=svc_accounts_uda,OU=groups,OU=groups_users,DC=OD,DC=LOCAL'),
((select ID from CONFIGURATION_KEY where [KEY] = 'SVC_ACCOUNTS_OU'),(select id from datacenter where code = 'PCM'),'OU=UDA,OU=service_accounts,OU=groups_users,DC=COPCI,DC=LOCAL;CN=svc_accounts_uda_pci,OU=groups,OU=groups_users,DC=COPCI,DC=LOCAL')
*/