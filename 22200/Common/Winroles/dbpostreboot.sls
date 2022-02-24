{% import "./vars.sls" as commonbase %}

{% set servername = grains['host'] %}
{% set servercpus = grains['num_cpus'] %}
{% set serverram = grains['mem_total'] %}
{% set maxmemory = serverram *85 //100 %}
{% set maxdegree = servercpus / 2 + 1 %}
{% set sa_pwd = commonbase.dict["sa_pwd"] %}

{% if commonbase.role == 'URD' or commonbase.role == 'UDD' or commonbase.role == 'UUD' or commonbase.role == 'UTD' or commonbase.role == 'UWD' %}

sqlmxmemory:
  file.managed:
    - name: {{commonbase.temp_folder}}\sqlmaxmemory.sql
    - source: salt://{{ commonbase.parentfolder }}/Common/Templates/sqlmaxmemory.sql
    - template: jinja
    - maxmemory: {{maxmemory}}
    - makedirs: true

runsqlmaxmemory:
  cmd.run:
    - name: sqlcmd.exe -S "{{servername}}" -U "sa" -P "{{ sa_pwd }}" -d "master" -i "{{commonbase.temp_folder}}/sqlmaxmemory.sql"

minmemoryperquery:
  file.managed:
    - name: {{commonbase.temp_folder}}\minmemoryperquery.sql
    - source: salt://{{ commonbase.parentfolder }}/Common/Templates/minmemoryperquery.sql
    - makedirs: true

runmaxmemoryperquery:
  cmd.run:
    - name: sqlcmd.exe -S "{{servername}}" -U "sa" -P "{{ sa_pwd }}" -d "master" -i "{{commonbase.temp_folder}}/minmemoryperquery.sql"

degreeofparallelism:
  file.managed:
    - name: {{commonbase.temp_folder}}\maxdegreeofparallelism.sql
    - source: salt://{{ commonbase.parentfolder }}/Common/Templates/maxdegreeofparallelism.sql
    - template: jinja
    - maxdegree: {{maxdegree}}
    - makedirs: true

rundegreeofparallelism:
  cmd.run:
    - name: sqlcmd.exe -S "{{servername}}" -U "sa" -P "{{ sa_pwd }}" -d "master" -i "{{commonbase.temp_folder}}/maxdegreeofparallelism.sql"

indexfactor:
  file.managed:
    - name: {{commonbase.temp_folder}}\indexfactor.sql
    - source: salt://{{ commonbase.parentfolder }}/Common/Templates/indexfactor.sql
    - makedirs: true

runindexfactor:
  cmd.run:
    - name: sqlcmd.exe -S "{{servername}}" -U "sa" -P "{{ sa_pwd }}" -d "master" -i "{{commonbase.temp_folder}}/indexfactor.sql"

Copying Database Creation Files:
  file.recurse:
    - name: {{commonbase.temp_folder}}\CO_SQLScripts
    - source: salt://{{ commonbase.parentfolder }}/Common/Templates/CO_SQLScripts
    - makedirs: true
    - include_empty: True

Creating DBA Database:
  cmd.run:
    - name: sqlcmd.exe -S "{{servername}}" -U "sa" -P "{{ sa_pwd }}" -d "master" -i "{{commonbase.temp_folder}}/CO_SQLScripts/DBA.sql"

Creating DBAAdmin Database:
  cmd.run:
    - name: sqlcmd.exe -S "{{servername}}" -U "sa" -P "{{ sa_pwd }}" -d "master" -i "{{commonbase.temp_folder}}/CO_SQLScripts/dbaAdmin.sql"

Creating AppUtilDB Database:
  cmd.run:
    - name: sqlcmd.exe -S "{{servername}}" -U "sa" -P "{{ sa_pwd }}" -d "master" -i "{{commonbase.temp_folder}}/CO_SQLScripts/appUtilDb.sql"

{% endif %}

{% if commonbase.role == 'UGM' %}

{% set pm2exists = salt['service.available']('pm2.exe') %}

{% if pm2exists == True %}

Kill PM2:
  cmd.run:
    - name: 'pm2 kill'
{#
Stop PM2 service:
  module.run:
    - name: service.stop
    - m_name: pm2.exe
    - require:
      - cmd: Kill PM2

Set PM2 service Manual:
  module.run:
    - name: service.modify
    - m_name: pm2.exe
    - start_type: manual
    - require:
      - module: Stop PM2 service
#}
{% endif %}

{% endif %}

