{% import "./Connectionvars.sls" as base %}

{% set adminpwd = salt['cmdb_lib3.getresource'](base.connect,salt['cmdb_lib3.getWindowsResourceName'](base.connect,pillar['datacenter']),salt['cmdb_lib3.getWindowsAccountName'](base.connect,pillar['datacenter'])) %}

{% for role in pillar['clusterroles'] %}

{% set Roleversion = salt['cmdb_lib3.getRoleversion'](base.connect,pillar['packageName'],role) %}

{% set instance = salt['cmdb_lib3.getRoleTemplateName'](base.connect,pillar['datacenter'],role,Roleversion,pillar['packageName']) %}

{% set ipaddress = salt.cmd.run('salt-cloud -a get_ipaddress '~ instance ~' -y').splitlines() | last | trim %}
Restart salt minion {{ instance }}:
  module.run:
    - name: cmdb_lib3.restartminion
    - host: "{{ ipaddress }}"
    - user: {{ salt['cmdb_lib3.getWindowsAccountName'](base.connect,pillar['datacenter']) }}
    - password: "{{ adminpwd }}"
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10
    - parallel: True

{% endfor %}

