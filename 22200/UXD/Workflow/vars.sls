#-------------------------------
{% set suite_version= salt['pillar.get']('VERSION', '') %}
{% set workflow = salt['pillar.get']('WORKFLOW', 'provision') %}
{% set cluster = salt['pillar.get']('CLUSTER', '') %}
{% set server = salt['pillar.get']('SERVER', '') %}
{% set tenant = salt['pillar.get']('TENANT', '') %}
{% set parentfolder = suite_version.split('-')[0]| regex_replace('\\.|\\-', '') %}
{% set version = parentfolder %}
{% set role= "UXD" %}
{% set percona_version= "57" %}
{% set sourcetenantkey = salt['pillar.get']('SOURCE_TENANT_KEY', '') %}
{% set sourcetenantfqdn = salt['pillar.get']('SOURCE_TENANT_FQDN', '') %}
{% set tmp_path= "/tmp" %}

{% set dict = salt['pillar.get'] ('DICT','') %}
{% set libaio_rpm_url= dict['libaio-devel-0.3.109-13'] %}
{% set nettools_rpm_url= dict['net-tools-2.0-0.25'] %}
{% set percona_downloadurl= dict['Percona-Server-5.7.23-25'] %}
{% set ms_baseurl= "https://packages.microsoft.com/rhel/7/prod/" %}
{% set ms_gpgkey= "https://packages.microsoft.com/keys/microsoft.asc" %}
{% set parentfolder = suite_version.split('-')[0]| regex_replace('\\.|\\-', '') %}
{% set unixODBC= dict['unixODBC'] %}
{% set unixODBC_devel= dict['unixODBC_devel'] %}
{% set pymysql_url= dict['pymysql_url'] %}
{% set pymysql= "PyMySQL-1.0.2" %}
{% set pymysql_file= pymysql + ".tar.gz" %}
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

{% set defaultuser = dict['defaultuser']%}
{% set defaultuserpwd = dict['defaultuserpwd'] %}
{% set exporterpwd = "Bunny1024!" %}
{% set exporteruser = "exporter" %}

{% set workflow_folder= parentfolder +"/"+ role +"/Workflow" %}
{% set clusterservers = salt['pillar.get']('CLUSTERSERVERS','') %}

{% if cluster!= '' %}

{% set dict = salt['pillar.get'] ('DICT','') %}
{% set uxdadminuser = dict['UXD_ADMIN_USER']  %}
{% set uxdadminpwd = dict['UXD_ADMIN_PASSWORD']  %}
{% set uxdport = dict['UXD_DB_PORT'] %}

{% endif %}



#Default Params
#-------------------------------




{% set percona_user = "mysql" %}
{% set percona_group = "mysql" %}

#DataCenter/Tier params
#--------------------------------



#Cluster Params
#--------------------------------



#Tenant Params
#---------------------------------



#Other/Internal Params
#---------------------------------

