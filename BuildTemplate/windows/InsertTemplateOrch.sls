{% import "./Connectionvars.sls" as base %}

{% for role in pillar['clusterroles'] %}

{% set Roleversion = salt['cmdb_lib3.getRoleversion'](base.connect,pillar['packageName'],role) %}

{% set shortversion = pillar['packageName'] | regex_replace('\\.|\\-', '') %}

{% set instance = salt['cmdb_lib3.getRoleTemplateName'](base.connect,pillar['datacenter'],role,Roleversion,pillar['packageName']) %}

{% set templateDesc = ['SALT ROLE TEMPLATE ',shortversion,' ',Roleversion,' ',role] | join %}

Insert Role Template {{ instance }}:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/windows/InsertRoleTemplate
    - pillar:
        datacenter: "{{ pillar['datacenter'] }}"
        package: "{{ pillar['packageName'] }}"
        role: "{{ role }}"
        templateName: "{{ instance }}"
        templateDesc: "{{ templateDesc }}"
{% endfor %}
