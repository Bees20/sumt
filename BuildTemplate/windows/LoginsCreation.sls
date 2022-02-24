
Copy Login Creation Files:
  file.managed:
    - name: {{ pillar['tempfolder'] }}/DB_TemplateScripts/logins.sql
    - source: salt://files/logins.sql
    - replace: True

Copy System DB config File:
  file.managed:
    - name: {{ pillar['tempfolder'] }}/DB_TemplateScripts/SystemDBConfig.sql
    - source: salt://files/SystemDBConfig.sql
    - replace: True

Configure System Databases:
  cmd.run:
    - name: sqlcmd.exe -S "{{ pillar['instance'] }}" -U "sa" -P "{{ pillar['sa_pass'] }}" -d "master" -i "{{pillar['tempfolder']}}//DB_TemplateScripts//SystemDBCOnfig.sql"


Stop MSSQL Agent Service:
  module.run:
    - name: service.stop
    - m_name: SQLSERVERAGENT
    - timeout: 180

Stop MSSQL Service:
  module.run:
    - name: service.stop
    - m_name: MSSQLSERVER
    - timeout: 180

Configure Startup Parameters for master:
  cmd.script:
    - source: salt://files/StartupParameters.ps1
    - shell: powershell    
    - runas: {{ pillar['adminuser'] }}
    - password: "{{ pillar['adminpass'] }}"
    - require:
      - Stop MSSQL Service

Start MSSQL Agent Service:
  module.run:
    - name: service.start
    - m_name: SQLSERVERAGENT
    - timeout: 180

Start MSSQL Service:
  module.run:
    - name: service.start
    - m_name: MSSQLSERVER
    - timeout: 180

 

{% for login in pillar['sqlLogins'].split(',') %}

Creating Login {{ login }}:
  cmd.run:
    - name: sqlcmd.exe -S "{{ pillar['instance'] }}" -U "sa" -P "{{ pillar['sa_pass'] }}" -d "master" -i "{{pillar['tempfolder']}}//DB_TemplateScripts//logins.sql" -v login="{{ login }}"

{% endfor %}

