{% import "./Connectionvars.sls" as base %}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}

{% set smarthost = salt['cmdb_lib3.getSmartHost'](base.connect,pillar['datacenter']) %}

{% set Domain = salt['cmdb_lib3.domain'](base.connect,pillar['datacenter']) %}

{% if (salt['pillar.get']('clusterrole') in ('UTA','UUW')) %}

{% for server in clusterservers %}

Smart Host Setup {{ server }}:
  salt.state:
    - sls:
      - cluster/windows/smarthost
    - tgt: {{ server }}
    - pillar:
        vmName: {{ server }}
        domain: {{ Domain }}
        smarthost: {{ smarthost }}
    - retry:
        attempts: 2
        until: True
        interval: 60
        splay: 10

{% endfor %}

{% else %}

Validated udapackages:
  test.succeed_without_changes

{% endif %}
