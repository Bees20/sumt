{% import "./../../Common/Winroles/vars.sls" as commonbase %}

Refreshdb:
  module.run:
    - name: pkg.refresh_db

Install Packages:
  pkg.installed:
    - pkgs:
      - custom7zip
      - openjdk
    - refresh_db: True
    - require:
      - module: Refreshdb

Installdotnet4.8:
  module.run:
    - name: pkg.install
    - m_name: dotnet4.8
    - require:
      - pkg: Install Packages

Install SQLSysClrTypes:
  pkg.installed:
    - pkgs:
      - sqlsysclrtypes
    - require:
      - module: Installdotnet4.8

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

Install Sqlncli: 
  pkg.installed:
    - pkgs:
      - sqlncli
    - require:
      - pkg: Install PowershellTools

Install Msodbcsql: 
  pkg.installed:
    - pkgs:
      - msodbcsql
    - require:
      - pkg: Install Sqlncli

Install MsSqlCmdLnUtils: 
  pkg.installed:
    - pkgs:
      - mssqlcmdlnutils
    - require:
      - pkg: Install Msodbcsql

Set Powershell Execution Policy:
  cmd.run:
    - name: 'set-executionpolicy remotesigned'
    - shell: powershell

Refresh Regedit:
  module.run:
    - name: reg.broadcast_change
    - require:
      - cmd: Set Powershell Execution Policy

Enable Diffie-Hellman:
  cmd.run:
    - name: 'reg add HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\Diffie-Hellman /t REG_DWORD /d 4294967295 /f'
    - shell: powershell
    - require:
      - cmd: Set Powershell Execution Policy

