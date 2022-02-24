{% import "./Connectionvars.sls" as base %}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}

{% set adminpasswd = salt['cmdb_lib3.getresource'](base.connect,['vRA_',salt['pillar.get']('datacenter')] | join,salt['pillar.get']('user')) %}

{% for server in clusterservers %}

change Admin passwd {{ server }}:
  salt.state:
    - tgt: {{ server }}
    - sls:
      - cluster/Linux/changepassword
    - pillar:
        adminpasswd: {{ adminpasswd }}
        user: {{ salt['pillar.get']('user') }}
    - queue: True
{% endfor %}

