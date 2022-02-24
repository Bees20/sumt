{% import "./Connectionvars.sls" as base %}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}

{% set Domain = salt['cmdb_lib3.domain'](base.connect,pillar['datacenter']) %}

{% set domainpasswd = salt['cmdb_lib3.getresource'](base.connect,salt['pillar.get']('domainuser'),salt['pillar.get']('domainuser')) %}

{% for server in clusterservers %}

Join Domain {{ server }}:
  salt.state:
    - sls:
      - cluster/Linux/domain
    - tgt: {{ server }}
    - pillar:
        Domain: {{ Domain }}
        passwd: {{ domainpasswd }}
        domainuser: {{ salt['pillar.get']('domainuser') }}
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10
    - queue: True
{% endfor %}

