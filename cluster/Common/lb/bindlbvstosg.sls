{% set clustername = pillar['cluster'] %}
{% set port = pillar['port'] %}
{% set lbvs = 'vs_'~ clustername ~'_'~ port ~'' %}
{% set sg = 'sg_'~ clustername ~'_'~ port ~'' %}
{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}

bindlbvstosg:
  module.run:
    - name: netscaler.vserver_servicegroup_add
    - v_name: {{ lbvs }}
    - sg_name: {{ sg }}
    - connection_args: {
        netscaler_host: {{ pillar['lb'] }},
        netscaler_user: {{ pillar['lbaccount'] }},
        netscaler_pass: {{ pillar['password'] }},
        netscaler_useSSL: 'False'
      }
