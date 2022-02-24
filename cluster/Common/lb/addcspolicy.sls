{% set cluster = pillar['cluster'] %}
{% set patset = pillar['patset'] %}
{% set role = pillar['role'] %}
{% set cspol = 'pol_'~ cluster ~'_fqdn_match' %}
{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}
{% if role == 'UUW' %}
{% set rule = 'HTTP.REQ.HOSTNAME.SET_TEXT_MODE(IGNORECASE).EQUALS_ANY(\\"'~ patset ~'\\")' %}
{% endif %}

{% if role == 'URW' %}

{% set rule = 'HTTP.REQ.HOSTNAME.SET_TEXT_MODE(IGNORECASE).EQUALS_ANY(\\"'~ patset ~'\\") && (HTTP.REQ.URL.PATH.SET_TEXT_MODE(IGNORECASE).GET(1).EQ(\\"jasperserver-pro\\") || HTTP.REQ.URL.PATH.SET_TEXT_MODE(IGNORECASE).GET(1).EQ(\\"monitor\\") || HTTP.REQ.URL.PATH.SET_TEXT_MODE(IGNORECASE).GET(1).EQ(\\"ReportingMobile\\"))'%}

{% endif %}

{% if role == 'UUW' or role == 'URW' %}
addcspolicy:
  module.run:
    - name: netscaler.cspolicy_add
    - cspol_name: {{ cspol }}
    - rule: "{{ rule }}"
    - connection_args: {
        netscaler_host: {{ pillar['lb'] }},
        netscaler_user: {{ pillar['lbaccount'] }},
        netscaler_pass: {{ pillar['password'] }},
        netscaler_useSSL: 'False'
      }
{% endif %}
