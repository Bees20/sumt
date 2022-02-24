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

Disable TLS 1.0 in server:
  reg.present:
    - name: HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server
    - vname: Enabled
    - vdata: 0
    - vtype: REG_DWORD
 
Disable TLS 1.0 in client:
  reg.present:
    - name: HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client
    - vname: Enabled
    - vdata: 0
    - vtype: REG_DWORD

Disable TLS 1.1 in server:
  reg.present:
    - name: HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server
    - vname: Enabled
    - vdata: 0
    - vtype: REG_DWORD

Disable TLS 1.1 in client:
  reg.present:
    - name: HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client
    - vname: Enabled
    - vdata: 0
    - vtype: REG_DWORD

Enable TLS 1.2 in server:
  reg.present:
    - name: HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server
    - vname: Enabled
    - vdata: 1
    - vtype: REG_DWORD

Enable TLS 1.2 in client:
  reg.present:
    - name: HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client
    - vname: Enabled
    - vdata: 1
    - vtype: REG_DWORD

DisableByDefault TLS 1.2 in server:
  reg.present:
    - name: HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server
    - vname: DisabledByDefault 
    - vdata: 0
    - vtype: REG_DWORD

DisableByDefault TLS 1.2 in client:
  reg.present:
    - name: HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client
    - vname: DisabledByDefault
    - vdata: 0
    - vtype: REG_DWORD