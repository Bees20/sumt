{% import "./Connectionvars.sls" as base %}

{% set instances = salt['cmdb_lib3.getRoleTemplateNamev1'](base.connect,pillar['datacenter'],pillar['clusterroles'],pillar['packageName']) %}

{#  
Update patches:
  salt.state:
    - sls:
      - BuildTemplate/Linux/patches
    - tgt: [{% for value in instances %}{{ [value['instance'],',']|join }}{% endfor %}]
    - tgt_type: list
#}

{# Remove Below code once everyting is offline and uncomment the above code #}

{% for value in instances %}


Update patches {{ value['instance'] }}:
  salt.state:
    - sls:
      - BuildTemplate/Linux/patches
    - tgt: {{ value['instance'] }}

Remove IP from WhiteList {{ value['instance'] }}:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Common/RemoveIpfromWhitelistOrch
    - pillar: {{ dict(pillar) | json }}
    - onfail:
        - Update patches {{ value['instance'] }}

{% endfor %}
