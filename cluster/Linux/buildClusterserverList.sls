{% import "./Connectionvars.sls" as base %}

{% set Networks = salt['cmdb_lib3.ipSublist'](base.connect,pillar['clusterrole'],pillar['datacenter'],pillar['environment']) %}

{% set ClusterServers = '' %}

{% set ClusterServers = salt['cmdb_lib3.buildServerlist'](base.connect,pillar['ClusterName'],pillar['numOfServers'],pillar['datacenter']) %}

{% set lb = salt['cmdb_lib3.getlb'](base.connect,pillar['datacenter'],pillar['environment']) %}

{% set lbaccount = salt['cmdb_lib3.getLBAccountName'](base.connect,pillar['datacenter']) %}

{% set lbpassword = salt['cmdb_lib3.getresource'](base.connect,salt['cmdb_lib3.getLBResourceName'](base.connect,pillar['datacenter']),salt['cmdb_lib3.getLBAccountName'](base.connect,pillar['datacenter'])) %}

{% set args = {"netscaler_host": lb,"netscaler_user": lbaccount,"netscaler_pass": lbpassword,"netscaler_useSSL": "False"} %}

{% if salt['cmdb_lib3.setlock'](base.connect,'buildclusterserverlist','20') %}

{% set iplist = salt['cmdb_lib3.getIP'](base.connect,Networks,pillar['datacenter'],pillar['numOfServers'],**args) %}

{% endif %}
