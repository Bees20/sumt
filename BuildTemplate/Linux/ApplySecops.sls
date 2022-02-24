{% import "./Connectionvars.sls" as base %}
{% set target = pillar['name'] %}
{% set version = pillar['packageName'] %}
{% set vm_type = pillar['role'] %}
{% set role_version = pillar['Roleversion'] %}


{% set SaltAPI = salt['cmdb_lib3.getConfigValueByKey'](base.connect,pillar['datacenter'],'SALT_API_URL') %}

{% set user = salt['pillar.get']('domainuser') %}

{% set domainpasswd = salt['cmdb_lib3.getresource'](base.connect,salt['pillar.get']('domainuser'),salt['pillar.get']('domainuser')) %}


{% set benchmark_ids = salt['cmdb_lib3.getBenchmarkID'](base.connect,version,vm_type,role_version) %}
{% set check_id1 = salt['cmdb_lib3.getCheckID'](base.connect,version,vm_type,role_version) %}
{% set variables = salt['cmdb_lib3.getVariables'](base.connect,version,vm_type,role_version)%}
{% set tar_ret_id = salt['sec_api.createTarget'](target,SaltAPI,user,domainpasswd) %}
{% set pol_ret_id = salt['sec_api.createPolicy'](target,tar_ret_id,benchmark_ids,check_id1,variables,SaltAPI,user,domainpasswd) %}
{#% set assess_policy = salt['sec_api.assessPolicy'](pol_ret_id,SaltAPI,user,domainpasswd) %#}

Pause to allow assessment to finish {{ target }}:
  cmd.run:
    - name: sleep 10; echo {{ pol_ret_id }}

{% set remediate_policy = salt['sec_api.remediatePolicy'](target,SaltAPI,user,domainpasswd) %}

