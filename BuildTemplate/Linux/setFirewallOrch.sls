{% import "./Connectionvars.sls" as base %}

{% set instances = salt['cmdb_lib3.getRoleTemplateNamev1'](base.connect,pillar['datacenter'],pillar['clusterroles'],pillar['packageName']) %}

{% for value in instances %}

Set Firewalld {{ value['instance'] }}:
  salt.state:
    - sls:
      - BuildTemplate/Linux/setFirewalld
    - tgt: {{ value['instance'] }}
    - parallel: True


Remove IP from WhiteList {{ value['instance'] }}:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Common/RemoveIpfromWhitelistOrch
    - pillar: {{ dict(pillar) | json }}
    - onfail:
        - Set Firewalld {{ value['instance'] }}

{% endfor %}
