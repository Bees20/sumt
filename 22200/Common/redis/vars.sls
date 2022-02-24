{% set redis_version= "6.2.6" %}
{% set redis_full_version= "2.12-2.2.2" %}
{% set redis_download= '' %}
{% set redis_user= "redis" %}
{% set redis_group= "redis" %}
{% set redis_path= "/opt/" %}
{% set redis_dir = redis_path ~ "redis-" ~ redis_version %}
{% set redis_download_file= 'redis-' + redis_version + '.tgz' %}
{% set dict = salt['pillar.get']('DICT') %}
{% set redis_download_url= dict['redis-6.2.6'] %}
{% set unixODBC= dict['unixODBC'] %}
{% set unixODBC_devel= dict['unixODBC_devel'] %}
{% set pymysql_url= dict['pymysql_url'] %}
{% set pymysql= "PyMySQL-1.0.2" %}
{% set pymysql_file= pymysql + ".tar.gz" %}
{% set tmp_path= "/tmp" %}
{% set mssql_tools_url= dict['mssql-tools'] %}
{% set mssql_tools_rpm= "mssql-tools-17.8.1.1-1.x86_64.rpm" %}
{% set msodbcsql_url= dict['msodbcsql-linux'] %}
{% set msodbcsql_rpm= "msodbcsql17-17.8.1.2-1.x86_64.rpm" %}
{% set python2_pip_url= dict['python2-pip'] %}
{% set python2_pip_rpm= "python2-pip-8.1.2-14.el7.noarch.rpm" %}
{% set python_setuptools_url= dict['python-setuptools'] %}
{% set python_setuptools_rpm= "python-setuptools-0.9.8-7.el7.noarch.rpm" %}
{% set python3_pip_url= dict['python3-pip'] %}
{% set python3_pip_rpm= "python3-pip-9.0.3-8.el7.noarch.rpm" %}

{% set redis_install_as_service= 1 %}
{% set redis_config_path= redis_path + 'redis_' + redis_full_version + '/config/server.properties' %}
{% set redis_install_path= redis_path + 'redis_' + redis_full_version  %}

{% set redis_data_dir= "/data/redis/" %}
{% set redis_config_dir= redis_path + 'redis_' + redis_version + '/config/' %}
{% set redis_scripts_dir=  redis_path + '/redis_' + redis_full_version + '/bin/' %}
{% set redis_log_dir= "/var/log/redis/" %}
{% set redis_service_file = 'redis.template' %}
{% set redis_conf_dir = '/etc/redis' %}
{% set ms_baseurl= "https://packages.microsoft.com/rhel/7/prod/" %}
{% set ms_gpgkey= "https://packages.microsoft.com/keys/microsoft.asc" %}


{% set directories = redis_log_dir,redis_config_dir,redis_conf_dir,tmp_path %}

{% set suite_version= salt['pillar.get']('VERSION', '') %}
{% set parentfolder = suite_version.split('-')[0]| regex_replace('\\.|\\-', '') %}