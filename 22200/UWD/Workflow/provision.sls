{% import "./../../Common/Winroles/vars.sls" as commonbase %}


{% set sqlserviceexists = salt['service.available']('MSSQLSERVER') %}

sqlcopy1:
  file.managed:
    - name: {{ commonbase.temp_folder }}\ConfigurationFile.ini
    - source: {{ commonbase.dict['configurationFile.ini'] }}
    - template: jinja
    - makedirs: true
    - skip_verify: true

Update SQLBACKUPDIR Path In INI File:
  file.replace:
    - name: {{ commonbase.temp_folder }}\ConfigurationFile.ini
    - pattern: 'SQLBACKUPDIR=.+$'
    - repl: SQLBACKUPDIR={{ commonbase.dict['backupLocation']|replace('\\','\\\\') }}

sqlcopy:
  archive.extracted:
    - name: {{ commonbase.temp_folder }}\sqlserver
    - source: {{ commonbase.dict['sqlserver'] }}
    - enforce_toplevel: false
    - skip_verify: true

copybat:
  file.managed:
    - source: salt://{{ commonbase.parentfolder }}/Common/Templates/install.bat
    - name: {{ commonbase.temp_folder }}\sqlserver\install.bat
    - template: jinja 
    - domain_user: {{ commonbase.dict['domain_user'] }} 
    - domain_pwd: {{ commonbase.dict['domain_pwd'] }} 
    - sa_pwd: {{ commonbase.dict['sa_pwd'] }} 
    - config_path: {{ commonbase.temp_folder }}\ConfigurationFile.ini

Download sql2016sp2:
  file.managed:
    - name: {{ commonbase.temp_folder }}\SQLServer2016SP2-KB4052908-x64-ENU.exe
    - source: {{ commonbase.dict['sql2016sp2'] }}
    - skip_verify: True

Download sql2016sp3:
  file.managed:
    - name: {{ commonbase.temp_folder }}\SQLServer2016SP3-KB5003279-x64-ENU.exe
    - source: {{ commonbase.dict['sql2016sp3'] }}
    - skip_verify: True

copysql2016sp2:
  file.managed:
    - source: salt://{{ commonbase.parentfolder }}/Common/Templates/install_sqlsp2.bat
    - name: {{ commonbase.temp_folder }}\install_sqlsp2.bat

copysql2016sp3:
  file.managed:
    - source: salt://{{ commonbase.parentfolder }}/Common/Templates/install_sqlsp3.bat
    - name: {{ commonbase.temp_folder }}\install_sqlsp3.bat


{% if not salt['service.available']('MSSQLSERVER') %}

runsqlbat:
  cmd.script:
    - source: {{ commonbase.temp_folder }}\sqlserver\install.bat
    - cwd: {{ commonbase.temp_folder }}\sqlserver\

runsqlsp2bat:
  cmd.script:
    - name: {{ commonbase.temp_folder }}\install_sqlsp2.bat
    - cwd: {{ commonbase.temp_folder }}

runsqlsp3bat:
  cmd.script:
    - name: {{ commonbase.temp_folder }}\install_sqlsp3.bat
    - cwd: {{ commonbase.temp_folder }}

{% endif %}

Refreshdb:
  module.run:
    - name: pkg.refresh_db

Install Packages:
  pkg.installed:
    - pkgs:
      - custom7zip
      - ssms  
    - refresh_db: True
    - require:
      - module: Refreshdb

Install SQLSysClrTypes:
  pkg.installed:
    - pkgs:
      - sqlsysclrtypes
    - require:
      - pkg: Install Packages

Install SharedManagementObjects: 
  pkg.installed:
    - pkgs:
      - sharedmanagementobjects
    - require:
      - pkg: Install SQLSysClrTypes

Install PowershellTools: 
  pkg.installed:
    - pkgs:
      - powershelltools
    - require:
      - pkg: Install SharedManagementObjects
