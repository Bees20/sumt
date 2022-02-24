{% import "./Connectionvars.sls" as base %}

{% set udaPackage = salt['pillar.get']('packageName') %}

{% set Cluster = pillar['ClusterName'] %}

{% set podClusterCode = salt['pillar.get']('podClusterCode', 'null') %}

{% set IS_DEDICATED = salt['pillar.get']('IS_DEDICATED', '0') %}

{% set IS_VALIDATED = salt['pillar.get']('IS_VALIDATED', 'none') %}

{% set associateClusterName = salt['pillar.get']('associateClusterName', '') %}


Add Cluster Information in CMDB:
  module.run:
    - name: cmdb_lib3.addClusterinfo
    - connect: {{ base.connect }}
    - clusterName: {{ Cluster }}
    - associateClusterName: "{{ associateClusterName }}"
    - isDedicated: "{{ IS_DEDICATED }}"
    - isValidated: "{{ IS_VALIDATED }}"
    - podClusterCode: "{{ podClusterCode }}"
    - udaPackage: {{ udaPackage }}


{% if salt['cmdb_lib3.ClusterServerExists'](base.connect,pillar['ClusterName']) %}

{% import "./buildClusterserverList.sls" as input %}

{% for i in range(0,input.ClusterServers|length) %}



Add VM Information into CMDB {{ input.ClusterServers[i] }}:
  module.run:
    - name: cmdb_lib3.addVMinfo
    - connect: {{ base.connect }}
    - vmName: {{ input.ClusterServers[i] }}
    - vmIP: {{ input.iplist[i]["ipaddress"] }}
    - uuid: {{ input.ClusterServers[i] }}
    - os: {{ input.iplist[i]["Port_Group"] }}
    - clusterrole: {{ salt['pillar.get']('clusterrole') }}
    - Environment: {{ salt['pillar.get']('environment') }}
    - ClusterName: {{ salt['pillar.get']('ClusterName') }}
    - fqdn: "NULL"


{% endfor %}
{% else %}

Validated:
  test.succeed_without_changes

{% endif %}
