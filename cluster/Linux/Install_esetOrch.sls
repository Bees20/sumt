{% import "./Connectionvars.sls" as base %}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}

{% set eset_dict = salt['cmdb_lib3.get_eset_config'](base.connect,pillar['datacenter']) %}

{% set eset_pass = salt['cmdb_lib3.getresource'](base.connect,eset_dict['CO_ESET_WEBCONSOLE_RESOURCENAME'],eset_dict['CO_ESET_WEBCONSOLE_ACCOUNTNAME']) %}

{% set repoServer = salt['cmdb_lib3.getRepoServer'](base.connect,salt['pillar.get']('datacenter')) %}

{% for server in clusterservers %}

Install ESET {{ server }}:
  salt.state:
    - sls:
      - cluster/Linux/Install_ESET
    - tgt: {{ server }}
    - pillar:
        eset_dict: {{ eset_dict }}
        eset_pass: {{ eset_pass }}
        repoServer: {{ repoServer }}
    - retry:
        attempts: 3
        until: True
        interval: 45
        splay: 10
    - queue: True
{% endfor %}

