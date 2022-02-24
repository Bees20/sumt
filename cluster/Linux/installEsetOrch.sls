{% import "./Connectionvars.sls" as base %}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}

{% set repoServer = salt['cmdb_lib3.getRepoServer'](base.connect,salt['pillar.get']('datacenter')) %}

{% for server in clusterservers %}

Install ESET {{ server }}:
  salt.state:
    - sls:
      - cluster/Linux/installEset
    - tgt: {{ server }}
    - pillar:
        repoServer: {{ repoServer }}
    - retry:
        attempts: 3
        until: True
        interval: 45
        splay: 10
    - queue: True
{% endfor %}

