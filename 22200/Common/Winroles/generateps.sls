{% import "./vars.sls" as commonbase %}


{% set PACKAGE_ROOT = commonbase.dict['PACKAGE_ROOT'] %}
{% if PACKAGE_ROOT[-1:] == "\\" %}
{% set PACKAGE_ROOT = PACKAGE_ROOT[:-1] %}
{% endif %}


{% set PACKAGE_SHARE = commonbase.dict['PACKAGE_SHARE'] %}
{% if PACKAGE_SHARE[-1:] == "\\" %}
{% set PACKAGE_SHARE = PACKAGE_SHARE[:-1] %}
{% endif %}


{% for server in commonbase.clusterservers %}

Replace values in {{commonbase.role}}.ps1 for {{ server }}:
  file.managed:
    - name: /srv/salt/{{ commonbase.scripts_folder }}/{{ commonbase.cluster }}_{{ server }}_{{ commonbase.role }}.ps1
    - source: {{ commonbase.common_template_folder }}/provision.ps1
    - makedirs: True
    - replace: True
    - template: jinja
    - ROLE: {{ commonbase.role }}
    - BUILD: {{ commonbase.suite_version }}
    - PACKAGE_SHARE: {{ PACKAGE_SHARE }}
    - PACKAGE_ROOT: {{ PACKAGE_ROOT }}
    - TEMP: {{ commonbase.dict['LOG_DIRECTORY'] }}
    - SERVER: {{ server }}
    - CLUSTER: {{ commonbase.cluster }}
    - UDAC_SERVER: {{ commonbase.dict['CMDB_DB_SERVER'] }}
    - UDAC_DB: {{ commonbase.dict['CMDB_DB_NAME'] }}
    - UDAC_USER: {{ commonbase.dict['CMDB_DB_USER'] }}
    - UDAC_PASS: {{ commonbase.dict['CMDB_DB_PASSWORD'] }}
    - ASSOCIATED_CLUSTER: {{ commonbase.associated_cluster }}
    - FILE_TEMP: {{ commonbase.dict['LOG_DIRECTORY'] }}
    - WORKFLOW: {{ commonbase.workflow }}

{% endfor %}
