{% import "./Connectionvars.sls" as base %}

{#% if salt['cmdb_lib3.ClusterServerExists'](base.connect,pillar['ClusterName']) %#}

{% import "./defaultValues.sls" as data %}

{#% import "./buildClusterserverList.sls" as input %#}

{#% for i in range(0,input.ClusterServers|length) %#}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}

{% set clusterserversIP = salt['cmdb_lib3.getClusterServerIP'](base.connect,pillar['ClusterName']) %}

{% for i in range(0,clusterservers|length) %}

{% set VLANname = salt['cmdb_lib3.getVLAN'](base.connect,clusterserversIP[i]) %}

{% set gateway = salt['cmdb_lib3.gateway'](base.connect,VLANname) %}

{% set switch = salt['cmdb_lib3.getDVS_switch'](base.connect,VLANname) %}

{% set subnet_mask = salt['cmdb_lib3.subnet_mask'](base.connect,VLANname) %}

{% if pillar['datacenter'] == 'AMS' %}

   {% set username = salt['cmdb_lib3.getLBAccountName'](base.connect,pillar['datacenter']) %}

   {% set password = salt['cmdb_lib3.getresource'](base.connect,salt['cmdb_lib3.getLBResourceName'](base.connect,pillar['datacenter']),salt['cmdb_lib3.getLBAccountName'](base.connect,pillar['datacenter'])) %}

  {% if pillar['environment'] == 'PROD' %}

    {% set vdom = "PROD-INET" %}

  {% else %}

     {% set vdom = "STAGE-INET" %}

  {% endif %}

{% set vdomfirewall = salt['cmdb_lib3.getvdomandfirewall'](base.connect,pillar['datacenter']) %}

Adding IP to whitelist for {{ pillar['datacenter'] }}:
  module.run:
    - name: SaltCommon.AddServertoWhiteList
    - vdom: {{ vdom }}
    - username: "{{ username }}"
    - password: "{{ password }}"
    - firewall: "{{ vdomfirewall[0][1] }}"
    - servername: {{ clusterservers[i] }}
    - ipaddr: "{{ clusterserversIP[i] }}"
    - test: False
{% else %}

{% set target = salt['cmdb_lib3.getConfigValueByKey'](base.connect,pillar['datacenter'],'CO_OUTBOUND_WHITELIST_SERVER') %}
{% set whitelistPath = salt['cmdb_lib3.getConfigValueByKey'](base.connect,pillar['datacenter'],'CO_OUTBOUND_WHITELIST_PATH') %}
{% set whitelistbackupPath = salt['cmdb_lib3.getConfigValueByKey'](base.connect,pillar['datacenter'],'CO_OUTBOUND_WHITELIST_BACKUPPATH') %}

Backup IP {{ clusterserversIP[i] }} to whitelist:
  salt.state:
    - tgt: {{ target }}
    - sls:
      - cluster.Common.BackupIpWhitelist
    - pillar:
        IP: {{ clusterserversIP[i] }}
        whitelistPath: {{ whitelistPath }}
        whitelistbackupPath: {{ whitelistbackupPath }}
    - retry:
        attempts: 3
    - queue: True

Add IP {{ clusterserversIP[i] }} to whitelist:
  salt.state:
    - tgt: {{ target }}
    - sls:
      - cluster.Common.AddIptoWhitelist
    - pillar:
        IP: {{ clusterserversIP[i] }}
        whitelistPath: {{ whitelistPath }}
        whitelistbackupPath: {{ whitelistbackupPath }}
    - retry:
        attempts: 3
    - queue: True

Wait for 5 min {{ clusterserversIP[i] }}:
  module.run:
    - name: test.sleep
    - length: 300

{% endif %}

Create instance {{ clusterservers[i] }}:
  salt.runner:
    - name: cloud.create
    - provider: vmware
    - clonefrom: {{ data.baseTemplate }}
    - instances:
      - {{ clusterservers[i] }}
    - cluster: {{ data.esxCluster }}
    - memory: {{ data.vmSize[0] }}MB
    - num_cpus: {{ data.vmSize[1] }}
    - customization: True
    - datastore: {{ data.Datastore }}
    - devices:
        network:
          Network adapter 1:
            switch_type: distributed
            dvs_switch: {{ switch }}
            name: {{ VLANname }}
            ip: {{ clusterserversIP[i] }}
            gateway: {{ gateway }}
            subnet_mask: {{ subnet_mask }}
            domain: {{ data.Domain }}
    - domain: {{ data.Domain }}
    - dns_servers:
      - {{ data.Nameservers[0] }}
      - {{ data.Nameservers[1] }}
    - folder: {{ salt['pillar.get']('clusterrole') }}
    - power_on: True
    - tmp_dir: /var
    - ssh_username: {{ salt['pillar.get']('domainuser') }}
    - password: {{ data.domainpasswd }}
    - sudo_password: {{ data.domainpasswd }}
    - script_args: -l -r -R {{ data.repoServer }}
    - plain_text: True
    - annotation: Provisioned by Salt-Cloud using {{ data.baseTemplate }}
    - deploy: True
    - wait_for_ip_timeout: 2000
    - minion:
        master:
          - {{ data.SaltMasters[0] }}
          - {{ data.SaltMasters[1] }}
    - failhard: True
    - parallel: True

Wait for MAC {{ clusterservers[i] }}:
  module.run:
    - name: test.sleep
    - length: 20

{% endfor %}

{#
{% else %}

Validated:
  test.succeed_without_changes

{% endif %}
#}
