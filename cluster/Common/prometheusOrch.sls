{% import "./Connectionvars.sls" as base %}

{% if salt['pillar.get']('environment') != 'PROD' or  salt['cmdb_lib3.islinux'](base.connect,pillar['clusterrole']) == 'NIX' %}

{% set prometheusserver = salt['cmdb_lib3.prometheusvm'](base.connect,pillar['datacenter']) %}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}

{% set Info = salt['cmdb_lib3.getConfigInfo'](base.connect,pillar['ClusterName']) %}

{% for server in clusterservers %}

{#% if salt['cmdb_lib3.islinux'](base.connect,pillar['clusterrole']) == 'NIX' %#}

addprometheus {{ server }}:
  salt.state:
    - sls:
      - cluster/Linux/backupprometheus
      - cluster/Linux/addprometheus
    - tgt: {{ prometheusserver.lower() }}
    - pillar:
        vm: {{ server }}
        role: {{ pillar['clusterrole'] }}
        OS: {{ salt.cmd.run('salt '~ server ~' grains.item os').splitlines() | last | trim }}
    - queue: True

addroleprometheus {{ server }}:
  salt.state:
    - sls:
      - cluster/Linux/addvmtoroleprometheus
    - tgt: {{ prometheusserver.lower() }}
    - pillar:
        vm: {{ server }}
        role: {{ pillar['clusterrole'] }}
        PackageName: {{ pillar['packageName'] }}
    - queue: True

{% if (pillar['clusterrole'] == 'SCC' or pillar['clusterrole'] == 'DCC') %}

updateredispasswordprometheus {{ server }}:
  salt.state:
    - sls:
      - cluster/Linux/updateRedispasswordPrometheus
    - tgt: {{ server }}
    - pillar:
        redispass: '{{ salt['cmdb_lib3.getresource'](base.connect,pillar['ClusterName'],'redis') }}'
        server: {{ server }}
    - queue: True
{% endif %}

{% if pillar['clusterrole'] == 'UKA' and (pillar['packageName']|replace('-','')|replace('.','')) < 21300178 %}

updaterabbitmqpasswordprometheus {{ server }}:
  salt.state:
    - sls:
      - cluster/Linux/updateRabbitMQpassword
    - tgt: {{ server }}
    - pillar:
        rabbitmqpass: '{{ salt['cmdb_lib3.getresource'](base.connect,pillar['ClusterName'],'rabbitadmin') }}'
    - queue: True
{% endif %}


{% if pillar['clusterrole'] == 'UMD' %}

updateUMDpasswordprometheus {{ server }}:
  salt.state:
    - sls:
      - cluster/Linux/updateUMDpasswordPrometheus
    - tgt: {{ server }}
    - pillar:
        Info: {{ dict(Info) | json }}
    - queue: True
{% endif %}

{#% endif %#}

{% endfor %}

{% else %}
Validated:
  test.succeed_without_changes
{% endif %}
