{% import "./Connectionvars.sls" as base %}

{% set instances = salt['cmdb_lib3.getRoleTemplateNamev1'](base.connect,pillar['datacenter'],pillar['clusterroles'],pillar['packageName']) %}

{% set repoServer = salt['cmdb_lib3.getRepoServer'](base.connect,salt['pillar.get']('datacenter')) %}

{% for value in instances %}

{% if value['role'] == 'UXD' %}

{% set password = salt['cmdb_lib3.getresource'](base.connect,salt['pillar.get']('uxdExporteruser'),salt['pillar.get']('uxdExporteruser')) %}

{% elif value['role'] == 'UMD' %}

{% set password = salt['cmdb_lib3.getresource'](base.connect,salt['pillar.get']('umdExporteruser'),salt['pillar.get']('umdExporteruser')) %}

{% else %}

{% set password = '' %}

{% endif %}

Configure Role Exporter {{ value['instance'] }}:
  salt.runner:
    - name: state.orch
    - mods: BuildTemplate/Linux/roleExporter
    - pillar:
        role: {{ value['role'] }}
        repoServer: {{ repoServer }}
        instance: {{ value['instance'] }}
        packageName: {{ pillar['packageName'] }}
        password: "{{ password }}"
    - parallel: True


{% endfor %}
