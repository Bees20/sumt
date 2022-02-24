Insert into CONFIGURATION_KEY ([KEY],DESCRIPTION,KEY_TYPE)
VALUES('SALTREPO_BASEURL','Base URL for salt','String')

Insert into CONFIGURATION_KEY ([KEY],DESCRIPTION,KEY_TYPE)
VALUES('SALTREPO_GPGKEY','Gpg key for salt','String')

INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES ((select ID from CONFIGURATION_KEY where [KEY] = 'SALTREPO_BASEURL'),(select id from datacenter where code = 'LDC'),'http://ldcsaltrep001/py3/redhat/7/x86_64/latest'),
((select ID from CONFIGURATION_KEY where [KEY] = 'SALTREPO_BASEURL'),(select id from datacenter where code = 'GSL'),'http://ldcsaltrep001/py3/redhat/7/x86_64/latest'),
        ((select ID from CONFIGURATION_KEY where [KEY] = 'SALTREPO_BASEURL'),(select id from datacenter where code = 'CMH'),'http://cmhsalgpv001/py3/redhat/7/x86_64/latest/'),
		((select ID from CONFIGURATION_KEY where [KEY] = 'SALTREPO_BASEURL'),(select id from datacenter where code = 'DSM'),'http://dsmsalgpv001/py3/redhat/7/x86_64/latest/'),
		((select ID from CONFIGURATION_KEY where [KEY] = 'SALTREPO_BASEURL'),(select id from datacenter where code = 'AMS'),'http://amssalgpv001/py3/redhat/7/x86_64/latest/'),
		((select ID from CONFIGURATION_KEY where [KEY] = 'SALTREPO_BASEURL'),(select id from datacenter where code = 'PCM'),'http://pcmsalgpv001/py3/redhat/7/x86_64/latest/')
		
		
	INSERT INTO CONFIGURATION_KEY_TO_DATACENTER (CONFIGURATION_KEY_ID,DATACENTER_ID,VALUE)
VALUES ((select ID from CONFIGURATION_KEY where [KEY] = 'SALTREPO_GPGKEY'),(select id from datacenter where code = 'LDC'),'http://ldcsaltrep001/yum/redhat/7/x86_64/latest/SALTSTACK-GPG-KEY.pub'),
((select ID from CONFIGURATION_KEY where [KEY] = 'SALTREPO_GPGKEY'),(select id from datacenter where code = 'GSL'),'http://ldcsaltrep001/yum/redhat/7/x86_64/latest/SALTSTACK-GPG-KEY.pub'),
        ((select ID from CONFIGURATION_KEY where [KEY] = 'SALTREPO_GPGKEY'),(select id from datacenter where code = 'CMH'),'http://cmhsalgpv001/py3/redhat/7/x86_64/latest/SALTSTACK-GPG-KEY.pub'),
		((select ID from CONFIGURATION_KEY where [KEY] = 'SALTREPO_GPGKEY'),(select id from datacenter where code = 'DSM'),'http://dsmsalgpv001/py3/redhat/7/x86_64/latest/SALTSTACK-GPG-KEY.pub'),
		((select ID from CONFIGURATION_KEY where [KEY] = 'SALTREPO_GPGKEY'),(select id from datacenter where code = 'AMS'),'http://amssalgpv001/py3/redhat/7/x86_64/latest/SALTSTACK-GPG-KEY.pub'),
		((select ID from CONFIGURATION_KEY where [KEY] = 'SALTREPO_GPGKEY'),(select id from datacenter where code = 'PCM'),'http://pcmsalgpv001/py3/redhat/7/x86_64/latest/SALTSTACK-GPG-KEY.pub')