{% import "../../Common/redis/vars.sls" as base %}

#-------------------------------
{% set suite_version= salt['pillar.get']('VERSION', '') %}
{% set workflow = salt['pillar.get']('WORKFLOW', 'provision') %}
{% set cluster = salt['pillar.get']('CLUSTER', '') %}
{% set server = salt['pillar.get']('SERVER', '') %}
{% set parentfolder = suite_version.split('-')[0]| regex_replace('\\.|\\-', '') %}
{% set version = parentfolder %}
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
{% set role= "SCC" %}

{% set parentfolder = suite_version.split('-')[0]| regex_replace('\\.|\\-', '') %}
{% set workflow_folder= parentfolder +"/"+ role +"/Workflow" %}
{% set clusterservers = salt['pillar.get']('CLUSTERSERVERS','') %}
{% set dict = salt['pillar.get']('DICT') %}

{% if cluster!= '' %}
{% set redis_dir= base.redis_dir%}
{% set dict = salt['pillar.get']('DICT') %}
{% set sccservernodes = dict['SCC_REDIS_NODES']  %}
{% set sccredispwd = dict['SCC_REDIS_PWD']  %}
{% set sccport = dict['SCC_REDIS_PORT'] %}
{% set scc_master = sccservernodes.split(',')[0] %}
{% endif %}


#Default Params
#-------------------------------
{% set redis_version = base.redis_version %}
{% set redis_full_version = base.redis_full_versio %}
{% set redis_download = base.redis_download %}
{% set redis_user = base.redis_user %}
{% set redis_group = base.redis_group %}
{% set redis_path = base.redis_path %}
{% set redis_dir  = base.redis_dir %}
{% set redis_download_file = base.redis_download_file %}
{% set redis_download_url = base.redis_download_url %}

{% set redis_install_as_service = base.redis_install_as_service %}
{% set redis_config_path = base.redis_config_path %}
{% set redis_install_path = base.redis_install_path %}

{% set redis_data_dir = base.redis_data_dir  %}
{% set redis_config_dir = base.redis_config_dir %}
{% set redis_scripts_dir = base.redis_scripts_dir %}
{% set redis_log_dir = base.redis_log_dir %}
{% set redis_service_file  = base.redis_service_file %}

{% set unixODBC= dict['unixODBC'] %}
{% set unixODBC_devel= dict['unixODBC_devel'] %}
{% set pymysql_url= dict['pymysql_url'] %}
{% set pymysql= "PyMySQL-1.0.2" %}
{% set pymysql_file= pymysql + ".tar.gz" %}
