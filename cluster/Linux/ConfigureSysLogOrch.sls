{% import "./Connectionvars.sls" as base %}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}

{% set syslog_server = salt['cmdb_lib3.get_syslog_server'](base.connect,salt['pillar.get']('datacenter')) %}



{% for server in clusterservers %}

Configure SysLog {{ server }}:
  salt.state:
    - sls:
      - cluster/Linux/syslog
    - tgt: {{ server }}
    - pillar:
        syslogServer: {{ syslog_server }}
    - queue: True
{% endfor %}

