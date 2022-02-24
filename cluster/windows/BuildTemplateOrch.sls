{% import "./Connectionvars.sls" as base %}

{% set roleversion = salt['cmdb_lib3.getRoleversion'](base.connect,pillar['packageName'],pillar['clusterrole']) %}

{% if pillar['datacenter'] == 'GSL' %}

{% set dc = 'LDC' %}

{% else %}

{% set dc = pillar['datacenter'] %}

{% endif %}

{% set instance = salt['cmdb_lib3.getRoleTemplateName'](base.connect,dc,pillar['clusterrole'],roleversion,pillar['packageName']) %}

{% set clusterRole = [] %}

{#% if (salt.cmd.shell('salt-cloud -f list_templates vmware | grep '~ instance ~'').splitlines() | last | trim) == instance %#}

{% if instance in (salt.cmd.shell('salt-cloud -f list_templates vmware | grep '~ instance ~'')) %}

Validation Success:
  cmd.run:
    - name: echo "{{ instance }} template found"

{% else %}

Provision RoleTemplate:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/windows/TemplateOrch
    - pillar:
        packageName: {{ pillar['packageName'] }}
        datacenter: {{ dc }}
        environment: {{ pillar['environment'] }}
        clusterroles: [ {{ pillar['clusterrole'] }}]
    - failhard: True

{% endif %}
