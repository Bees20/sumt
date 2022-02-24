#template-required variables
{% set user = "uecAdminUser" %}
{% set group = "uecAdminUser" %}
{% set suite_version= salt['pillar.get']('VERSION', '') %}
{% set role = 'UEC' %}
{% set workflow = salt['pillar.get']('WORKFLOW', 'provision') %}
{% set cluster = salt['pillar.get']('CLUSTER', '') %}
{% set server = salt['pillar.get']('SERVER', '') %}
{% set parentfolder = suite_version.split('-')[0]| regex_replace('\\.|\\-', '') %}
{% set dict = salt['pillar.get']('DICT') %}
{% set workflow_folder= parentfolder +"/"+ role +"/Workflow" %}
{% set templates_folder= parentfolder +"/"+ role +"/Templates" %}
{% set versionfile = 'versionfile.template' %}
{% set ms_baseurl= "https://packages.microsoft.com/rhel/7/prod/" %}
{% set ms_gpgkey= "https://packages.microsoft.com/keys/microsoft.asc" %}
{% set repoServer = salt['pillar.get']('repoServer', '') %}
{% set release_version = salt['pillar.get']('VERSION','') %}
{% set dsbulk_location = "/opt/" %}
{% set dsbulk_dir = "dsbulk-1.8.0" %}
{% set unixODBC= dict['unixODBC'] %}
{% set unixODBC_devel= dict['unixODBC_devel'] %}
{% set tmp_path= "/tmp" %}
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


# trailing slash should be handeled appropriatly - This is to be done
{% set package_root = "/opt/install" +"/"+ suite_version +"/"+ role %}

# trailing slash should be handeled appropriatly - This is to be done
{% set install_root = "/opt/suite" %}

{% set templates_folder= parentfolder +"/"+ role +"/Templates" %}

{% set clusterservers = salt['pillar.get']('CLUSTERSERVERS','') %}

{% set share = dict["package_share_location"]|string %}
{% set duser = dict["user"] %}
{% set domain = dict["domain"] %}
{% set passwd= dict["password"] %}






