
{% import "./Connectionvars.sls" as base %}
{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}

{% set ntp_server = salt['cmdb_lib3.get_ntp_server'](base.connect,salt['pillar.get']('datacenter')) %}



{% for server in clusterservers %}

Configure ntp {{ server }}:
  salt.state:
    - sls:
      - cluster/Linux/ntp
    - tgt: {{ server }}
    - pillar:
        ntpServer: {{ ntp_server }}
    - queue: True

SSSD Changes {{ server }}:
  salt.state:
    - tgt: {{ server }}
    - sls:
      - cluster/Linux/sssdchanges
    - retry:
        attempts: 3
        until: True
        interval: 20
        splay: 10
    - queue: True

{% endfor %}

