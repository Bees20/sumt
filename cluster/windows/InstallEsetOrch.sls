{% import "./Connectionvars.sls" as base %}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}

{% set repoServer = salt['cmdb_lib3.getRepoServer'](base.connect,salt['pillar.get']('datacenter')) %}

{% for server in clusterservers %}

InstallESET {{ server }}:
  salt.state:
    - tgt: {{ server }}
    - sls:
      - cluster/windows/InstallEset
    - pillar:
        reposerver: {{ repoServer }}
    - retry:
        attempts: 3
        until: True
        interval: 45
        splay: 10
    - queue: True
{% endfor %}
