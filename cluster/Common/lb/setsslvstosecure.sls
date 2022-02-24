{% set clustername = pillar['cluster'] %}
{% set port = '443' %}
{% set csvs = 'cs_'~ clustername ~'_'~ port ~'' %}
{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}

setsslvstosec:
  module.run:
    - name: netscaler.setsslvs_update
    - csvs_name: {{ csvs }}
    - sslprofile: 'SECURE'
    - connection_args: {
        netscaler_host: {{ pillar['lb'] }},
        netscaler_user: {{ pillar['lbaccount'] }},
        netscaler_pass: {{ pillar['password'] }},
        netscaler_useSSL: 'False'
      }
