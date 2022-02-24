{% import "./Connectionvars.sls" as base %}

{% set policy_name = pillar['policy_name'] %}

{% set SaltAPI = salt['cmdb_lib3.getConfigValueByKey'](base.connect,pillar['datacenter'],'SALT_API_URL') %}

{% set user = salt['pillar.get']('domainuser') %}

{% set domainpasswd = salt['cmdb_lib3.getresource'](base.connect,salt['pillar.get']('domainuser'),salt['pillar.get']('domainuser')) %}

Assess Policy:
  module.run:
    - name: sec_api.reAssessPolicy
    - policy_name: '{{ policy_name }}'
    - API: {{ SaltAPI }}
    - user: {{ user }}
    - password: {{ domainpasswd }}

