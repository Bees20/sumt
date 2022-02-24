{% import "./Connectionvars.sls" as base %}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}

{% set domainpasswd = salt['cmdb_lib3.getresource'](base.connect,salt['pillar.get']('domainuser'),salt['pillar.get']('domainuser')) %}

{% set Binary = salt['cmdb_lib3.GetSplunk'](base.connect,pillar['datacenter']) %}

{% set Domain = salt['cmdb_lib3.domain'](base.connect,pillar['datacenter']) %}


{% for server in clusterservers %}

InstallSplunk {{ server }}:
  salt.state:
    - tgt: {{ server }}
    - sls:
      - cluster/Linux/splunk
    - pillar:
        Domain: {{ Domain }}
        passwd: {{ domainpasswd }}
        domainuser: {{ salt['pillar.get']('domainuser') }}
        Binary: {{ Binary }}
        datacenter: {{ pillar['datacenter'] }}
    - retry:
        attempts: 3
        until: True
        interval: 45
        splay: 10
    - queue: True
{% endfor %}

