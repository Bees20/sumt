{% import "./Connectionvars.sls" as base %}

{% set instances = salt['cmdb_lib3.getRoleTemplateNamev1'](base.connect,pillar['datacenter'],pillar['clusterroles'],pillar['packageName']) %}

{% set repoServer = salt['cmdb_lib3.getRepoServer'](base.connect,salt['pillar.get']('datacenter')) %}

{% set suiteversion = pillar['packageName'].split('-')[0]| regex_replace('\\.|\\-', '') %}

{% for value in instances %}

Install Role Prerequisites {{ value['instance'] }}:
  salt.runner:
    - name: state.orch
    - mods: {{ suiteversion }}/{{ value['role'] }}/Workflow/orch
    - pillar:
        VERSION: {{ pillar['packageName'] }}
        WORKFLOW: "PROVISION"
        SERVER: {{ value['instance'] }}
        repoServer: {{ repoServer }}
        ROLE: {{ value['role'] }}
        DICT: {{ salt['cmdb_lib3.getprerequisiteurls'](base.connect,pillar['packageName'],value['role'],pillar['datacenter'],salt['pillar.get']('sqlaccount'),salt['pillar.get']('domainuser')) | json }}
    - parallel: True


Remove IP from WhiteList {{ value['instance'] }}:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Common/RemoveIpfromWhitelistOrch
    - pillar: {{ dict(pillar) | json }}
    - onfail:
        - Install Role Prerequisites {{ value['instance'] }}

{% endfor %}

