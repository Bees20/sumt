{% set clustername = pillar['cluster'] %}
{% set serverport = pillar['port'] %}
{% set persistence = pillar['persistence'] %}
{% set backupvs = pillar['backupvs'] %}
{% set lbmethod = pillar['lbmethod'] %}
{% set lbvs = 'vs_'~ clustername ~'_'~ serverport ~'' %}
{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}

addlbvserver:
  module.run:
    - name: netscaler.lbvserver_add
    - lbvs_name: {{ lbvs }}
    - lbvs_type: HTTP
    - persistype: {{ persistence }}
    - backupvs: {{ backupvs }}
    - method: {{ lbmethod }}
    - ip: '0.0.0.0'
    - port: 0
    - clttimeout: 180
    - timeout: 1440
    - connection_args: {
        netscaler_host: {{ pillar['lb'] }},
        netscaler_user: {{ pillar['lbaccount'] }},
        netscaler_pass: {{ pillar['password'] }},
        netscaler_useSSL: 'False'
      }
