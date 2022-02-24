{% import "./Connectionvars.sls" as base %}

{% if (salt['pillar.get']('clusterrole') not in ('UTA','URW','UTD','URD')) %}

{% if salt['pillar.get']('associateClusterName') != '' %}

{% set assoccluster = salt['cmdb_lib3.getassociatedcluster'](base.connect,salt['pillar.get']('ClusterName')) %}

{#% set assoClusterServersIP = salt['cmdb_lib3.get_assoclusterVmIps'](base.connect,assoccluster) %#}

{% set params = "'', '" + pillar['ClusterName'] + "','" + assoccluster + "','" + pillar['Workflow'] + "','" + pillar['clusterrole'] + "',''" %}

{% else %}

{#%set assoClusterServersIP = 'defalut' %#}

{% set params =  "'', '" + pillar['ClusterName'] + "','','" + pillar['Workflow'] + "','" + pillar['clusterrole'] + "',''" %}

{% endif %}

{% set query = "select [dbo].[GET_PS_INSTALL_PARAMETERS](" + params + ")" %}

{% set Install_params = salt['cmdb_lib3.get_install_params'](base.connect,query,pillar['packageName'],pillar['clusterrole'],pillar['datacenter'],salt['pillar.get']('sqlaccount'),salt['pillar.get']('udacresource'),salt['pillar.get']('domainuser')) %}

{% set suiteversion = pillar['packageName'].split('-')[0]| regex_replace('\\.|\\-', '') %}

{#% set repoServer = salt['cmdb_lib3.getRepoServer'](base.connect,salt['pillar.get']('datacenter')) %#}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}

{#% set VMdata = salt['cmdb_lib3.getVMdata'](base.connect,pillar['ClusterName']) %#}


Post Role Configuration:
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
        DICT: {{ Install_params | json }}
    - retry:
        attempts: 2
        until: True
        interval: 60
        splay: 10

{% else %}

Validated:
  test.succeed_without_changes

{% endif %}
