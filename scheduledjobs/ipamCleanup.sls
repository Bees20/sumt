{% import "./Connectionvars.sls" as base %}

IPAM Cleanup SQL:
  module.run:
    - name: cmdb_lib3.cleanupIpamNodes
    - connect: {{ base.connect }}
    - datacenter: {{ pillar['datacenter'] }}
