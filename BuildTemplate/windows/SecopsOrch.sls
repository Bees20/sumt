{% import "./Connectionvars.sls" as base %}

{% for role in pillar['clusterroles'] %}

{% set Roleversion = salt['cmdb_lib3.getRoleversion'](base.connect,pillar['packageName'],role) %}

{% set instance = salt['cmdb_lib3.getRoleTemplateName'](base.connect,pillar['datacenter'],role,Roleversion,pillar['packageName']) %}


Apply SecOps policies {{ instance }}:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/windows/Apply_SecOps
    - pillar:
        name: {{ instance }}
        packageName: {{ pillar['packageName'] }}
        role: {{ role }}
        Roleversion: {{ Roleversion }}
        datacenter: {{ pillar['datacenter'] }}
    - parallel: True
    - retry:
        attempts: 3
        until: True
        interval: 45
        splay: 10

Wait for Policy {{ instance }}:
  module.run:
    - name: test.sleep
    - length: 10

{% endfor %}
