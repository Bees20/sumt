{% set clustername = pillar['cluster'] %}
{% set httpport = '80' %}
{% set cshttp = 'cs_'~ clustername ~'_'~ httpport ~'' %}
{% set policy = pillar['policy'] %}
{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}

bindcsvstopol:
  module.run:
    - name: netscaler.csvspolbind_add
    - csvs_name: {{ cshttp }}
    - pol_name: {{ policy }}
    - priority: 100
    - priorityexpr: 'END'
    - connection_args: {
        netscaler_host: {{ pillar['lb'] }},
        netscaler_user: {{ pillar['lbaccount'] }},
        netscaler_pass: {{ pillar['password'] }},
        netscaler_useSSL: 'False'
      }
