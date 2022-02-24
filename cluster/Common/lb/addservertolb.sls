{% import "./Connectionvars.sls" as base %}
{% set clustername = pillar['clustername'] %}
{% set packagename = pillar['packagename'] %}
{% set role = pillar['role'] %}
{% set ip = pillar['ip'] %}
{% set server = pillar['server'] %}
{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}

{% if salt['cmdb_lib3.isLoadBalanced'](base.connect,'ANY',packagename,role) %}
{% set dictdata = salt['cmdb_lib3.dictinfo'](base.connect,clustername,packagename) %}
{% set serverport = dictdata['serverPort'] %}
{% set sg = 'sg_'~ clustername ~'_'~ serverport ~'' %}
{% set sid = server[-1] %}
addserver {{ server }}:
  module.run:
    - name: netscaler.server_add
    - s_name: {{ server }}
    - s_ip: {{ ip }}
    - connection_args: {
        netscaler_host: {{ pillar['lb'] }},
        netscaler_user: {{ pillar['lbaccount'] }},
        netscaler_pass: {{ pillar['password'] }},
        netscaler_useSSL: 'False'
      }

enableserver {{ server }}:
  module.run:
    - name: netscaler.server_enable
    - s_name: {{ server }}
    - connection_args: {
        netscaler_host: {{ pillar['lb'] }},
        netscaler_user: {{ pillar['lbaccount'] }},
        netscaler_pass: {{ pillar['password'] }},
        netscaler_useSSL: 'False'
      }


bindservertosg {{ server }}:
  module.run:
    - name: netscaler.servicegroup_server_add
    - sg_name: {{ sg }}
    - s_name: {{ server }}
    - s_port: {{ serverport }}
    - s_id: {{ sid }}
    - connection_args: {
        netscaler_host: {{ pillar['lb'] }},
        netscaler_user: {{ pillar['lbaccount'] }},
        netscaler_pass: {{ pillar['password'] }},
        netscaler_useSSL: 'False'
      }

servicegroup_server_enable {{ server }}:
  module.run:
    - name: netscaler.servicegroup_server_enable
    - sg_name: {{ sg }}
    - s_name: {{ server }}
    - s_port: {{ serverport }}
    - s_id: {{ sid }}
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
