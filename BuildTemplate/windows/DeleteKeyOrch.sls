{% import "./Connectionvars.sls" as base %}

{% for role in pillar['clusterroles'] %}

{% set Roleversion = salt['cmdb_lib3.getRoleversion'](base.connect,pillar['packageName'],role) %}

{% set instance = salt['cmdb_lib3.getRoleTemplateName'](base.connect,pillar['datacenter'],role,Roleversion,pillar['packageName']) %}

Delete VM in Vcenter {{ role }}:
  salt.runner:
    - name: cloud.action
    - func: destroy
    - instance: {{ instance }}
    - retry:
        attempts: 5
        until: True
        interval: 60
        splay: 10

{% for master in salt['cmdb_lib3.getSaltMasters'](base.connect,salt['pillar.get']('datacenter')) %}

Delete Role Template Server keys {{ instance }} on {{ master }}:
  salt.state:
    - sls:
      - BuildTemplate/windows/DeleteKey
    - tgt: {{ master }}
    - pillar:
        instance: {{ instance }}
    - queue: True

{% endfor %}

{% endfor %}
