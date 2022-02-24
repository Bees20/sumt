{% set clustername = pillar['cluster'] %}
{% set serverport = '80' %}
{% set lbvs = 'vs_'~ clustername ~'_'~ serverport ~'' %}
{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}

setlbvserverfroURW:
  module.run:
    - name: netscaler.lbvserver_update
    - lbvs_name: {{ lbvs }}
    - persistencetype: 'RULE'
    - rule: 'jsession_persistence_req'
    - resrule: 'jsession_persistence_res'
    - connection_args: {
        netscaler_host: {{ pillar['lb'] }},
        netscaler_user: {{ pillar['lbaccount'] }},
        netscaler_pass: {{ pillar['password'] }},
        netscaler_useSSL: 'False'
      }
