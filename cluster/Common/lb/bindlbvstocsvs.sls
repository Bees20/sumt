{% set clustername = pillar['cluster'] %}
{% set serverport = pillar['port'] %}
{% set sslport = '443' %}
{% set lbvs = 'vs_'~ clustername ~'_'~ serverport ~'' %}
{% set csvs = 'cs_'~ clustername ~'_'~ sslport ~'' %}
{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}

bindcsvstolbvs:
  module.run:
    - name: netscaler.csvslbvs_bind
    - csvs_name: {{ csvs }}
    - lbvs_name: {{ lbvs }}
    - connection_args: {
        netscaler_host: {{ pillar['lb'] }},
        netscaler_user: {{ pillar['lbaccount'] }},
        netscaler_pass: {{ pillar['password'] }},
        netscaler_useSSL: 'False'
      }
