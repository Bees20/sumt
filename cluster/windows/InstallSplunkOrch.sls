{% import "./Connectionvars.sls" as base %}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}

{% set splunkDeploymentServer = salt['cmdb_lib3.getsplunkDeploymentServer'](base.connect,salt['pillar.get']('datacenter')) %}

{% set splunkWindowsInstaller = salt['cmdb_lib3.getsplunkWindowsInstaller'](base.connect,salt['pillar.get']('datacenter')) %}

{% set repoServer = salt['cmdb_lib3.getRepoServer'](base.connect,salt['pillar.get']('datacenter')) %}

{% for server in clusterservers %}

InstallSplunk {{ server }}:
  salt.state:
    - tgt: {{ server }}
    - sls:
      - cluster/windows/InstallSplunk
    - pillar:
        reposerver: {{ repoServer }}
        splunkInstaller: {{ splunkWindowsInstaller }}
        deploymentserver: {{ splunkDeploymentServer }}
    - retry:
        attempts: 3
        until: True
        interval: 45
        splay: 10
    - queue: True
{% endfor %}
