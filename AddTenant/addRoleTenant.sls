{% import "./Connectionvars.sls" as base %}

{% set suiteversion = pillar['packageName'].split('-')[0]| regex_replace('\\.|\\-', '') %}

{% set siteKey = salt['addTenant.getsiteKeyfromFQDN'](base.connect,pillar['FQDN']) %}

{% set execOrder =  salt['addTenant.get_INSTALL_TENANT'](base.connect,siteKey,pillar['packageName'],'ADD_TENANT') %}

{% for row in execOrder %}

{% set role = row[1] %}

{% set clusterName = salt['cmdb_lib3.getClusterbysiteKeyandRole'](base.connect,siteKey,role)[0] %}

{% if salt['addTenant.getassociatedcluster'](base.connect,clusterName) %}

{% set assoccluster = salt['addTenant.getassociatedcluster'](base.connect,clusterName) %}

{% else %}

{% set assoccluster = '' %}

{% endif %}

{% if role != 'UFS' %}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,clusterName)[0] %}
{% else %}

{% set clusterservers = salt['addTenant.getcmdb_uuwServerForUfsExec'](base.connect,siteKey) %}

{% endif %}

{% set params = "'" + clusterservers + "', '" + clusterName + "','" + assoccluster + "','ADD_TENANT','" + role + "','" + siteKey + "'" %}

{% set query = "select [dbo].[GET_PS_INSTALL_PARAMETERS](" + params + ")" %}

{% set Install_params = salt['cmdb_lib3.get_install_params'](base.connect,query,pillar['packageName'],role,pillar['datacenter'],salt['pillar.get']('sqlaccount'),salt['pillar.get']('udacresource'),salt['pillar.get']('domainuser')) %}

{% if role != 'UFS' %}

{% set Install_params = salt['addTenant.append_dict'](Install_params,"EXECUTE_FROM",row[4]) %}

{% else %}

{% set Install_params = salt['addTenant.append_dict'](Install_params,"EXECUTE_FROM", clusterservers ) %}

{% endif %}

Add Tenant {{ siteKey }}_{{ role }}:
  salt.runner:
    - name: state.orch
    - mods: {{ suiteversion }}.{{ role }}.Workflow.orch
    - pillar:
        VERSION: {{ pillar['packageName'] }}
        WORKFLOW: "ADD_TENANT"
        CLUSTER: {{ clusterName }}
        TENANT: {{ siteKey }}
        ROLE: {{ role }}
        SERVER: {{ clusterservers }}
        ASSOCIATED_CLUSTER: {{ assoccluster }}
        CLUSTERSERVERS: {{ clusterservers }}
        DICT: {{ Install_params | json }}
    - retry:
        attempts: 2
        until: True
        interval: 60
        splay: 10
    - failhard: True

{% if role in ['UUD','UWD'] %}

Run Post Scripts {{ siteKey }}_{{ role }}:
  module.run:
    - name: addTenant.postValidationSteps
    - connect: {{ base.connect }}
    - role: {{ role }}
    - siteKey: {{ siteKey }}
    - environment: {{ pillar['environment'] }}
    - require:
       - Add Tenant {{ siteKey }}_{{ role }}
    - retry:
        attempts: 2
        until: True
        interval: 60
        splay: 10
{% endif %}

{% endfor %}
