{% import "./Connectionvars.sls" as base %}

{% for master in salt['cmdb_lib3.getSaltMasters'](base.connect,salt['pillar.get']('datacenter')) %}

  {% for server in salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}
Accept Cluster Server keys {{ server }} on {{ master }}:
  salt.state:
    - sls:
      - cluster/Linux/AcceptKey
    - tgt: {{ master }}
    - pillar:
        instance: {{ server }}
    - queue: True
  {% endfor %}
{% endfor %}
