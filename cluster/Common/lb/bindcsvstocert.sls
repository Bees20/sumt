{% set clustername = pillar['cluster'] %}
{% set sslport = '443' %}
{% set csvs = 'cs_'~ clustername ~'_'~ sslport ~'' %}
{% set cert = pillar['cert'] %}
{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}

bindcsvstocert:
  module.run:
    - name: netscaler.bindcsvstocert_add
    - csvs_name: {{ csvs }}
    - cert_name: {{ cert }}
    - connection_args: {
        netscaler_host: {{ pillar['lb'] }},
        netscaler_user: {{ pillar['lbaccount'] }},
        netscaler_pass: {{ pillar['password'] }},
        netscaler_useSSL: 'False'
      }
