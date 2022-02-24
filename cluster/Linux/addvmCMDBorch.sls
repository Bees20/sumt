{% import "./Connectionvars.sls" as base %}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}

{% for server in clusterservers %}

Add VM to CMDB {{  server }}:
  salt.runner:
    - name: state.orch
    - mods: cluster/Linux/addvmCMDB
    - pillar:
        server: {{ server }}
        clusterrole: {{ salt['pillar.get']('clusterrole') }}
        environment: {{ salt['pillar.get']('environment') }}
        ClusterName: {{ salt['pillar.get']('ClusterName') }}
        datacenter: {{ salt['pillar.get']('datacenter') }}
{% endfor %}
