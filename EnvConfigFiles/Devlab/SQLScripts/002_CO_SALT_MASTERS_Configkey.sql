insert into CONFIGURATION_KEY ([key],DESCRIPTION,DEFAULT_VALUE,KEY_TYPE,IS_SECURE,SHOW_ON_UI) values
('CO_SALT_MASTERS', 'salt masters', '', 'String', 0, 1)


INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES 
((select ID from CONFIGURATION_KEY where [KEY] = 'CO_SALT_MASTERS'),(select id from datacenter where code = 'LDC'),'ldcsaltmas003,ldcsaltmas004')
