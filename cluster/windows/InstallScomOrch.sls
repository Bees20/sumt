{% import "./Connectionvars.sls" as base %}

{% if salt['pillar.get']('environment') == 'PROD' %}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}

{% set scomManagementServer = salt['cmdb_lib3.getscomManagementServer'](base.connect,salt['pillar.get']('datacenter')) %}

{% set repoServer = salt['cmdb_lib3.getRepoServer'](base.connect,salt['pillar.get']('datacenter')) %}

{% set Domain = salt['cmdb_lib3.domain'](base.connect,salt['pillar.get']('datacenter')) %}

{% for server in clusterservers %}

InstallScom {{ server }}:
  salt.state:
    - tgt: {{ server }}
    - sls:
      - cluster/windows/InstallScom
    - pillar:
        reposerver: {{ repoServer }}
        managementServer: {{ scomManagementServer }}
        domain: {{ Domain }}
    - retry:
        attempts: 3
        until: True
        interval: 45
        splay: 10
    - queue: True
{% endfor %}

{% else %}
Validated:
  test.succeed_without_changes
{% endif %}
