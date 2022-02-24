{% import "./Connectionvars.sls" as base %}

{% set adminpwd = salt['cmdb_lib3.getresource'](base.connect,salt['cmdb_lib3.getWindowsResourceName'](base.connect,pillar['datacenter']),salt['cmdb_lib3.getWindowsAccountName'](base.connect,pillar['datacenter'])) %}

{% for role in pillar['clusterroles'] %}

{% if role == 'URD' or role == 'UDD' or role == 'UUD' or role == 'UTD' or role == 'UWD' %}

{% set Roleversion = salt['cmdb_lib3.getRoleversion'](base.connect,pillar['packageName'],role) %}
{% set instance = salt['cmdb_lib3.getRoleTemplateName'](base.connect,pillar['datacenter'],role,Roleversion,pillar['packageName']) %}
{% set sa_pass = salt['cmdb_lib3.getresource'](base.connect,'vRATemplate','sa') %}
{% set SMTP = salt['cmdb_lib3.getConfigValueByKey'](base.connect,pillar['datacenter'],'SMART_SMTP_HOST') %}
{% set sqlLogins = salt['cmdb_lib3.getConfigValueByKey'](base.connect,pillar['datacenter'],'CO_UDA_WIN_DB_SYSADMINS') %}
{% set backupLocation = salt['cmdb_lib3.getConfigValueByKey'](base.connect,pillar['datacenter'],'CO_UDA_WIN_DB_BACKUPLOCATION') %}
{% set tempfolder = 'c:\\Temp' %}


Copy SQL scripts {{ role }} db on {{ instance }}:
  salt.state:
    - tgt: {{ instance }}
    - sls:
      - BuildTemplate/windows/CopyDBScripts


Configure {{ role }} db {{ instance }}:
  salt.state:
    - tgt: {{ instance }}
    - sls:
      - BuildTemplate/windows/PostDbBuild
      - BuildTemplate/windows/LoginsCreation
    - pillar:
        sql_user: "{{ salt['pillar.get']('sqlaccount') }}"
        instance: {{ instance }}
        sa_pass: "{{ sa_pass }}"
        tempfolder: {{ tempfolder }}
        domain_user: "{{ salt['pillar.get']('sqlaccount') }}"
        SMTP: {{ SMTP }}
        sqlLogins: "{{ sqlLogins }}"
        backupLocation: "{{ backupLocation }}"
        adminuser: {{ salt['cmdb_lib3.getWindowsAccountName'](base.connect,pillar['datacenter']) }}
        adminpass: "{{ adminpwd }}"
{% else %}

Validated:
  test.succeed_without_changes

{% endif %}

{% endfor %}

