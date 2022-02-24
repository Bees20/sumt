{% import "./Connectionvars.sls" as base %}

{% set instances = salt['cmdb_lib3.getRoleTemplateNamev1'](base.connect,pillar['datacenter'],pillar['clusterroles'],pillar['packageName']) %}

{% for value in instances %}


Run Secops Assessment {{ value['instance'] }}:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Linux/sec_reAssess
    - pillar:
        policy_name: {{ value['instance'] }}
        datacenter: {{ pillar['datacenter'] }}
    - parallel: True


Wait for Policy {{ value['instance'] }}:
  module.run:
    - name: test.sleep
    - length: 10

Remove IP from WhiteList {{ value['instance'] }}:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Common/RemoveIpfromWhitelistOrch
    - pillar: {{ dict(pillar) | json }}
    - onfail:
        - Run Secops Assessment {{ value['instance'] }}

{% endfor %}
