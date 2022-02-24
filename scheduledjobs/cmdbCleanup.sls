{% import "./Connectionvars.sls" as base %}

CMDB Cleanup SQL:
  module.run:
    - name: cmdb_lib3.cleanupIPAddresses
    - connect: {{ base.connect }}
