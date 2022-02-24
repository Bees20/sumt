{% import "./Connectionvars.sls" as base %}

{% set suiteversion = pillar['packageName'].split('-')[0]| regex_replace('\\.|\\-', '') %}

{% set subdomain =  salt['pillar.get']('domain')  %}

{% set saltuser = salt['cmdb_lib3.domain'](base.connect,pillar['datacenter']).split('.')[0]+'\\'+pillar['domainuser']  %}

{% set backupLocation = salt['cmdb_lib3.getConfigValueByKey'](base.connect,pillar['datacenter'],'CO_UDA_WIN_DB_BACKUPLOCATION') %}

{% for role in pillar['clusterroles'] %}

{% set Roleversion = salt['cmdb_lib3.getRoleversion'](base.connect,pillar['packageName'],role) %}

{% set instance = salt['cmdb_lib3.getRoleTemplateName'](base.connect,pillar['datacenter'],role,Roleversion,pillar['packageName']) %}

{% if role in ('UTD','URD','UUD','UWD','UDD') %}

Create Backup Folder on Share for {{ role }} db {{ instance }}:
  salt.state:
    - tgt: {{ instance }}
    - sls:
      - BuildTemplate/windows/createdir
    - pillar:
        backupLocation: "{{ backupLocation }}\\{{ instance }}"
        user: {{ saltuser }}

{% else %}

Validated:
  test.succeed_without_changes

{% endif %}

Install Role Prerequisites {{ instance }}:
  salt.runner:
    - name: state.orch
    - mods: {{ suiteversion }}/{{ role }}/Workflow/orch
    - pillar:
        VERSION: {{ pillar['packageName'] }}
        WORKFLOW: "PROVISION"
        SERVER: {{ instance }}
        ROLE: {{ role }}
        DICT: {{ salt['cmdb_lib3.getprerequisiteurls'](base.connect,pillar['packageName'],role,pillar['datacenter'],salt['pillar.get']('sqlaccount'),salt['pillar.get']('domainuser')) | json }}
    - failhard: True
    - parallel: True

{% if role == 'UDD' %}

Create Snapshot Folder {{ instance }}:
  salt.state:
    - tgt: {{ instance }}
    - sls:
      - BuildTemplate/windows/CreateSnapshotFolder

{% endif %}

{% endfor %}
