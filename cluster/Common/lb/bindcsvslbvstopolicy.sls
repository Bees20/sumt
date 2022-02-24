{% set cluster = pillar['cluster'] %}
{% set port = pillar['port'] %}
{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}
{% set lbvs = 'vs_'~ cluster ~'_'~ port ~'' %}
{% set publiccsname = pillar['publiccsname'] %}
{% set policy = 'pol_'~ cluster ~'_fqdn_match' %}
{% set clusternum = pillar['clusternum'] %}
{% set role = pillar['role'] %}
{% if role == 'UUW' %}
{% set priority = '7'~ clusternum ~'' %}
{% endif %}
{% if role == 'URW' %}
{% set priority = '4'~ clusternum ~'' %}
{% endif %}
{% if role == 'UUW' or role == 'URW' %}
bindcsvstopol:
  module.run:
    - name: netscaler.csvspollbvsbind_add
    - csvs_name: {{ publiccsname }}
    - pol_name: {{ policy }}
    - priority: {{ priority }}
    - lbvs: {{ lbvs }}
    - connection_args: {
        netscaler_host: {{ pillar['lb'] }},
        netscaler_user: {{ pillar['lbaccount'] }},
        netscaler_pass: {{ pillar['password'] }},
        netscaler_useSSL: 'False'
      }
{% endif %}
