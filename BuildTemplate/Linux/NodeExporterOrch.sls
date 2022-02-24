{% import "./Connectionvars.sls" as base %}

{% set instances = salt['cmdb_lib3.getRoleTemplateNamev1'](base.connect,pillar['datacenter'],pillar['clusterroles'],pillar['packageName']) %}

{% set repoServer = salt['cmdb_lib3.getRepoServer'](base.connect,salt['pillar.get']('datacenter')) %}

{% for value in instances %}

Node_exporter {{ value['instance'] }}:
  salt.state:
    - sls:
      - BuildTemplate/Linux/Install_nodeExporter
    - tgt: {{ value['instance'] }}
    - pillar:
        repoServer: {{ repoServer }}
    - parallel: True

Remove IP from WhiteList {{ value['instance'] }}:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Common/RemoveIpfromWhitelistOrch
    - pillar: {{ dict(pillar) | json }}
    - onfail:
        - Node_exporter {{ value['instance'] }}

{% endfor %}

