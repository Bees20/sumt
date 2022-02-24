{% import "./Connectionvars.sls" as base %}

Add Config Keys into CMDB:
  module.run:
    - name: cmdb_lib3.{{ salt['pillar.get']('clusterrole') }}_CONFIGKEYS
    - connect: {{ base.connect }}
    - ClusterName: {{ salt['pillar.get']('ClusterName') }}
    - packagename: {{ salt['pillar.get']('packageName') }}
    - retry:
        attempts: 2
        until: True
        interval: 60
        splay: 10

