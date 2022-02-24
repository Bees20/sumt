{% import "./Connectionvars.sls" as base %}

{% if pillar['clusterrole'] == 'UTA' or pillar['clusterrole'] == 'URW' %}

{% set role = pillar['clusterrole'] %}

{% set assoccluster = salt['cmdb_lib3.getassociatedcluster'](base.connect,salt['pillar.get']('ClusterName')) %}

{% set assoClusterServers = salt['cmdb_lib3.getClusterServerList'](base.connect,assoccluster) %}

{% set role_params = "'', '" + pillar['ClusterName'] + "','" + assoccluster + "','" + pillar['Workflow'] + "','" + pillar['clusterrole'] + "',''" %}

{% set params = "'', '" + assoccluster + "','" + pillar['ClusterName'] + "','" + pillar['Workflow'] + "','" + assoccluster.split('-')[3] +"',''" %}

{% set role_query = "select [dbo].[GET_PS_INSTALL_PARAMETERS](" + role_params + ")" %}

{% set query = "select [dbo].[GET_PS_INSTALL_PARAMETERS](" + params + ")" %}

{% set Install_params = salt['cmdb_lib3.get_install_params'](base.connect,query,pillar['packageName'],assoccluster.split('-')[3],pillar['datacenter'],salt['pillar.get']('sqlaccount'),salt['pillar.get']('udacresource'),salt['pillar.get']('domainuser')) %}

{% set role_Install_params = salt['cmdb_lib3.get_install_params'](base.connect,role_query,pillar['packageName'],pillar['clusterrole'],pillar['datacenter'],salt['pillar.get']('sqlaccount'),salt['pillar.get']('udacresource'),salt['pillar.get']('domainuser')) %}

{% set suiteversion = pillar['packageName'].split('-')[0]| regex_replace('\\.|\\-', '') %}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}

{% set Domain = salt['cmdb_lib3.domain'](base.connect,salt['pillar.get']('datacenter')) %}

{% set shares = [salt['cmdb_lib3.getTenantShare'](base.connect,pillar['datacenter']),salt['cmdb_lib3.getPackageShare'](base.connect,pillar['datacenter'])] %}

{% set domainpasswd = salt['cmdb_lib3.getresource'](base.connect,salt['pillar.get']('domainuser'),salt['pillar.get']('domainuser')) %}

{% for server in assoClusterServers %}

Change Minion Log on AS service {{ server }}:
  salt.state:
    - sls:
      - cluster/windows/minionLogonAs
    - tgt: {{ server }}
    - pillar:
        domain: {{ Domain }}
        domainuser: {{ salt['pillar.get']('domainuser') }}
        domainpasswd: {{ domainpasswd }}

symlink Creation on {{ server }}:
  salt.state:
    - tgt: {{ server }}
    - sls:
      - cluster/windows/symlink
    - pillar:
        domain: {{ Domain }}
        environment: {{ salt['pillar.get']('environment') }}
        datacenter: {{ salt['pillar.get']('datacenter') }}
        tenantShare: {{ salt['cmdb_lib3.getTenantShare'](base.connect,pillar['datacenter']) }}
        packageShare: {{ salt['cmdb_lib3.getPackageShare'](base.connect,pillar['datacenter']) }}
    - retry:
        attempts: 3
        until: True
        interval: 45
        splay: 10

{% endfor %}

Post Role Configuration for {{ assoccluster }}:
  salt.runner:
    - name: state.orch
    - mods: {{ suiteversion }}/{{ assoccluster.split('-')[3] }}/Workflow/orch
    - pillar:
        VERSION: {{ pillar['packageName'] }}
        WORKFLOW: {{ pillar['Workflow'] }}
        CLUSTER: {{ assoccluster }}
        ROLE: {{ assoccluster.split('-')[3] }}
        ASSOCIATED_CLUSTER: {{ pillar['ClusterName'] }}
        CLUSTERSERVERS: {{ assoClusterServers }}
        DICT: {{ Install_params | json }}
    - retry:
        attempts: 2
        until: True
        interval: 60
        splay: 10
    - failhard: True



Post Role Configuration for {{ pillar['ClusterName'] }}:
  salt.runner:
    - name: state.orch
    - mods: {{ suiteversion }}/{{ pillar['clusterrole'] }}/Workflow/orch
    - pillar:
        VERSION: {{ pillar['packageName'] }}
        WORKFLOW: {{ pillar['Workflow'] }}
        CLUSTER: {{ pillar['ClusterName'] }}
        ROLE: {{ pillar['clusterrole'] }}
        ASSOCIATED_CLUSTER: {{ pillar['associateClusterName'] }}
        CLUSTERSERVERS: {{ clusterservers }}
        DICT: {{ dict(role_Install_params) | json }}
    - retry:
        attempts: 2
        until: True
        interval: 60
        splay: 10

{% else %}

Validated:
  test.succeed_without_changes

{% endif %}
