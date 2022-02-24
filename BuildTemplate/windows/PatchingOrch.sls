{% import "./Connectionvars.sls" as base %}

{% for role in pillar['clusterroles'] %}

{% set Roleversion = salt['cmdb_lib3.getRoleversion'](base.connect,pillar['packageName'],role) %}

{% set instance = salt['cmdb_lib3.getRoleTemplateName'](base.connect,pillar['datacenter'],role,Roleversion,pillar['packageName']) %}

Patching {{ instance }}:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/windows/windowspatching
    - pillar:
        instance: {{ instance }}
        wsusserver: {{ salt['cmdb_lib3.getWsusServer'](base.connect,salt['pillar.get']('datacenter')) }}
    - parallel: True
{% endfor %}

