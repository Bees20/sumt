{% import "./Connectionvars.sls" as base %}

{% set instances = salt['cmdb_lib3.getRoleTemplateNamev1'](base.connect,pillar['datacenter'],pillar['clusterroles'],pillar['packageName']) %}

{% set repoServer = salt['cmdb_lib3.getRepoServer'](base.connect,salt['pillar.get']('datacenter')) %}

{% for value in instances %}

Create Local Repo {{ value['instance'] }}:
  salt.state:
    - sls:
      - BuildTemplate/Linux/createLocalRepo
    - tgt: {{ value['instance'] }}
    - pillar:
        repoServer: {{ repoServer }}
    - parallel: True

{% endfor %}

