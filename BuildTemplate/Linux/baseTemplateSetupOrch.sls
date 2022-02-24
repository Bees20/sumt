{% import "./Connectionvars.sls" as base %}

{% set saltpass = salt['cmdb_lib3.getresource'](base.connect,salt['pillar.get']('domainuser'),salt['pillar.get']('domainuser')) %}
{% set rootpass = salt['cmdb_lib3.getresource'](base.connect,'vRATemplate',salt['pillar.get']('user')) %}
{% set repoServer = salt['cmdb_lib3.getRepoServer'](base.connect,salt['pillar.get']('datacenter')) %}
{% set Domain = salt['cmdb_lib3.domain'](base.connect,pillar['datacenter']) %}
{% set instances = salt['cmdb_lib3.getRoleTemplateNamev1'](base.connect,pillar['datacenter'],pillar['clusterroles'],pillar['packageName']) %}


{% for value in instances %}

Run Base Template setup  {{ value['instance'] }}:
  salt.state:
    - tgt: {{ value['instance'] }}
    - sls:
      - BuildTemplate/Linux/baseTemplateSetup
    - parallel: True
    - pillar:
        Domain: {{ Domain }}
        saltpass: {{ saltpass }}
        rootpass: {{ rootpass }}
        repoServer: {{ repoServer }}

Remove IP from WhiteList {{ value['instance'] }}:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Common/RemoveIpfromWhitelistOrch
    - pillar: {{ dict(pillar) | json }}
    - onfail:
        - Run Base Template setup  {{ value['instance'] }}

{% endfor %}


