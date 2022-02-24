{% import "./Connectionvars.sls" as base %}

{% for master in salt['cmdb_lib3.getSaltMasters'](base.connect,salt['pillar.get']('datacenter')) %}

  {% for server in salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}
Delete Cluster Server keys {{ server }} on {{ master }}:
  salt.state:
    - sls:
      - cluster/windows/DeleteKey
    - tgt: {{ master }}
    - pillar:
        instance: {{ server }}
    - queue: True
  {% endfor %}
{% endfor %}

deletelocking:
  module.run:
    - name: cmdb_lib3.deletelock
    - connect: {{ base.connect }}
    - lockname: 'buildclusterserverlist'

