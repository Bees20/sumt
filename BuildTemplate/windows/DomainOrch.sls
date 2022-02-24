{% import "./Connectionvars.sls" as base %}

{% set domainpasswd = salt['cmdb_lib3.getresource'](base.connect,salt['pillar.get']('domainuser'),salt['pillar.get']('domainuser')) %}

{% set Domain = salt['cmdb_lib3.domain'](base.connect,pillar['datacenter']) %}

{% for role in pillar['clusterroles'] %}

{% set Roleversion = salt['cmdb_lib3.getRoleversion'](base.connect,pillar['packageName'],role) %}

{% set instance = salt['cmdb_lib3.getRoleTemplateName'](base.connect,pillar['datacenter'],role,Roleversion,pillar['packageName']) %}

Join into Domain {{ instance }}:
  salt.state:
    - sls:
      - BuildTemplate/windows/JoinDomain
    - tgt: {{ instance }}
    - pillar:
        domainuser: {{ salt['pillar.get']('domainuser') }}
        domainpwd: {{ domainpasswd  }}
        domain: {{ Domain }}
    - parallel: True

wait for vm {{ instance }} reboot:
  salt.wait_for_event:
    - name: salt/minion/*/start
    - id_list:
      - {{ instance }}
    - require:
      - salt: Join into Domain {{ instance }}
    - timeout: 900

Change Minion Log on AS service {{ instance }}:
  salt.state:
    - sls:
      - BuildTemplate/windows/minionLogonAs
    - tgt: {{ instance }}
    - pillar:
        domain: {{ Domain }}
        domainuser: {{ salt['pillar.get']('domainuser') }}
        domainpasswd: {{ domainpasswd }}
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
