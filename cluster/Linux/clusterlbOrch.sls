{% import "./Connectionvars.sls" as base %}
{% set clustername = pillar['ClusterName'] %}
{% set packagename = pillar['packageName'] %}
{% set role = pillar['clusterrole'] %}
{% if salt['cmdb_lib3.isLoadBalanced'](base.connect,'CLUSTER',packagename,role) %}
{% set dictdata = salt['cmdb_lib3.dictinfo'](base.connect,clustername,packagename) %}
{% set subnet = salt['cmdb_lib3.ipSublist'](base.connect,'VIP',dictdata['datacenter'],dictdata['environment']) %}
{% set zone = salt['cmdb_lib3.zoneForVIP'](base.connect,dictdata['datacenter'],dictdata['environment']) %}
{% set utliserver = salt['cmdb_lib3.getdata'](base.connect,"VRO_UTILITY_SERVER",dictdata['datacenter']) %}
{% set domainpasswd = salt['cmdb_lib3.getresource'](base.connect,salt['pillar.get']('vrouser'),salt['pillar.get']('vrouser')) %}
{% set Domain = salt['cmdb_lib3.domain'](base.connect,dictdata['datacenter']) %}
{% set lbaccount = salt['cmdb_lib3.getLBAccountName'](base.connect,dictdata['datacenter']) %}
{% set lb = salt['cmdb_lib3.getlb'](base.connect,dictdata['datacenter'],dictdata['environment']) %}
{% set lbpassword = salt['cmdb_lib3.getresource'](base.connect,salt['cmdb_lib3.getLBResourceName'](base.connect,dictdata['datacenter']),salt['cmdb_lib3.getLBAccountName'](base.connect,dictdata['datacenter'])) %}
{% set args = {"netscaler_host": lb,"netscaler_user": lbaccount,"netscaler_pass": lbpassword,"netscaler_useSSL": "False"} %}
{% set csip = salt['cmdb_lib3.getIP'](base.connect,subnet,dictdata['datacenter'],'1',**args)[0] %}

{% if dictdata['datacenter'] == 'LDC' %}
{% set dnsip = salt['cmdb_lib3.getDNS'](base.connect,dictdata['datacenter']) %}
{% else %}
{% set dnsip = salt['cmdb_lib3.getDNS'](base.connect,'CMH') %}
{% endif %}

{% if 'alive' in dictdata['healthCheckResponse'] %}
{% set response = 'alive' %}
{% else %}
{% set response = dictdata['healthCheckResponse'] %}
{% endif %}

{% if dictdata['environment'] == 'PROD' %}
{% set vipcluster =  pillar['ClusterName']  %}
{% else %}
{% set vipcluster =  pillar['ClusterName'] ~'.'~ dictdata['environment'] %}
{% endif %}

addlbmon:
  salt.runner:
    - name: state.orch
    - mods: cluster/Common/lb/addlbmonitor
    - pillar:
        role: {{ dictdata['clusterRole'] }}
        clusterversion: "{{ dictdata['clusterVersion'] }}"
        response: "{{ response }}"
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

addcsvserver:
  salt.runner:
    - name: state.orch
    - mods: cluster/Common/lb/addcsvserver
    - pillar:
        cluster: {{ clustername }}
        ip: "{{ csip["ipaddress"]  }}"
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

bindcsvstopol:
  salt.runner:
    - name: state.orch
    - mods: cluster/Common/lb/bindcsvstopolicy
    - pillar:
        cluster: {{ clustername }}
        policy: {{ dictdata['httpsRedirect'] }}
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

bindcsvstolbvs:
  salt.runner:
    - name: state.orch
    - mods: cluster/Common/lb/bindlbvstocsvs
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

bindcsvstocer:
  salt.runner:
    - name: state.orch
    - mods: cluster/Common/lb/bindcsvstocert
    - pillar:
        cluster: {{ clustername }}
        cert: {{ dictdata['certificate'] }}
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

setcsssl:
  salt.runner:
    - name: state.orch
    - mods: cluster/Common/lb/setsslvstosecure
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

{% if role == 'URW' %}
bindlbvstosg:
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
{% endif %}

{#
addserver:
  ddns.present:
    - name: {{ clustername }}
    - zone: {{ zone|lower }}
    - ttl: 3600
    - data: "{{ csip["ipaddress"] }}"
    - nameserver: "{{ dnsip }}"
    - rdtype: A
    - retry:
        attempts: 3
        until: True
        interval: 60
        splay: 10
#}

Add DNS Record:
  salt.state:
    - sls:
      - cluster/windows/addDNSvipRecord
    - tgt: {{ utliserver }}
    - pillar:
        name: {{ vipcluster }}
        zone: {{ zone|lower }}
        ipaddress: "{{ csip["ipaddress"] }}"
        dnsip: "{{ dnsip }}"
        domainuser: {{ salt['pillar.get']('vrouser') }}
        password: "{{ domainpasswd }}"
    - retry:
        attempts: 2
        until: True
        interval: 60
        splay: 10
    - queue: True
{% else %}

Validated:
  test.succeed_without_changes
{% endif %}
