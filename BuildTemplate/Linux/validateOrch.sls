{% import "./Connectionvars.sls" as base %}

{% set instances = salt['cmdb_lib3.getRoleTemplateNamev1'](base.connect,pillar['datacenter'],pillar['clusterroles'],pillar['packageName']) %}

{% for value in instances %}

Validate Python version {{ value['instance'] }}:
  salt.state:
    - tgt: {{ value['instance'] }}
    - sls:
      - BuildTemplate/Linux/validate

Remove IP from WhiteList {{ value['instance'] }}:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Common/RemoveIpfromWhitelistOrch
    - pillar: {{ dict(pillar) | json }}
    - onfail:
        - Validate Python version {{ value['instance'] }}

{% endfor %}
