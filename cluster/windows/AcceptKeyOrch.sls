{% import "./Connectionvars.sls" as base %}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}


{% for master in salt['cmdb_lib3.getSaltMasters'](base.connect,salt['pillar.get']('datacenter')) %}

  {% for server in clusterservers %}
Accept Cluster Server keys {{ server }} on {{ master }}:
  salt.state:
    - sls:
      - cluster/windows/AcceptKey
    - tgt: {{ master }}
    - pillar:
        instance: {{ server }}
    - queue: True


  {% endfor %}
{% endfor %}

