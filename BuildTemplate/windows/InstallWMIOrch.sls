{% import "./Connectionvars.sls" as base %}

{% for role in pillar['clusterroles'] %}

{% set Roleversion = salt['cmdb_lib3.getRoleversion'](base.connect,pillar['packageName'],role) %}

{% set instance = salt['cmdb_lib3.getRoleTemplateName'](base.connect,pillar['datacenter'],role,Roleversion,pillar['packageName']) %}

Install Sysmon {{ instance }}:
  salt.state:
    - sls:
      - BuildTemplate/windows/InstallWmiExporter
    - tgt: {{ instance }}
    - pillar:
        reposerver: {{ salt['cmdb_lib3.getRepoServer'](base.connect,salt['pillar.get']('datacenter')) }}
    - parallel: True
{% endfor %}
