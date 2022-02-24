{% set patset = pillar['patset'] %}
{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}

{#
getpatset:
  module.run:
    - name: netscaler.nspatset_get
    - p_name: {{ patset }}
    - connection_args: {
        netscaler_host: '{{ lb }}',
        netscaler_user: 'vro-admin',
        netscaler_pass: '{{ password }}',
        netscaler_useSSL: 'False'
      } #}

addpatset:
  module.run:
    - name: netscaler.nspatset_add
    - p_name: {{ patset }}
    - connection_args: {
        netscaler_host: {{ pillar['lb'] }},
        netscaler_user: {{ pillar['lbaccount'] }},
        netscaler_pass: {{ pillar['password'] }},
        netscaler_useSSL: 'False'
      }

