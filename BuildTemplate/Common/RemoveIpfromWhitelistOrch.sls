{% import "./Connectionvars.sls" as base %}

{% set instances = salt['cmdb_lib3.getRoleTemplateNamev1'](base.connect,pillar['datacenter'],pillar['clusterroles'],pillar['packageName']) %}

{% for value in instances %}

{% set serverIP = salt.cmd.run('salt '~ value['instance'] ~' grains.item fqdn_ip4').splitlines() | last | replace("-", "") | trim %}

{% if pillar['datacenter'] == 'AMS' %}

   {% set username = salt['cmdb_lib3.getLBAccountName'](base.connect,pillar['datacenter']) %}

   {% set password = salt['cmdb_lib3.getresource'](base.connect,salt['cmdb_lib3.getLBResourceName'](base.connect,pillar['datacenter']),salt['cmdb_lib3.getLBAccountName'](base.connect,pillar['datacenter'])) %}

  {% if pillar['environment'] == 'PROD' %}

    {% set vdom = "PROD-INET" %}

  {% else %}

     {% set vdom = "STAGE-INET" %}

  {% endif %}

{% set vdomfirewall = salt['cmdb_lib3.getvdomandfirewall'](base.connect,pillar['datacenter']) %}

Remove IP from whitelist for {{ serverIP }}:
  module.run:
    - name: SaltCommon.RemoveServerfromWhiteList
    - vdom: {{ vdom }}
    - username: "{{ username }}"
    - password: "{{ password }}"
    - firewall: "{{ vdomfirewall[0][1] }}"
    - servername: {{ value['instance'] }}
    - ipaddr: "{{ serverIP }}"
    - test: False

{% else %}

{% set target = salt['cmdb_lib3.getConfigValueByKey'](base.connect,pillar['datacenter'],'CO_OUTBOUND_WHITELIST_SERVER') %}
{% set whitelistPath = salt['cmdb_lib3.getConfigValueByKey'](base.connect,pillar['datacenter'],'CO_OUTBOUND_WHITELIST_PATH') %}

Remove IP {{ serverIP }} from whitelist:
  salt.state:
    - tgt: {{ target }}
    - sls:
      - BuildTemplate.Common.RemoveIpfromWhitelist
    - pillar:
        IP: {{ serverIP }}
        whitelistPath: {{ whitelistPath }}
    - retry:
        attempts: 3
    - queue: True

{% endif %}
{% endfor %}
