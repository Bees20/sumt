{% import "./Connectionvars.sls" as base %}

{% set timeZone = salt['cmdb_lib3.getTimeZone'](base.connect,pillar['datacenter']) %}
{% for role in pillar['clusterroles'] %}

{% set Roleversion = salt['cmdb_lib3.getRoleversion'](base.connect,pillar['packageName'],role) %}

{% set instance = salt['cmdb_lib3.getRoleTemplateName'](base.connect,pillar['datacenter'],role,Roleversion,pillar['packageName']) %}

Set TimeZone {{ instance }}:
  salt.function:
    - name: timezone.set_zone
    - arg:
      - "America/New_York"
    - tgt: {{ instance }}
{% endfor %}

