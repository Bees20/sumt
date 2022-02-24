{% import "./../../Common/Winroles/vars.sls" as commonbase %}

{% if commonbase.dict['iis_sourcefile'] != '' %}

Download iis sourcefile:
  file.managed:
    - name: {{ commonbase.temp_folder }}\microsoft-windows-netfx3-ondemand-package.cab
    - source: {{ commonbase.dict['iis_sourcefile'] }}
    - skip_verify: True

{% endif %}

Install_IIS-Multiple_features:
  win_servermanager.installed:
    - features:
      - NET-Framework-Features
      - NET-Framework-Core
    - source: {{ commonbase.temp_folder }}\

Refreshdb:
  module.run:
    - name: pkg.refresh_db

Install Packages:
  pkg.installed:
    - pkgs:
      - custom7zip
      - nodejs16.10.0
    - refresh: True
    - require:
      - module: Refreshdb

Install dotnet4.8:
  module.run:
    - name: pkg.install
    - m_name: dotnet4.8
    - require:
      - pkg: Install Packages 

Install SQLSysClrTypes:
  pkg.installed:
    - pkgs:
      - sqlsysclrtypes

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

Set Powershell Execution Policy:
  cmd.run:
    - name: 'set-executionpolicy remotesigned'
    - shell: powershell

Refresh Regedit:
  module.run:
    - name: reg.broadcast_change
    - require:
      - cmd: Set Powershell Execution Policy

Create_pm2folder:
  file.directory:
    - name: {{ commonbase.pm2 }}
    - makedirs: True
    - require:
      - pkg: Install Packages

Copy pm2:
  archive.extracted:
    - name: {{ commonbase.pm2 }}
    - source: salt://{{ commonbase.parentfolder }}/{{ commonbase.role }}/Templates/pm2.zip
    - enforce_toplevel: false
    - skip_verify: true
    - require:
      - file: Create_pm2folder

Add PM2 Path to Environment Variables:
  win_path.exists:
    - name: {{ commonbase.pm2 }}\NPM

PM2_HOME variable:
   environ.setenv:
     - name: PM2_HOME
     - value: {{ commonbase.pm2 }}\.pm2
     - update_minion: True
     - permanent: HKLM

PM2_SERVICE_PM2_DIR variable:
   environ.setenv:
     - name: PM2_SERVICE_PM2_DIR
     - value: {{ commonbase.pm2 }}\NPM\node_modules\pm2\index.js
     - update_minion: True
     - permanent: HKLM

SET_PM2_HOME variable:
   environ.setenv:
     - name: SET_PM2_HOME
     - value: 'true'
     - update_minion: True
     - permanent: HKLM

SET_PM2_SERVICE_PM2_DIR variable:
   environ.setenv:
     - name: SET_PM2_SERVICE_PM2_DIR
     - value: 'true'
     - update_minion: True
     - permanent: HKLM

SET_PM2_SERVICE_SCRIPTS variable:
   environ.setenv:
     - name: SET_PM2_SERVICE_SCRIPTS
     - value: 'true'
     - update_minion: True
     - permanent: HKLM

Update PM2 values:
  file.replace:
    - name: {{ commonbase.pm2_dir }}\\npm\\node_modules\\pm2-windows-service\\src\\daemon\\pm2.xml
    - pattern: C:\\Users\\deployteam\\AppData\\Roaming
    - repl: {{ commonbase.pm2_dir }}
    - require:
      - archive: Copy pm2


{% set pm2exists = salt['service.available']('pm2.exe') %}

{% if pm2exists == False %}

Create PM2 service:
  module.run:
    - name: service.create
    - m_name: pm2.exe
    - bin_path: {{ commonbase.pm2 }}\npm\node_modules\pm2-windows-service\src\daemon\pm2.exe
    - display_name: pm2
    - start_type: auto
    - require:
      - file: Update PM2 values

{% endif %}



