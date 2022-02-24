{% import "./Connectionvars.sls" as base %}

{% set lb = salt['cmdb_lib3.getlb'](base.connect,pillar['datacenter'],pillar['environment']) %}

{% set lbaccount = salt['cmdb_lib3.getLBAccountName'](base.connect,pillar['datacenter']) %}

{% set lbpassword = salt['cmdb_lib3.getresource'](base.connect,salt['cmdb_lib3.getLBResourceName'](base.connect,pillar['datacenter']),salt['cmdb_lib3.getLBAccountName'](base.connect,pillar['datacenter'])) %}

{% set args = {"netscaler_host": lb,"netscaler_user": lbaccount,"netscaler_pass": lbpassword,"netscaler_useSSL": "False"} %}

{% for role in pillar['clusterroles'] %}

{% set Roleversion = salt['cmdb_lib3.getRoleversion'](base.connect,pillar['packageName'],role) %}

{% set esxCluster = salt['cmdb_lib3.getesxClusterName'](base.connect,pillar['datacenter'],pillar['environment'],role) %}

{% set Datastore = salt['cmdb_lib3.getRTdatastore'](base.connect,pillar['datacenter'],pillar['environment'],role,pillar['packageName'],esxCluster) %}

{% set winDrives = salt['cmdb_lib3.get_winDrive'](base.connect,pillar['datacenter'],pillar['environment'],role,pillar['packageName'],esxCluster) %}

{% set Networks = salt['cmdb_lib3.ipSublist'](base.connect,role,pillar['datacenter'],pillar['environment']) %}

{% set baseTemplate = salt['cmdb_lib3.getBaseTemplate'](base.connect,pillar['datacenter'],role,pillar['packageName']) %}

{% set vmSize = salt['cmdb_lib3.getMemory'](base.connect,pillar['packageName'],role) %}

{% if salt['cmdb_lib3.setlock'](base.connect,'buildclusterserverlist','5') %}

{% set retriveIP = salt['cmdb_lib3.getIP'](base.connect,Networks,pillar['datacenter'],numOfServers='1',**args)[0] %}

{% endif %}

{% set gateway = salt['cmdb_lib3.gateway'](base.connect,retriveIP["Port_Group"]) %}

{% set subnet_mask = salt['cmdb_lib3.subnet_mask'](base.connect,retriveIP["Port_Group"]) %}

{% set switch = salt['cmdb_lib3.getDVS_switch'](base.connect,retriveIP["Port_Group"]) %}

{% set instance = salt['cmdb_lib3.getRoleTemplateName'](base.connect,pillar['datacenter'],role,Roleversion,pillar['packageName']) %}


Create instance {{ instance }}:
  salt.runner:
    - name: cloud.create
    - provider: vmware
    - clonefrom: {{ baseTemplate }}
    - instances:
      - {{ instance }}
    - cluster: {{ esxCluster }}
    - memory: {{ vmSize[0] }}MB
    - num_cpus: {{ vmSize[1] }}
    - customization: True
    - datastore: {{ Datastore }}
    - devices:
        disk:
          {% for drive in winDrives %}
          {{ drive['DRIVE_LETTER'] }}:
            size: {{ drive['DRIVE_SIZE'] }}
            datastore: {{ drive['DATASTORE'] }}
            thin_provision: True
          {% endfor %}
        network:
          Network adapter 1:
            switch_type: distributed
            dvs_switch: {{ switch }}
            name: {{ retriveIP["Port_Group"] }}
            ip: {{ retriveIP["ipaddress"]  }}
            gateway: {{ gateway }}
            subnet_mask: {{ subnet_mask }}
            domain: {{ salt['cmdb_lib3.domain'](base.connect,pillar['datacenter']) }}
    - domain: {{ salt['cmdb_lib3.domain'](base.connect,pillar['datacenter']) }}
    - dns_servers:
      - {{ salt['cmdb_lib3.getNameservers'](base.connect,pillar['datacenter'])[0] }}
      - {{ salt['cmdb_lib3.getNameservers'](base.connect,pillar['datacenter'])[1] }}
    - folder: inf/Salt Templates
    - power_on: True
    - plain_text: True
    - annotation: Provisioned by Salt-Cloud using {{ baseTemplate }}
    - deploy: True
    - wait_for_ip_timeout: 2000
    - minion:
        master:
          - {{ salt['cmdb_lib3.getSaltMasters'](base.connect,pillar['datacenter'])[0] }}
          - {{ salt['cmdb_lib3.getSaltMasters'](base.connect,pillar['datacenter'])[1] }}
    - win_username: {{ salt['cmdb_lib3.getWindowsAccountName'](base.connect,pillar['datacenter']) }}
    - win_password: "{{salt['cmdb_lib3.getresource'](base.connect,salt['cmdb_lib3.getWindowsResourceName'](base.connect,pillar['datacenter']),salt['cmdb_lib3.getWindowsAccountName'](base.connect,pillar['datacenter']))}}"
    - win_organization_name: sumtotal
    - win_autologon: True
    - plain_text: True
    - parallel: True
    - win_installer: /srv/salt/win/repo-ng/Salt-Minion-3003.1-Py3-AMD64-Setup.exe
    - win_run_once: cmd /c netsh advfirewall set allprofiles state off

Wait for MAC {{ instance }}:
  module.run:
    - name: test.sleep
    - length: 20

{% endfor %}
