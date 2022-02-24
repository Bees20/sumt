{% import "./Connectionvars.sls" as base %}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}

{#% set shares = [salt['cmdb_lib3.getTenantShare'](base.connect,pillar['datacenter']),salt['cmdb_lib3.getPackageShare'](base.connect,pillar['datacenter'])] %#}

{% set Domain = salt['cmdb_lib3.domain'](base.connect,salt['pillar.get']('datacenter')) %}

{% for server in clusterservers %}

Symlink Creation on {{ server }}:
  salt.state:
    - tgt: {{ server }}
    - sls:
      - cluster/windows/symlink
    - pillar:
        domain: {{ Domain }}
        environment: {{ salt['pillar.get']('environment') }}
        datacenter: {{ salt['pillar.get']('datacenter') }}
        tenantShare: {{ salt['cmdb_lib3.getTenantShare'](base.connect,pillar['datacenter']) }}
        packageShare: {{ salt['cmdb_lib3.getPackageShare'](base.connect,pillar['datacenter']) }}
    - retry:
        attempts: 3
        until: True
        interval: 45
        splay: 10
    - queue: True
{% endfor %}
