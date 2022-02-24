{% set clustername = pillar['cluster'] %}
{% set csip = pillar['ip'] %}
{% set httpport = '80' %}
{% set sslport = '443' %}
{% set cshttp = 'cs_'~ clustername ~'_'~ httpport ~'' %}
{% set csssl = 'cs_'~ clustername ~'_'~ sslport ~'' %}
{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}

addhttpcsvserver:
  module.run:
    - name: netscaler.csvserver_add
    - csvs_name: {{ cshttp }}
    - csvs_type: HTTP
    - csip: {{ csip }}
    - csvs_port: {{ httpport }}
    - clttimeout: 180
    - connection_args: {
        netscaler_host: {{ pillar['lb'] }},
        netscaler_user: {{ pillar['lbaccount'] }},
        netscaler_pass: {{ pillar['password'] }},
        netscaler_useSSL: 'False'
      }
addsslcsvserver:
  module.run:
    - name: netscaler.csvserver_add
    - csvs_name: {{ csssl }}
    - csvs_type: SSL
    - csip: {{ csip }}
    - csvs_port: {{ sslport }}
    - clttimeout: 180
    - connection_args: {
        netscaler_host: {{ pillar['lb'] }},
        netscaler_user: {{ pillar['lbaccount'] }},
        netscaler_pass: {{ pillar['password'] }},
        netscaler_useSSL: 'False'
      }
