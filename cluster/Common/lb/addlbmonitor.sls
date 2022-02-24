{% set role = pillar['role'] %}
{% set clusterversion = pillar['clusterversion'] %}
{% set request = pillar['request'] %}
{% set req = 'GET '~ request ~'' %}
{% set response = pillar['response'] %}
{% set monitor = 'mon_'~ clusterversion ~'-'~ role ~'' %}
{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}

{% if role != 'URW' %}
addmonitor:
  module.run:
    - name: netscaler.monitor_add
    - mon_name: {{ monitor }}
    - mon_type: HTTP-ECV
    - mon_recv: "{{ response }}"
    - mon_send: "{{ req }}"
    - lrtm: 'ENABLED'
    - resptimeout: 5
    - interval: 10
    - connection_args: {
        netscaler_host: {{ pillar['lb'] }},
        netscaler_user: {{ pillar['lbaccount'] }},
        netscaler_pass: {{ pillar['password'] }},
        netscaler_useSSL: 'False'
      }
{% else %}

Validated:
  test.succeed_without_changes

{% endif %}
