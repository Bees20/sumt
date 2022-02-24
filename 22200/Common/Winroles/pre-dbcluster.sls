{% import "./vars.sls" as commonbase %}

{% set servername = grains['host'] %}
{% set sa_pwd = commonbase.dict["sa_pwd"] %}

sqlservernamequery:
  file.managed:
    - name: {{commonbase.temp_folder}}\changesqlservername.sql
    - source: salt://{{ commonbase.parentfolder }}/Common/Templates/changesqlservername.sql
    - makedirs: true

Runsqlservernamechangequery:
  cmd.run:
    - name: sqlcmd.exe -S "{{servername}}" -U "sa" -P "{{ sa_pwd }}" -d "master" -i "{{commonbase.temp_folder}}/changesqlservername.sql"

Stop sqlserveragent:
  module.run:
    - name: service.stop
    - m_name: SQLSERVERAGENT

Restart sqlserver:
  module.run:
    - name: service.restart
    - m_name: MSSQLSERVER

Start sqlserveragent:
  module.run:
    - name: service.start
    - m_name: SQLSERVERAGENT

{% if commonbase.role == 'UUD' %}

createusersql:
  file.managed:
    - name: {{commonbase.temp_folder}}\createuser.sql
    - source: salt://{{ commonbase.parentfolder }}/Common/Templates/createuser.sql
    - template: jinja
    - username: {{ commonbase.dict["UUD_ADMIN_USER"] }}
    - pwd: {{ commonbase.dict["UUD_ADMIN_PASSWORD"] }}

{% endif %}

{% if commonbase.role == 'UDD' %}

createusersql:
  file.managed:
    - name: {{commonbase.temp_folder}}\createuser.sql
    - source: salt://{{ commonbase.parentfolder }}/Common/Templates/createuser.sql
    - template: jinja
    - username: {{ commonbase.dict["UWD_DISTRIBUTOR_ADMIN_USER"] }}
    - pwd: {{ commonbase.dict["UWD_DISTRIBUTOR_ADMIN_PASSWORD"] }}

{% endif %}

{% if commonbase.role == 'UTD' %}

createusersql:
  file.managed:
    - name: {{commonbase.temp_folder}}\createuser.sql
    - source: salt://{{ commonbase.parentfolder }}/Common/Templates/createuser.sql
    - template: jinja
    - username: {{ commonbase.dict["UTD_ADMIN_USER"] }}
    - pwd: {{ commonbase.dict["UTD_ADMIN_PASSWORD"] }}

{% endif %}

{% if commonbase.role == 'URD' %}

createusersql:
  file.managed:
    - name: {{commonbase.temp_folder}}\createuser.sql
    - source: salt://{{ commonbase.parentfolder }}/Common/Templates/createuser.sql
    - template: jinja
    - username: {{ commonbase.dict["URD_ADMIN_USER"] }}
    - pwd: {{ commonbase.dict["URD_ADMIN_PASSWORD"] }}

{% endif %}

{% if commonbase.role == 'UWD'%}

createusersql:
  file.managed:
    - name: {{commonbase.temp_folder}}\createuser.sql
    - source: salt://{{ commonbase.parentfolder }}/Common/Templates/createuser.sql
    - template: jinja
    - username: {{ commonbase.dict["UWD_ADMIN_USER"] }}
    - pwd: {{ commonbase.dict["UWD_ADMIN_PASSWORD"] }}

{% endif %}

runcreateuser:
  cmd.run:
    - name: sqlcmd.exe -S "{{servername}}" -U "sa" -P "{{ sa_pwd }}" -d "master" -i "{{commonbase.temp_folder}}\createuser.sql"







