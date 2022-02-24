#Workflow Params
#-------------------------------
{% set suite_version= salt['pillar.get']('VERSION', '') %}
{% set workflow = salt['pillar.get']('WORKFLOW', 'provision') %}
{% set cluster = salt['pillar.get']('CLUSTER', '') %}
{% set server = salt['pillar.get']('SERVER', '') %}
{% set parentfolder = suite_version.split('-')[0]| regex_replace('\\.|\\-', '') %}
{% set version = parentfolder %}
{% set clusterservers = salt['pillar.get']('CLUSTERSERVERS','') %}
{% set dict = salt['pillar.get'] ('DICT','') %}
{% set ms_baseurl= "https://packages.microsoft.com/rhel/7/prod/" %}
{% set ms_gpgkey= "https://packages.microsoft.com/keys/microsoft.asc" %}
{% set unixODBC= dict['unixODBC'] %}
{% set unixODBC_devel= dict['unixODBC_devel'] %}
{% set pymongo_url= dict['pymongo_url'] %}
{% set pymysql_url= dict['pymysql_url'] %}
{% set pymysql= "PyMySQL-1.0.2" %}
{% set pymysql_file= pymysql + ".tar.gz" %}
{% set tmp_path = '/tmp' %}
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

#Default Params
#-------------------------------

{% set role= "UMD" %}
{% set percona_server_version= "4.4" %}

{% set parentfolder = suite_version.split('-')[0]| regex_replace('\\.|\\-', '') %}
{#% set parentfolder = salt['common.getshortversion'](suite_version) %#}
{% set workflow_folder= parentfolder +"/"+ role +"/Workflow" %}

{% if cluster!= '' %}
{% set dict = salt['pillar.get'] ('DICT','') %}
{% set umd_user = dict['UMD_ADMIN_USER']  %}
{% set umd_password = dict['UMD_ADMIN_PASSWORD']  %}
{% set umd_port = dict['UMD_DB_PORT'] %}

{% endif %}

#DataCenter/Tier params
#--------------------------------



#Cluster Params
#--------------------------------



#Tenant Params
#---------------------------------



#Other/Internal Params
#---------------------------------
{% set percona_config_path=  '/etc/mongod.conf' %}
{% set percona_rpm_version = '4.4.10-11.el7.x86_64.rpm' %}
{% set percona_archive_url = dict['percona-server-mongodb-4.4.10-11'] %}
{% set percona_tmp_path = '/tmp/Percona-Server-MongoDB' %}


#Prerequsite Packages
#----------------------
{% set byobu_rpm = dict['byobu-5.73-4'] %}
{% set tmux_rpm =  dict['tmux-1.8-4'] %}
{% set screen_rpm = dict['screen-4.1.0-0.26'] %}
