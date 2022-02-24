{% import "./Connectionvars.sls" as base %}

{% set vmName = salt['pillar.get']('server') %}

{#% set addgrain = 'salt '~ vmName ~' grains.setval UDA_Cluster '~ salt['pillar.get']('ClusterName') ~'' %#}

{#% set custom = salt.cmd.run(addgrain) %#}

{% set Domain = salt['cmdb_lib3.domain'](base.connect,salt['pillar.get']('datacenter')) %}

{% set InstanceUuid = salt.cmd.run('salt-cloud -a get_InstanceUuid '~ vmName ~' -y').splitlines() | last |trim %}

{% set powerstate = salt.cmd.run('salt-cloud -a get_powerState '~ vmName ~' -y').splitlines() | last |trim %}

{#% set vmIP = salt.cmd.run('salt '~ vmName ~' grains.item fqdn_ip4').splitlines() | last | replace("-", "") | trim%#}

{% set systemOS = salt.cmd.run('salt '~ vmName ~' grains.item osfinger').splitlines() | last | trim%}

{#% set getfqdn = salt.cmd.run('salt '~ vmName ~' grains.item fqdn').splitlines() | last | trim %#}

{#% set result = salt['cmdb_lib3.addVMinfo'](base.connect,vmName,vmIP,uuid,systemOS,clusterrole,environment,clusterName) %#}


Add VM Information into CMDB:
  module.run:
    - name: cmdb_lib3.UpdateVMdata
    - connect: {{ base.connect }}
    - vmName: {{ vmName }}
    - uuid: {{ InstanceUuid }}
    - os: {{ systemOS }}
    - fqdn: "{{ vmName }}.{{ Domain }}"
    - ClusterName: {{ salt['pillar.get']('ClusterName') }}
    - PowerState: {{ powerstate }}
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10
