{% import "./Connectionvars.sls" as base %}

{% for role in pillar['clusterroles'] %}

{% set Roleversion = salt['cmdb_lib3.getRoleversion'](base.connect,pillar['packageName'],role) %}

{% set instance = salt['cmdb_lib3.getRoleTemplateName'](base.connect,pillar['datacenter'],role,Roleversion,pillar['packageName']) %}

Unjoin a computer from an AD Domain {{ instance }}:
  salt.state:
    - sls:
      - BuildTemplate/windows/UnjoinDomain
    - tgt: {{ instance }}
    - pillar:
        domainuser: {{ salt['pillar.get']('domainuser') }}
        domainpwd: {{ salt['cmdb_lib3.getresource'](base.connect,salt['pillar.get']('domainuser'),salt['pillar.get']('domainuser')) }}
        domain: {{ salt['cmdb_lib3.domain'](base.connect,pillar['datacenter']) }}
    - parallel: True

wait_for_minion Reboot {{ instance }}:
  salt.wait_for_event:
    - name: salt/minion/*/start
    - id_list:
      - {{ instance }}
    - timeout: 2000
    - require:
      - salt: Unjoin a computer from an AD Domain {{ instance }}

{% endfor %}
