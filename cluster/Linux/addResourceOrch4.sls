{% import "./Connectionvars.sls" as base %}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}

{% set adminpasswd = salt['cmdb_lib3.getresource'](base.connect,['vRA_',salt['pillar.get']('datacenter')] | join,salt['pillar.get']('user')) %}

{% for server in clusterservers %}

Add Service account {{ server }}:
  salt.runner:
    - name: state.orch
    - mods: cluster/Linux/addResource
    - pillar:
        server: {{ server }}
        adminpasswd: {{ adminpasswd }}
        user: {{ salt['pillar.get']('user') }}

{% endfor %}

