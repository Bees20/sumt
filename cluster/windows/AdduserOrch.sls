{% import "./Connectionvars.sls" as base %}

{% set role =  pillar['clusterrole'] %}

{% set applicationGroups = salt['cmdb_lib3.getConfigValueByKey'](base.connect,pillar['datacenter'],'CO_WINDOWSAPPLICATIONGROUPS') %}

{% set sqlInstaller = salt['cmdb_lib3.getConfigValueByKey'](base.connect,pillar['datacenter'],'CO_SQLSERVERINSTALLERUSER') %}

{% set dbaGroup = salt['cmdb_lib3.getConfigValueByKey'](base.connect,pillar['datacenter'],'CO_SQLSERVERDBAGROUPS') %}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}

{% if role == 'UUW' or role == 'URW' or role == 'UWD' or role == 'UTA' %}

{% set clusterArray = pillar['ClusterName'].split('-') %}

{% set svcuser = ['svc_',pillar['datacenter'],pillar['environment'][0],pillar['clusterrole'],clusterArray[4][1:5]] | join | lower %}

{% set passwd =  salt['cmdb_lib3.getresource'](base.connect,pillar['ClusterName'],svcuser) %} 

{% set utliserver = salt['cmdb_lib3.getdata'](base.connect,"VRO_UTILITY_SERVER",pillar['datacenter']) %}

{% set Domain = salt['cmdb_lib3.domain'](base.connect,pillar['datacenter']) %}

{% set domainpasswd = salt['cmdb_lib3.getresource'](base.connect,salt['pillar.get']('domainuser'),salt['pillar.get']('domainuser')) %}

{% set vropasswd = salt['cmdb_lib3.getresource'](base.connect,salt['pillar.get']('vrouser'),salt['pillar.get']('vrouser')) %}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}

{% set svcAccountOU = salt['cmdb_lib3.getSvcAccountOU'](base.connect,pillar['datacenter']) %}

Add domain user:
  salt.state:
    - sls:
      - cluster/windows/adduser
    - tgt: {{ utliserver }}
    - pillar:
        domainuser: {{ salt['pillar.get']('vrouser') }}
        domainpwd: "{{ vropasswd }}"
        domain: {{ Domain }}
        username: {{ svcuser }}
        password: "{{ passwd }}"
        svcOU: "{{ svcAccountOU }}"
    - retry:
        attempts: 2
        until: True
        interval: 60
        splay: 10
    - queue: True

Wait for AD:
  module.run:
    - name: test.sleep
    - length: 60

{% for server in clusterservers %}

Add a user in the group {{ server }}:
  salt.state:
    - sls:
      - cluster/windows/addusertoGroup
    - tgt: {{ server }}
    - pillar:
        domain: {{ Domain }}
        svcuser: {{ svcuser }}
        domainuser: {{ salt['pillar.get']('domainuser') }}
    - require:
      - salt: Add domain user
    - queue: True
{% endfor %}

{% else %}

Validated:
  test.succeed_without_changes

{% endif %}



{% for server in clusterservers %}

Add a Groups to Administrator group {{ server }}:
  salt.state:
    - sls:
      - cluster/windows/addGroups
    - tgt: {{ server }}
    - pillar:
        role: {{ role }}
        applicationGroups: {{ applicationGroups }}
        sqlInstaller: {{ sqlInstaller }}
        dbaGroup: {{ dbaGroup }}
    - queue: True
{% endfor %}



{#
{% if role == 'UUD' or role == 'URD' or role == 'UWD' or role == 'UTD' or role == 'UDD' %}

{% set sqlInstaller = salt['cmdb_lib3.getConfigValueByKey'](pillar['datacenter'],'CO_SQLSERVERINSTALLERUSER') %}
{% set dbaGroup = salt['cmdb_lib3.getConfigValueByKey'](pillar['datacenter'],'CO_SQLSERVERDBAGROUPS') %}

{% for server in clusterservers %}

Add groups to Administrator group {{ server }}:
  salt.state:
    - sls:
      - cluster/windows/addusertoGroup
    - tgt: {{ server }}
    - pillar:
        domain: {{ Domain }}
        svcuser: {{ svcuser }}
        domainuser: {{ salt['pillar.get']('domainuser') }}
        applicationGroups: "{{ applicationGroups }}"
        sqlInstaller: "{{ sqlInstaller }}"
        dbaGroup: "{{ dbaGroup }}"
    - queue: True
{% endfor %}

{% else %}

Validated:
  test.succeed_without_changes

{% endif %}
#}
