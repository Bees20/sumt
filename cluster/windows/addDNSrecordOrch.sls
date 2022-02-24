{% import "./Connectionvars.sls" as base %}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}

{% set clusterserversIP = salt['cmdb_lib3.getClusterServerIP'](base.connect,pillar['ClusterName']) %}

{% set Domain = salt['cmdb_lib3.domain'](base.connect,pillar['datacenter']) %}

{% set Nameservers = salt['cmdb_lib3.getNameservers'](base.connect,pillar['datacenter']) %}


{% for i in range(0,clusterservers|length) %}

add DNS Record {{ clusterservers[i] }}:
  ddns.present:
    - name: {{ clusterservers[i] }}
    - zone: {{ Domain }}
    - ttl: 3600
    - data: {{ clusterserversIP[i] }}
    - nameserver: {{ Nameservers[0] }}
    - rdtype: 'A'
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10

{% endfor %}
