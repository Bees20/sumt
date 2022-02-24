{% import "./Connectionvars.sls" as base %}

{% set lb = salt['cmdb_lib3.getlb'](base.connect,pillar['datacenter'],pillar['environment']) %}

{% set lbaccount = salt['cmdb_lib3.getLBAccountName'](base.connect,pillar['datacenter']) %}

{% set lbpassword = salt['cmdb_lib3.getresource'](base.connect,salt['cmdb_lib3.getLBResourceName'](base.connect,pillar['datacenter']),salt['cmdb_lib3.getLBAccountName'](base.connect,pillar['datacenter'])) %}

{% set args = {"netscaler_host": lb,"netscaler_user": lbaccount,"netscaler_pass": lbpassword,"netscaler_useSSL": "False"} %}

{% for role in pillar['clusterroles'] %}

{% if salt['cmdb_lib3.setlock'](base.connect,'buildclusterserverlist','5') %}

{% set vars = salt['cmdb_lib3.getInstancevars'](base.connect,pillar['packageName'],role,pillar['datacenter'],pillar['environment'],pillar['domainuser'],numOfServers='1',**args) %}

{% endif %}

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
    - servername: {{ vars['instance'] }}
    - ipaddr: "{{  vars['retriveIP']['ipaddress']  }}"
    - test: True
{% else %}

{% set target = salt['cmdb_lib3.getConfigValueByKey'](base.connect,pillar['datacenter'],'CO_OUTBOUND_WHITELIST_SERVER') %}
{% set whitelistPath = salt['cmdb_lib3.getConfigValueByKey'](base.connect,pillar['datacenter'],'CO_OUTBOUND_WHITELIST_PATH') %}
{% set whitelistbackupPath = salt['cmdb_lib3.getConfigValueByKey'](base.connect,pillar['datacenter'],'CO_OUTBOUND_WHITELIST_BACKUPPATH') %}

Backup IP {{  vars['retriveIP']['ipaddress']  }} to whitelist:
  salt.state:
    - tgt: {{ target }}
    - sls:
      - BuildTemplate.Common.BackupIpWhitelist
    - pillar:
        IP: {{  vars['retriveIP']['ipaddress']  }}
        whitelistPath: {{ whitelistPath }}
        whitelistbackupPath: {{ whitelistbackupPath }}
    - retry:
        attempts: 3
    - queue: True

Add IP {{  vars['retriveIP']['ipaddress']  }} to whitelist:
  salt.state:
    - tgt: {{ target }}
    - sls:
      - BuildTemplate.Common.AddIptoWhitelist
    - pillar:
        IP: {{  vars['retriveIP']['ipaddress']  }}
        whitelistPath: {{ whitelistPath }}
        whitelistbackupPath: {{ whitelistbackupPath }}
    - retry:
        attempts: 2
    - queue: True

Wait for 5 min:
  module.run:
    - name: test.sleep
    - length: 300

{% endif %}

deletelocking {{ vars['instance'] }}:
  module.run:
    - name: cmdb_lib3.deletelock
    - lockname: 'buildclusterserverlist'
    - connect: {{ base.connect }}

Create instance {{ vars['instance'] }}:
  salt.runner:
    - name: cloud.create
    - provider: vmware
    - clonefrom: {{ vars['baseTemplate'] }}
    - instances:
      - {{ vars['instance'] }}
    - cluster: {{ vars['esxCluster'] }}
    - memory: {{ vars['vmSize'][0] }}MB
    - num_cpus: {{ vars['vmSize'][1] }}
    - customization: True
    - datastore: {{ vars['Datastore'] }}
    - devices:
        network:
          Network adapter 1:
            switch_type: distributed
            dvs_switch: {{ vars['Networkadapter']['DVS_SWITCH'] }}
            name: {{ vars['retriveIP']['Port_Group'] }}
            ip: {{  vars['retriveIP']['ipaddress']  }}
            gateway: {{ vars['Networkadapter']['DEFAULT_GATEWAY'] }}
            subnet_mask: {{ vars['Networkadapter']['SUBNET'] }}
            domain: {{ vars['Domain'] }}
    - domain: {{ vars['Domain'] }}
    - dns_servers:
      - {{ vars['Nameservers'][0] }}
      - {{ vars['Nameservers'][1] }}
    - folder: inf/Salt Templates
    - power_on: True
    - tmp_dir: /var
    - ssh_username: {{ salt['pillar.get']('domainuser') }}
    - password: {{ vars['domainpasswd'] }}
    - sudo_password: {{ vars['domainpasswd'] }}
    - script_args: -l -r -R {{ vars['repoServer'] }}
    - plain_text: True
    - annotation: Provisioned by Salt-Cloud using {{ vars['baseTemplate'] }}
    - deploy: True
    - wait_for_ip_timeout: 2000
    - minion:
        master:
          - {{ vars['SaltMasters'][0] }}
          - {{ vars['SaltMasters'][1] }}
    - failhard: True
    - parallel: True

Wait for MAC {{ vars['instance'] }}:
  module.run:
    - name: test.sleep
    - length: 15

{% endfor %}
