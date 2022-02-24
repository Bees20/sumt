{% import "./Connectionvars.sls" as base %}

{% for role in pillar['clusterroles'] %}

{% set Roleversion = salt['cmdb_lib3.getRoleversion'](base.connect,pillar['packageName'],role) %}

{% set instance = salt['cmdb_lib3.getRoleTemplateName'](base.connect,pillar['datacenter'],role,Roleversion,pillar['packageName']) %}

Modify minion config {{ instance }}:
  salt.state:
    - sls:
      - BuildTemplate/windows/config
    - tgt: {{ instance }}


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
