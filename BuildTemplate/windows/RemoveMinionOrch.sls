{% import "./Connectionvars.sls" as base %}

{% for role in pillar['clusterroles'] %}

{% set Roleversion = salt['cmdb_lib3.getRoleversion'](base.connect,pillar['packageName'],role) %}

{% set instance = salt['cmdb_lib3.getRoleTemplateName'](base.connect,pillar['datacenter'],role,Roleversion,pillar['packageName']) %}

Remove IP and  Salt Minion {{ instance }}:
  salt.state:
    - sls:
      - BuildTemplate/windows/removeminion
    - tgt: {{ instance }}
    - timeout: 10
    - check_cmd:
      - /bin/true
    - pillar:
        adminuser: {{ salt['cmdb_lib3.getWindowsAccountName'](base.connect,pillar['datacenter']) }}
        adminpwd: '{{ salt['cmdb_lib3.getresource'](base.connect,salt['cmdb_lib3.getWindowsResourceName'](base.connect,pillar['datacenter']),salt['cmdb_lib3.getWindowsAccountName'](base.connect,pillar['datacenter'])) }}'

{% endfor %}

Wait_for_Minion uninstall:
  module.run:
    - name: test.sleep
    - length: 360

