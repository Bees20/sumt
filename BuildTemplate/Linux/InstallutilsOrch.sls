{% import "./Connectionvars.sls" as base %}

{% set instances = salt['cmdb_lib3.getRoleTemplateNamev1'](base.connect,pillar['datacenter'],pillar['clusterroles'],pillar['packageName']) %}

{% for value in instances %}

Install_Packages {{ value['instance'] }}:
  salt.state:
    - sls:
      - BuildTemplate/Linux/Install_utils
    - tgt: {{ value['instance'] }}
    - parallel: True

{% endfor %}
