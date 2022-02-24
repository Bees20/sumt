{% import "./Connectionvars.sls" as base %}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}

{% set clusterserversIP = salt['cmdb_lib3.getClusterServerIP'](base.connect,pillar['ClusterName']) %}

{% set adminpwd = salt['cmdb_lib3.getresource'](base.connect,salt['cmdb_lib3.getWindowsResourceName'](base.connect,pillar['datacenter']),salt['cmdb_lib3.getWindowsAccountName'](base.connect,pillar['datacenter'])) %}

{% for i in range(0,clusterservers|length) %}

Restart salt minion {{ clusterservers[i] }}:
  module.run:
    - name: cmdb_lib3.restartminion
    - host: "{{ clusterserversIP[i] }}"
    - user: {{ salt['cmdb_lib3.getWindowsAccountName'](base.connect,pillar['datacenter']) }}
    - password: "{{ adminpwd }}"
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10
    - queue: True
{% endfor %}
