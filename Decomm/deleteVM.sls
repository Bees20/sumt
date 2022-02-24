{% import "./Connectionvars.sls" as base %}

{#% set ClusterID = salt['cmdb_lib3.getSaltClusterID'](salt['pillar.get']('Datacenter')) %#}

Delete VM in Vcenter:
  salt.runner:
    - name: cloud.action
    - func: destroy
    - instance: {{ pillar['instance'] }}
    - retry:
        attempts: 5
        until: True
        interval: 60
        splay: 10

{#
Delete keys:
  module.run:
    - name: sec_api.DeleteMinionKey
    - target: {{ pillar['instance'] }}
    - cluster: {{ ClusterID }}
#}

{% for master in salt['cmdb_lib3.getSaltMasters'](base.connect,salt['pillar.get']('Datacenter')) %}
Delete Cluster Server keys {{ salt['pillar.get']('instance') }} on {{ master }}:
  salt.state:
    - sls:
      - Decomm/DeleteKey
    - tgt: {{ master }}
    - pillar:
        instance: {{ salt['pillar.get']('instance') }}
{% endfor %}
