{% import "./Connectionvars.sls" as base %}

{% for role in pillar['clusterroles'] %}

{% set Roleversion = salt['cmdb_lib3.getRoleversion'](base.connect,pillar['packageName'],role) %}

{% set instance = salt['cmdb_lib3.getRoleTemplateName'](base.connect,pillar['datacenter'],role,Roleversion,pillar['packageName']) %}

{% for master in salt['cmdb_lib3.getSaltMasters'](base.connect,salt['pillar.get']('datacenter')) %}
Accept Cluster Server keys {{ instance }} on {{ master }}:
  salt.state:
    - sls:
      - BuildTemplate/Common/AcceptKey
    - tgt: {{ master }}
    - pillar:
        instance: {{ instance }}
    - queue: True
{% endfor %}
{% endfor %}
