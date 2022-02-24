{% set clustername = pillar['cluster'] %}
{% set serverport = pillar['port'] %}
{% set sg = 'sg_'~ clustername ~'_'~ serverport ~'' %}
{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}
{% set role = pillar['role'] %}
{% if role == 'URW' %}
{% set svrtimeout = 1800 %}
{% else %}
{% set svrtimeout = 360 %}
{% endif %}

addsg:
  module.run:
    - name: netscaler.servicegroup_add
    - sg_name: {{ sg }}
    - maxclient: 0
    - maxreq: 0
    - useip: NO
    - useproxyport: YES
    - clttimeout: 180
    - svrtimeout: {{ svrtimeout }}
    - cka: YES
    - tcpb: NO
    - cmp: YES
    - connection_args: {
        netscaler_host: {{ pillar['lb'] }},
        netscaler_user: {{ pillar['lbaccount'] }},
        netscaler_pass: {{ pillar['password'] }},
        netscaler_useSSL: 'False'
      }

