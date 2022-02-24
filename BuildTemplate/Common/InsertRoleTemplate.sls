{% import "./Connectionvars.sls" as base %}

{% set instances = salt['cmdb_lib3.getRoleTemplateNamev1'](base.connect,pillar['datacenter'],pillar['clusterroles'],pillar['packageName']) %}

{% set shortversion = pillar['packageName'] | regex_replace('\\.|\\-', '') %}

{% for value in instances %}

{% set Roleversion = salt['cmdb_lib3.getRoleversion'](base.connect,pillar['packageName'],value['role']) %}

{% set templateDesc = ['SALT ROLE TEMPLATE ',shortversion,' ',Roleversion,' ',value['role']] | join %}

Insert Role Template {{ value['instance'] }} Into CMDB:
  module.run:
    - name: cmdb_lib3.insertRoleTemplate
    - connect: {{ base.connect }}
    - datacenter: "{{ pillar['datacenter'] }}"
    - package: "{{ pillar['package'] }}"
    - role: "{{ value['role'] }}"
    - templateName: "{{ value['instance'] }}"
    - templateDescription: "{{ templateDesc }}"


{% endfor %}
