{% import "./Connectionvars.sls" as base %}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}

{% set clusterserversIP = salt['cmdb_lib3.getClusterServerIP'](base.connect,pillar['ClusterName']) %}

{% set datacenter = pillar['datacenter'] %}
{% set environment = pillar['environment'] %}
{% set clustername = pillar['ClusterName'] %}
{% set packagename = pillar['packageName'] %}
{% set role = pillar['clusterrole'] %}
{% set lbaccount = salt['cmdb_lib3.getLBAccountName'](base.connect,pillar['datacenter']) %}
{% set lb = salt['cmdb_lib3.getlb'](base.connect,pillar['datacenter'],pillar['environment']) %}
{% set lbpassword = salt['cmdb_lib3.getresource'](base.connect,salt['cmdb_lib3.getLBResourceName'](base.connect,pillar['datacenter']),salt['cmdb_lib3.getLBAccountName'](base.connect,pillar['datacenter'])) %}

{% for i in range(0,clusterservers|length) %}

addservertolb {{ clusterservers[i] }}:
  salt.runner:
    - name: state.orch
    - mods: cluster/Common/lb/addservertolb
    - pillar:
        clustername: {{ clustername }}
        packagename: {{ packagename }}
        role: {{ role }}
        ip: {{ clusterserversIP[i] }}
        server: {{ clusterservers[i] }}
        datacenter: {{ datacenter }}
        environment: {{ environment }}
        lb: '{{ lb }}'
        lbaccount: {{ lbaccount }}
        password: "{{ lbpassword }}"
    - retry:
        attempts: 3
        until: True
        interval: 45
        splay: 10

{% endfor %}
