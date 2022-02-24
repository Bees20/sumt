{% import "./Connectionvars.sls" as base %}

{% set instances = salt['cmdb_lib3.getRoleTemplateNamev1'](base.connect,pillar['datacenter'],pillar['clusterroles'],pillar['packageName']) %}

{% set securityGroups = salt['cmdb_lib3.getConfigValueByKey'](base.connect,pillar['datacenter'],'CO_SUDOER_ACCOUNTS') %}

{% for value in instances %}

Sudo access {{ value['instance'] }}:
  salt.state:
    - sls:
      - BuildTemplate/Linux/sudoers
    - tgt: {{ value['instance'] }}
    - pillar:
        securityGroups: "{{ securityGroups }}"

{% if value['role']|last == 'D' %}

{% set DBsecurityGroups = salt['cmdb_lib3.getConfigValueByKey'](base.connect,pillar['datacenter'],'CO_SUDOER_DB_ACCOUNTS') %}

Sudo access for database roles {{ value['instance'] }}:
  salt.state:
    - sls:
      - BuildTemplate/Linux/sudoers
    - tgt: {{ value['instance'] }}
    - pillar:
        securityGroups: "{{ DBsecurityGroups }}"

{% endif %}

Remove IP from WhiteList {{ value['instance'] }}:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Common/RemoveIpfromWhitelistOrch
    - pillar: {{ dict(pillar) | json }}
    - onfail:
        - Sudo access {{ value['instance'] }}

{% endfor %}
