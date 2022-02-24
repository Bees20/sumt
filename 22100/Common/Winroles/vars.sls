{% set role = salt['pillar.get']('ROLE', '') %}
{% set workflow = salt['pillar.get']('WORKFLOW', 'provision') %}
{% set cluster = salt['pillar.get']('CLUSTER', '') %}
{% set tenant = salt['pillar.get']('TENANT', '') %}
{% set patch = salt['pillar.get']('PATCH_VERSION', '') %}
{% set associated_cluster = salt['pillar.get']('ASSOCIATED_CLUSTER', '') %}
{% set server = salt['pillar.get']('SERVER', '') %}
{% set suite_version= salt['pillar.get']('VERSION', '') %}
{% set dict = salt['pillar.get'] ('DICT','') %}
{% set clusterservers = salt['pillar.get']('CLUSTERSERVERS','') %}

{% set parentfolder = suite_version.split('-')[0]| regex_replace('\\.|\\-', '') %}
{% set workflow_folder = parentfolder +"/"+ role +"/Workflow" %}
{% set template_folder = parentfolder +"/"+ role +"/Templates" %}
{% set scripts_folder =  parentfolder +"/"+ role +"/Scripts" %}

{% set temp_folder = "c:\Temp" %}
{% set log_folder = "c:\saltlogs" %}
{% set sqldirectories= 'D:\Program Files\Microsoft SQL Server','D:\Program Files (x86)\Microsoft SQL Server','D:\mssql\data','D:\mssql\logs','D:\mssql\logs\Carousel','D:\mssql\data\Carousel' %}
{% set pm2= "c:\\pm2" %}
{% set pm2_dir= "c:\\\\pm2" %}

{% set custom_package_folder = "/srv/salt/win/repo-ng/Custom_Packages" %}
{% set install_package_folder= "/srv/salt/"+ parentfolder +"/Common/Winrepo/Packages" %}
{% set common_template_folder = "/srv/salt/"+ parentfolder +"/Common/Templates" %}

{% set EnableCiphersHashesKeyExchangeAlgorithms= 'Ciphers\\AES 128/128','Ciphers\\AES 256/256','Hashes\\SHA256','Hashes\\SHA384','Hashes\\SHA512','KeyExchangeAlgorithms\\ECDH','KeyExchangeAlgorithms\\PKCS' %}
{% set DisableCiphersHashesKeyExchangeAlgorithms= 'Ciphers\\DES 56/56','Ciphers\\NULL','Ciphers\\RC2 128/128','Ciphers\\RC2 40/128','Ciphers\\RC2 56/128','Ciphers\\RC4 128/128','Ciphers\\RC4 40/128','Ciphers\\RC4 56/128','Ciphers\\RC4 64/128','Ciphers\\Triple DES 168','Hashes\\MD5','Hashes\\SHA','KeyExchangeAlgorithms\\Diffie-Hellman'%}
{% set Enabled_protocols= 'TLS 1.2' %}
{% set Disabled_protocols= 'Multi-Protocol Unified Hello','PCT 1.0','SSL 2.0','SSL 3.0','TLS 1.0','TLS 1.1' %}




