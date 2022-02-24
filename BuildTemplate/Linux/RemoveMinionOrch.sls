{% import "./Connectionvars.sls" as base %}


{% set domainpasswd = salt['cmdb_lib3.getresource'](base.connect,salt['pillar.get']('domainuser'),salt['pillar.get']('domainuser')) %}

{% set instances = salt['cmdb_lib3.getRoleTemplateNamev1'](base.connect,pillar['datacenter'],pillar['clusterroles'],pillar['packageName']) %}

{% for value in instances %}

{% set serverIP = salt.cmd.run('salt '~ value['instance'] ~' grains.item fqdn_ip4').splitlines() | last | replace("-", "") | trim%}


Remove Minion Configuration {{ value['instance'] }}:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Linux/removeminion
    - pillar:
        instance: {{ value['instance'] }}
        domainpasswd: {{ domainpasswd }}
    - parallel: True

{#
Remove Salt Minion on {{ value['instance'] }} has IP {{ serverIP }}:
  module.run:
    - name: SaltCommon.RemoveLinuxSaltMinion
    - ip: {{ serverIP }}
    - port: "22"
    - username: {{ salt['pillar.get']('domainuser') }}
    - password: {{ domainpasswd }}
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10

Remove Salt Minion on {{ value['instance'] }} with IP {{ serverIP }}:
  cmd.run:
    - name: {{ salt['SaltCommon.RemoveLinuxSaltMinion'](serverIP,'22',pillar['domainuser'],domainpasswd) }}
    - bg: True

#}
{% endfor %}

