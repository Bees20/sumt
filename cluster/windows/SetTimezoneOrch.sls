{% import "./Connectionvars.sls" as base %}

{% set clusterservers = salt['cmdb_lib3.getClusterServerList'](base.connect,pillar['ClusterName']) %}
{% set timeZone = salt['cmdb_lib3.getTimeZone'](base.connect,pillar['datacenter']) %}
{% for server in clusterservers %}

Set TimeZone {{ server }}:
  salt.function:
    - name: timezone.set_zone
    - arg:
      - "{{ timeZone }}"
    - tgt: {{ server }}
    - queue: True
{% endfor %}

