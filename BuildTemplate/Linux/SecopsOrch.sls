{% import "./Connectionvars.sls" as base %}

{% set instances = salt['cmdb_lib3.getRoleTemplateNamev1'](base.connect,pillar['datacenter'],pillar['clusterroles'],pillar['packageName']) %}

{% for key in instances %}

{% set Roleversion = salt['cmdb_lib3.getRoleversion'](base.connect,pillar['packageName'],key['role']) %}

Apply SecOps policies {{ key['instance'] }}:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Linux/ApplySecops
    - pillar:
        name: {{ key['instance'] }}
        packageName: {{ pillar['packageName'] }}
        role: {{ key['role'] }}
        Roleversion: {{ Roleversion }}
        datacenter: {{ pillar['datacenter'] }}
    - parallel: True
    - retry:
        attempts: 3
        until: True
        interval: 45
        splay: 10

Wait for Policy {{ key['instance'] }}:
  module.run:
    - name: test.sleep
    - length: 10

Remove IP from WhiteList {{ key['instance'] }}:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Common/RemoveIpfromWhitelistOrch
    - pillar: {{ dict(pillar) | json }}
    - onfail:
        - Apply SecOps policies {{ key['instance'] }}

{% endfor %}
