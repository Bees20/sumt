{% import "./Connectionvars.sls" as base %}

{% set instances = salt['cmdb_lib3.getRoleTemplateNamev1'](base.connect,pillar['datacenter'],pillar['clusterroles'],pillar['packageName']) %}

{% set SaltMasters = salt['cmdb_lib3.getSaltMasters'](base.connect,salt['pillar.get']('datacenter')) %}

{% for value in instances %}

  {% for master in SaltMasters %}

Accept Cluster Server keys {{ value['instance'] }} on {{ master }}:
  salt.state:
    - sls:
      - BuildTemplate/Linux/AcceptKey
    - tgt: {{ master }}
    - pillar:
        instance: {{ value['instance'] }}
    - queue: True

  {% endfor %}

{% endfor %}
