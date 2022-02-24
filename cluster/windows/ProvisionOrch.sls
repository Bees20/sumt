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
    - plain_text: True
    - annotation: Provisioned by Salt-Cloud using {{ data.baseTemplate }}
    - deploy: True
    - wait_for_ip_timeout: 2000
    - minion:
        master:
          - {{ data.SaltMasters[0] }}
          - {{ data.SaltMasters[1] }}
    - win_username: {{ salt['cmdb_lib3.getWindowsAccountName'](base.connect,pillar['datacenter']) }}
    - win_password: '{{ data.adminpwd }}'
    - win_organization_name: sumtotal
    - win_autologon: True
    - plain_text: True
    - win_installer: /srv/salt/win/repo-ng/Salt-Minion-3003.1-Py3-AMD64-Setup.exe
    - win_run_once: cmd /c netsh advfirewall set allprofiles state off
    - failhard: True
    - parallel: True

Wait for MAC {{ clusterservers[i] }}:
  module.run:
    - name: test.sleep
    - length: 20
{% endfor %}
