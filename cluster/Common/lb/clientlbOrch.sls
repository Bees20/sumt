{% import "./Connectionvars.sls" as base %}
{% set clustername = pillar['ClusterName'] %}
{% set packagename = pillar['packageName'] %}
{% set role = pillar['clusterrole'] %}
{% if salt['cmdb_lib3.isLoadBalanced'](base.connect,'CLIENT',packagename,role) %}
{% set dictdata = salt['cmdb_lib3.dictinfo'](base.connect,clustername,packagename) %}
{% set lbaccount = salt['cmdb_lib3.getLBAccountName'](base.connect,dictdata['datacenter']) %}
{% set lb = salt['cmdb_lib3.getlb'](base.connect,dictdata['datacenter'],dictdata['environment']) %}
{% set lbpassword = salt['cmdb_lib3.getresource'](base.connect,salt['cmdb_lib3.getLBResourceName'](base.connect,dictdata['datacenter']),salt['cmdb_lib3.getLBAccountName'](base.connect,dictdata['datacenter'])) %}

addlbmon:
  salt.runner:
    - name: state.orch
    - mods: cluster/Common/lb/addlbmonitor
    - pillar:
        role: {{ dictdata['clusterRole'] }}
        clusterversion: "{{ dictdata['clusterVersion'] }}"
        response: {{ dictdata['healthCheckResponse'] }}
        request: {{ dictdata['healthCheckRequest'] }}
        datacenter: {{ dictdata['datacenter'] }}
        environment: {{ dictdata['environment'] }}
        lb: '{{ lb }}'
        lbaccount: {{ lbaccount }}
        password: "{{ lbpassword }}"
    - retry:
        attempts: 3
        until: True
        interval: 45
        splay: 10

addpatset:
  salt.runner:
    - name: state.orch
    - mods: cluster/Common/lb/addpatset
    - pillar:
        patset: {{ dictdata['patSetName'] }}
        datacenter: {{ dictdata['datacenter'] }}
        environment: {{ dictdata['environment'] }}
        lb: '{{ lb }}'
        lbaccount: {{ lbaccount }}
        password: "{{ lbpassword }}"
    - retry:
        attempts: 3
        until: True
        interval: 45
        splay: 10

addlbvserver:
  salt.runner:
    - name: state.orch
    - mods: cluster/Common/lb/addlbvserver
    - pillar:
        cluster: {{ clustername }}
        port: "{{ dictdata['serverPort'] }}"
        persistence: {{ dictdata['persistence'] }}
        backupvs: {{ dictdata['lbMaintainanceServer'] }}
        lbmethod: {{ dictdata['loadDistMethod'] }}
        datacenter: {{ dictdata['datacenter'] }}
        environment: {{ dictdata['environment'] }}
        lb: '{{ lb }}'
        lbaccount: {{ lbaccount }}
        password: "{{ lbpassword }}"
    - retry:
        attempts: 3
        until: True
        interval: 45
        splay: 10

{% if role == 'URW' %}
addservicegroup:
  salt.runner:
    - name: state.orch
    - mods: cluster/Common/lb/addsg
    - pillar:
        role: {{ dictdata['clusterRole'] }}
        cluster: {{ clustername }}
        port: "{{ dictdata['serverPort'] }}"
        datacenter: {{ dictdata['datacenter'] }}
        environment: {{ dictdata['environment'] }}
        lb: '{{ lb }}'
        lbaccount: {{ lbaccount }}
        password: "{{ lbpassword }}"
    - retry:
        attempts: 3
        until: True
        interval: 45
        splay: 10

setlbvsforurw:
  salt.runner:
    - name: state.orch
    - mods: cluster/Common/lb/setlbvserver
    - pillar:
        cluster: {{ clustername }}
        datacenter: {{ dictdata['datacenter'] }}
        environment: {{ dictdata['environment'] }}
        lb: '{{ lb }}'
        lbaccount: {{ lbaccount }}
        password: "{{ lbpassword }}"
    - retry:
        attempts: 3
        until: True
        interval: 45
        splay: 10

{% else %}

addservicegroup:
  salt.runner:
    - name: state.orch
    - mods: cluster/Common/lb/addsg
    - pillar:
        role: {{ dictdata['clusterRole'] }}
        cluster: {{ clustername }}
        port: "{{ dictdata['serverPort'] }}"
        datacenter: {{ dictdata['datacenter'] }}
        environment: {{ dictdata['environment'] }}
        lb: '{{ lb }}'
        lbaccount: {{ lbaccount }}
        password: "{{ lbpassword }}"
    - retry:
        attempts: 3
        until: True
        interval: 45
        splay: 10
{% endif %}

addcspolicy:
  salt.runner:
    - name: state.orch
    - mods: cluster/Common/lb/addcspolicy
    - pillar:
        cluster: {{ clustername }}
        role: {{ role }}
        patset: {{ dictdata['patSetName'] }}
        datacenter: {{ dictdata['datacenter'] }}
        environment: {{ dictdata['environment'] }}
        lb: '{{ lb }}'
        lbaccount: {{ lbaccount }}
        password: "{{ lbpassword }}"
    - retry:
        attempts: 3
        until: True
        interval: 45
        splay: 10

bindsgtolbvs:
  salt.runner:
    - name: state.orch
    - mods: cluster/Common/lb/bindlbvstosg
    - pillar:
        cluster: {{ clustername }}
        port: "{{ dictdata['serverPort'] }}"
        datacenter: {{ dictdata['datacenter'] }}
        environment: {{ dictdata['environment'] }}
        lb: '{{ lb }}'
        lbaccount: {{ lbaccount }}
        password: "{{ lbpassword }}"
    - retry:
        attempts: 3
        until: True
        interval: 45
        splay: 10

bindsglbmon:
  salt.runner:
    - name: state.orch
    - mods: cluster/Common/lb/bindsgtomonitor
    - pillar:
        cluster: {{ clustername }}
        role: {{ dictdata['clusterRole'] }}
        clusterversion: "{{ dictdata['clusterVersion'] }}"
        port: "{{ dictdata['serverPort'] }}"
        datacenter: {{ dictdata['datacenter'] }}
        environment: {{ dictdata['environment'] }}
        lb: '{{ lb }}'
        lbaccount: {{ lbaccount }}
        password: "{{ lbpassword }}"
    - retry:
        attempts: 3
        until: True
        interval: 45
        splay: 10

bindcsvslbvstopol:
  salt.runner:
    - name: state.orch
    - mods: cluster/Common/lb/bindcsvslbvstopolicy
    - pillar:
        cluster: {{ clustername }}
        role: {{ dictdata['clusterRole'] }}
        publiccsname: {{ dictdata['publicCsName'] }}
        clusternum: "{{ dictdata['clusterNum'] }}"
        port: "{{ dictdata['serverPort'] }}"
        datacenter: {{ dictdata['datacenter'] }}
        environment: {{ dictdata['environment'] }}
        lb: '{{ lb }}'
        lbaccount: {{ lbaccount }}
        password: "{{ lbpassword }}"
    - retry:
        attempts: 3
        until: True
        interval: 45
        splay: 10
{% else %}

Validated:
  test.succeed_without_changes

{% endif %}
