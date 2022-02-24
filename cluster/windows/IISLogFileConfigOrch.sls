{% import "./Connectionvars.sls" as base %}

{% if pillar['clusterrole'] == 'UUW' or pillar['clusterrole'] == 'UTA' %}

{% set adminpwd = salt['cmdb_lib3.getresource'](base.connect,salt['cmdb_lib3.getWindowsResourceName'](base.connect,pillar['datacenter']),salt['cmdb_lib3.getWindowsAccountName'](base.connect,pillar['datacenter'])) %}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}

{% for server in clusterservers %}

IISLogFileConfig {{ server }}:
  salt.state:
    - sls:
      - cluster/windows/IISLogFileConfig
    - tgt: {{ server }}
    - retry:
        attempts: 2
        until: True
        interval: 60
        splay: 10
    - queue: True

Restart minion {{ server }}:
  salt.function:
    - name: cmd.run_bg
    - tgt: {{ server }}
    - arg:
        - 'salt-call --local service.restart salt-minion'
    - queue: True

wait for minion restart {{ server }}:
  salt.wait_for_event:
    - name: salt/minion/*/start
    - id_list:
      - {{ server }}
    - require:
      - salt: Restart minion {{ server }}

IISLogFileRotation {{ server }}:
  salt.state:
    - sls:
      - cluster/windows/IISLogFileRotation
    - pillar:
        domainAdminUser: {{ salt['cmdb_lib3.getWindowsAccountName'](base.connect,pillar['datacenter']) }}
        domainAdminPass: "{{ adminpwd }}"
    - tgt: {{ server }}
    - retry:
        attempts: 2
        until: True
        interval: 60
        splay: 10
    - queue: True

{% endfor %}
{% else %}

Validated:
  test.succeed_without_changes

{% endif %}

