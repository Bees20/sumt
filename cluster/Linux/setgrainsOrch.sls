{% import "./Connectionvars.sls" as base %}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}

{% for server in clusterservers %}

set grains {{ server }}:
  salt.state:
    - sls:
      - cluster/Linux/setgrains
    - tgt: {{ server }}
    - pillar:
        ClusterName: {{ pillar['ClusterName'] }}
{% endfor %}
