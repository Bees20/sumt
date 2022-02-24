{% import "./Connectionvars.sls" as base %}

{% set DBroles = salt['cmdb_lib3.getwindowsDB'](base.connect,pillar['packageName']) %}

{% for role in pillar['clusterroles'] %}

{% set Roleversion = salt['cmdb_lib3.getRoleversion'](base.connect,pillar['packageName'],role) %}

{% set instance = salt['cmdb_lib3.getRoleTemplateName'](base.connect,pillar['datacenter'],role,Roleversion,pillar['packageName']) %}


Remove insecure windows permission for {{ instance }}:
  salt.state:
    - tgt: {{ instance }}
    - sls:
      - BuildTemplate/windows/WindowsPermission
    - pillar:
        DBroles: {{ DBroles }}
        clusterrole: {{ role }}
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10


Change Minion Log on AS service {{ instance }}:
  salt.state:
    - sls:
      - BuildTemplate/windows/minionLogonAsSystem
    - tgt: {{ instance }}
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10

Restart minion {{ instance }}:
  salt.function:
    - name: cmd.run_bg
    - tgt: {{ instance }}
    - arg:
        - 'salt-call --local service.restart salt-minion'

wait for minion restart {{ instance }}:
  salt.wait_for_event:
    - name: salt/minion/*/start
    - id_list:
      - {{ instance }}
    - require:
      - salt: Restart minion {{ instance }}


{% endfor %}
