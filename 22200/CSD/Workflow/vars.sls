#-------------------------------
{% set suite_version= salt['pillar.get']('VERSION', '') %}
{% set workflow = salt['pillar.get']('WORKFLOW', 'provision') %}
{% set cluster = salt['pillar.get']('CLUSTER', '') %}
{% set server = salt['pillar.get']('SERVER', '') %}
{% set parentfolder = suite_version.split('-')[0]| regex_replace('\\.|\\-', '') %}
{% set version = parentfolder %}

#Default Params
#-------------------------------
{% set role= "CSD" %}
{% set parentfolder = suite_version.split('-')[0]| regex_replace('\\.|\\-', '') %}
{% set workflow_folder= parentfolder +"/"+ role +"/Workflow" %}
{% set dict = salt['pillar.get'] ('DICT','') %}
{% set clusterservers = salt['pillar.get']('CLUSTERSERVERS','') %}

{% set workflow_folder= version +"/"+ role +"/Workflow" %}
{% set templates_folder= version +"/"+ role +"/Templates" %}
{% set cassandra_download_path= "/tmp" %}
{% set cassandra_version= "3.11.5" %}
{% set cassandra_download_file= 'apache-cassandra-' ~ cassandra_version ~ '-bin.tar.gz' %}
{% set cassandra_archive_path= cassandra_download_path ~ '/' ~ cassandra_download_file %}
{% set cassandra_path= '/opt/cassandra' %}
{% set cassandra_dir= cassandra_path ~ '/apache-cassandra-' ~ cassandra_version %}
{% set cassandra_tmp_dir= cassandra_dir ~ '/tmp' %}
{% set cassandra_group= 'cassandra' %}
{% set cassandra_user= 'cassandra' %}
{% set cassandra_cluster_name= "Test Cluster" %}
{% set cassandra_config_dir= "/etc/cassandra" %}
{% set cassandra_config_file = templates_folder ~ "cassandra.yaml" %}
{% set cassandra_log_dir= "/var/log/cassandra" %}
{% set commitlog_directory= "/var/lib/cassandra/commitlog" %}
{% set cassandra_data_dir= "/var/lib/cassandra/data" %}
{% set saved_caches_directory= "/var/lib/cassandra/saved_caches" %}
{% set directories = cassandra_path, cassandra_log_dir, cassandra_data_dir , cassandra_config_dir , cassandra_tmp_dir, cassandra_download_path %}
{% set ms_baseurl= "https://packages.microsoft.com/rhel/7/prod/" %}
{% set ms_gpgkey= "https://packages.microsoft.com/keys/microsoft.asc" %}
{% set unixODBC= dict['unixODBC'] %}
{% set unixODBC_devel= dict['unixODBC_devel'] %}
{% set pymysql_url= dict['pymysql_url'] %}
{% set pymysql= "PyMySQL-1.0.2" %}
{% set pymysql_file= pymysql + ".tar.gz" %}
{% set cassandra_driver= dict['cassandra_driver']%}
{% set cassandra_driver_file= "cassandra_driver-3.25.0-cp36-cp36m-manylinux1_x86_64.whl" %}
{% set geomet= dict['geomet']%}
{% set geomet_file= "geomet-0.2.1.post1-py3-none-any.whl" %}
{% set six= dict['six']%}
{% set six_file= "six-1.16.0-py2.py3-none-any.whl" %}
{% set click= dict['click']%}
{% set click_file= "click-8.0.3-py3-none-any.whl" %}
{% set importlib_metadata= dict['importlib_metadata']%}
{% set importlib_metadata_file= "importlib_metadata-4.8.3-py3-none-any.whl" %}
{% set typing_extensions= dict['typing_extensions']%}
{% set typing_extensions_file= "typing_extensions-4.0.1-py3-none-any.whl" %}
{% set zipp= dict['zipp']%}
{% set zipp_file= "zipp-3.6.0-py3-none-any.whl" %}
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


{% if cluster!= '' %}
{% set dict = salt['pillar.get'] ('DICT','') %}
{% set cassandraadminuser= dict['CSD_DB_ADMIN_USER'] %}
{% set cassandraadminpwd= dict['CSD_DB_ADMIN_PWD'] %}
{% set replicationfactor= dict['CSD_DB_REPLICATION_FACTOR'] %}

{% set csdservernodes= dict['CSD_SERVER_NODES'] %}
{% set csdport= dict['CSD_PORT'] %}

{% set csd_master = csdservernodes.split(',')[0] %}


{% endif %}
#DataCenter/Tier params
#--------------------------------



#Cluster Params
#--------------------------------
{% set cassandra_seed_ips= '127.0.0.1' %}


#Tenant Params
#---------------------------------



#Other/Internal Params
#---------------------------------

