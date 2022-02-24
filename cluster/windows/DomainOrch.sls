{% import "./Connectionvars.sls" as base %}
{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}
{% set Domain = salt['cmdb_lib3.domain'](base.connect,pillar['datacenter']) %}
{% set domainpasswd = salt['cmdb_lib3.getresource'](base.connect,salt['pillar.get']('domainuser'),salt['pillar.get']('domainuser')) %}

{% for server in clusterservers %}

Join into Domain {{ server }}:
  salt.state:
    - sls:
      - cluster/windows/JoinDomain
    - tgt: {{ server }}
    - pillar:
        domain: {{ Domain }}
        domainpwd: {{ domainpasswd }}
        domainuser: {{ salt['pillar.get']('domainuser') }}
    - parallel: True
    - queue: True

{% endfor %}

reboot_minion:
  salt.function:
    - name: system.reboot
    - tgt: [{% for server in clusterservers %}{{ [server,',']|join }}{% endfor %}]
    - tgt_type: list
    - kwarg:
        timeout: 1
        in_seconds: True
    - require:
      - salt: Join into Domain*

Wait_for_minion Reboot:
  salt.wait_for_event:
    - name: salt/minion/*/start
    - timeout: 1000
    - id_list:{% for server in clusterservers %}
      - {{ server }}{% endfor %}
    - require:
      - salt: reboot_minion

{% for server in clusterservers %}
Change Minion Log on AS service {{ server }}:
  salt.state:
    - sls:
      - cluster/windows/minionLogonAs
    - tgt: {{ server }}
    - pillar:
        domain: {{ Domain }}
        domainuser: {{ salt['pillar.get']('domainuser') }}
        domainpasswd: {{ domainpasswd }}
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10

{% endfor %}
