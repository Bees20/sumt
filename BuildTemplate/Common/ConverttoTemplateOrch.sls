{% import "./Connectionvars.sls" as base %}

{% set instances = salt['cmdb_lib3.getRoleTemplateNamev1'](base.connect,pillar['datacenter'],pillar['clusterroles'],pillar['packageName']) %}

{% for value in instances %}

Convert a VM to Template {{ value['instance'] }}:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Linux/ConverttoTemplate
    - pillar:
        instance: {{ value['instance'] }}
    - parallel: True

{% endfor %}
