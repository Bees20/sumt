{% import "./Connectionvars.sls" as base %}

{% for role in pillar['clusterroles'] %}

{% set esxCluster = salt['cmdb_lib3.getesxClusterName'](base.connect,pillar['datacenter'],pillar['environment'],role) %}

{% set Roleversion = salt['cmdb_lib3.getRoleversion'](base.connect,pillar['packageName'],role) %}

{% set instance = salt['cmdb_lib3.getRoleTemplateName'](base.connect,pillar['datacenter'],role,Roleversion,pillar['packageName']) %}

{% set Diskmap = salt['cmdb_lib3.get_Drivemap'](base.connect,pillar['datacenter'],pillar['environment'],role,pillar['packageName'],esxCluster) %}

{% for data in Diskmap %}

disk map {{ data['DRIVE_LETTER'] }} on {{ instance }}:
  salt.state:
    - sls:
      - BuildTemplate/windows/diskMap
    - tgt: {{ instance }}
    - pillar:
        driveletter: "{{ data['DRIVE_LETTER'] }}"
        drivelabel: "{{ data['DRIVE_LABEL'] }}"
        drivenum: "{{ data['DRIVE_NUMBER'] }}"
        clusterrole: "{{ role }}"

{% endfor %}

{% endfor %}
