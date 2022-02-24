{% import "./Connectionvars.sls" as base %}


{% set domainpasswd = salt['cmdb_lib3.getresource'](base.connect,salt['pillar.get']('domainuser'),salt['pillar.get']('domainuser')) %}

{% set repoServer = salt['cmdb_lib3.getRepoServer'](base.connect,salt['pillar.get']('datacenter')) %}

{% set Domain = salt['cmdb_lib3.domain'](base.connect,pillar['datacenter']) %}

{% set instances = salt['cmdb_lib3.getRoleTemplateNamev1'](base.connect,pillar['datacenter'],pillar['clusterroles'],pillar['packageName']) %}

{% for value in instances %}

Remove {{ value['instance'] }} from Domain:
  salt.state:
    - tgt: {{ value['instance'] }}
    - sls:
      - BuildTemplate/Linux/LeaveDomain
    - parallel: True
    - pillar:
        Domain: {{ Domain }}
        domainpasswd: {{ domainpasswd }}
        domainuser: {{ salt['pillar.get']('domainuser') }}
        repoServer: {{ repoServer }}
{% endfor %}

