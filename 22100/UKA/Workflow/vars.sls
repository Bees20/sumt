
#Workflow Params
#-------------------------------
{% set suite_version = salt['pillar.get']('VERSION', '') %}
{% set workflow = salt['pillar.get']('WORKFLOW', 'provision') %}
{% set cluster = salt['pillar.get']('CLUSTER', '') %}
{% set server = salt['pillar.get']('SERVER', '') %}
{% set clusterservers = salt['pillar.get']('CLUSTERSERVERS','') %}

{% set role= "UKA" %}
{% set parentfolder = suite_version.split('-')[0]| regex_replace('\\.|\\-', '') %}
{% set dict = salt['pillar.get'] ('DICT','') %}

{% if cluster!= '' %}
{% set zookeeper_nodes = salt['pillar.get']('assoClusterServersIP') %}
{% set zookeeper_port = '2181' %}

{% set zookeeper_temp = zookeeper_nodes|replace(",", ':'~ zookeeper_port  ~',') %}
{% set zookeeper_temp_string = zookeeper_temp + ":" + zookeeper_port %}

{% set majorserver = clusterservers[0] %}
{% set zookeeper_ip_string = zookeeper_temp_string ~ '/kafka' %}
{% set kafka_ip_string = dict['UKA_SERVER_NODES']  %} # also need a key to capture this
{% set kafka_port = dict['UKA_PORT'] or 9092 %}

{% set dict_hosts = salt['pillar.get']('VMdata') %}


{% endif %}


#Default Params
#-------------------------------
{% set kafka_version= "3.0.0" %}
{% set kafka_full_version= "2.12-3.0.0" %}
{% set kafka_download= "" %}
{% set kafka_download_path= "/tmp" %}
{% set kafka_download_file= "kafka_" + kafka_full_version + ".tgz" %}
{% set kafka_download_url= dict['kafka-3.0.0'] %}
{% set confluent_common_url= dict['confluent_common'] %}
{% set confluent_rest_utils_url= dict['confluent_rest_utils'] %}
{% set confluent_schema_registry_url= dict['confluent_schema_registry'] %}
{% set kafka_extraction_path= kafka_download_path + "/" + kafka_download_file %}
{% set kafka_install_as_service= 1 %}
{% set kafka_user= "kafka" %}
{% set kafka_group= "kafka" %}
{% set workflow_folder= parentfolder +"/"+ role +"/Workflow" %}
{% set templates_folder= parentfolder +"/"+ role +"/Templates" %}
{% set kafka_path = "/opt/kafka" %}
{% set log_path = "/opt/lib/kafka" %}
{% set ms_baseurl= "https://packages.microsoft.com/rhel/7/prod/" %}
{% set ms_gpgkey= "https://packages.microsoft.com/keys/microsoft.asc" %}
{% set confluent_full_version= "7.0.1-1" %}
{% set unixODBC= dict['unixODBC'] %}
{% set unixODBC_devel= dict['unixODBC_devel'] %}
{% set confluent_kafka= dict['confluent_kafka']%}
{% set enum= dict['enum']%}
{% set futures= dict['futures']%}
{% set pymysql_url= dict['pymysql_url'] %}
{% set confluent_kafka_file= "confluent_kafka-1.4.1-cp27-cp27mu-manylinux1_x86_64.whl" %}
{% set enum_file= "enum34-1.1.10-py2-none-any.whl" %}
{% set futures_file= "futures-3.3.0-py2-none-any.whl" %}
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



#Other/Internal Params
#---------------------------------
{% set schema_registry_path= "/etc/schema-registry" %}
{% set kafka_service_file = 'kafka.template' %}
{% set directories = kafka_path,schema_registry_path,log_path %}
{% set kafka_config_path= kafka_path + '/kafka_' + kafka_full_version + '/config/server.properties' %}
{% set kafka_install_path= kafka_path + '/kafka_' + kafka_full_version  %}

{% set share = dict["package_share_location"]|string %}
{% set user = dict["user"] %}
{% set domain = dict["domain"] %}
{% set passwd= dict["password"] %}
{% set package_root = "/opt/install" +"/"+ suite_version +"/"+ role %}
{% set templates_folder= parentfolder +"/"+ role +"/Templates" %}
{% set release_version = salt['pillar.get']('VERSION','') %}













