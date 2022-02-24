{% set clustername = pillar['cluster'] %}
{% set role = pillar['role'] %}
{% set clusterversion = pillar['clusterversion'] %}
{% set port = pillar['port'] %}
{% set sg = 'sg_'~ clustername ~'_'~ port ~'' %}
{% if role != 'URW' %}
{% set monitor = 'mon_'~ clusterversion ~'-'~ role ~'' %}
{% else %}
{%set monitor = 'tcp' %}
{% endif %}
{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}

bindsgtomonitor:
  module.run:
    - name: netscaler.sglbmonitorbinding_add
    - mon_name: {{ monitor }}
    - sg_name: {{ sg }}
    - connection_args: {
        netscaler_host: {{ pillar['lb'] }},
        netscaler_user: {{ pillar['lbaccount'] }},
        netscaler_pass: {{ pillar['password'] }},
        netscaler_useSSL: 'False'
      }
