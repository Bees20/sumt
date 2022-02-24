{% import "./Connectionvars.sls" as base %}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}

{% set clusterserversIP = salt['cmdb_lib3.getClusterServerIP'](base.connect,pillar['ClusterName']) %}

{% set adminpwd = salt['cmdb_lib3.getresource'](base.connect,salt['cmdb_lib3.getWindowsResourceName'](base.connect,pillar['datacenter']),salt['cmdb_lib3.getWindowsAccountName'](base.connect,pillar['datacenter'])) %}


{% for i in range(0,clusterservers|length) %}

Modify minion config {{ clusterservers[i] }}:
  salt.state:
    - sls:
      - cluster/windows/config
    - tgt: {{ clusterservers[i] }}

Restart minion {{ clusterservers[i] }}:
  salt.function:
    - name: cmd.run_bg
    - tgt: {{ clusterservers[i] }}
    - arg:
        - 'salt-call --local service.restart salt-minion'

Start salt minion {{ clusterservers[i] }}:
  module.run:
    - name: cmdb_lib3.restartminion
    - host: "{{ clusterserversIP[i] }}"
    - user: {{ salt['cmdb_lib3.getWindowsAccountName'](base.connect,pillar['datacenter']) }}
    - password: "{{ adminpwd }}"

wait for minion restart {{ clusterservers[i] }}:
  salt.wait_for_event:
    - name: salt/minion/*/start
    - id_list:
      - {{ clusterservers[i] }}
    - require:
      - salt: Restart minion {{ clusterservers[i] }}

{% endfor %}
