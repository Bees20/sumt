{% import "./Connectionvars.sls" as base %}

{% set instances = salt['cmdb_lib3.getRoleTemplateNamev1'](base.connect,pillar['datacenter'],pillar['clusterroles'],pillar['packageName']) %}

{% set SaltMasters = salt['cmdb_lib3.getSaltMasters'](base.connect,salt['pillar.get']('datacenter')) %}

{% for value in instances %}

Delete VM in Vcenter {{ value['instance'] }}:
  salt.runner:
    - name: cloud.action
    - func: destroy
    - instance: {{ value['instance'] }}
    - retry:
        attempts: 5
        until: True
        interval: 60
        splay: 10

  {% for master in SaltMasters %}

Delete Role Template Server keys {{ value['instance'] }} on {{ master }}:
  salt.state:
    - sls:
      - BuildTemplate/Linux/DeleteKey
    - tgt: {{ master }}
    - pillar:
        instance: {{ value['instance'] }}
    - queue: True

  {% endfor %}

{% endfor %}
