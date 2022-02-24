{% import "./../../Common/Winroles/vars.sls" as commonbase %}

{% if commonbase.dict['iis_sourcefile'] != '' %}

Download iis sourcefile:
  file.managed:
    - name: {{ commonbase.temp_folder }}\microsoft-windows-netfx3-ondemand-package.cab
    - source: {{ commonbase.dict['iis_sourcefile'] }}
    - skip_verify: True

{% endif %}

# Install IIS Web-Server
IIS-WebserverRole:
  win_servermanager.installed:
    - name: Web-Server
    - source: {{ commonbase.temp_folder }}\

# Install IIS Multiple features, reboot if required
Install_IIS-Multiple_features:
  win_servermanager.installed:
    - features:
      - Web-Common-Http
      - Web-Mgmt-Console
      - Web-Default-Doc
      - Web-Dir-Browsing
      - Web-Http-Errors
      - Web-Static-Content
      - Web-Http-Redirect
      - Web-Health
      - Web-Http-Logging
      - Web-Custom-Logging
      - Web-Log-Libraries
      - Web-ODBC-Logging
      - Web-Request-Monitor
      - Web-Http-Tracing
      - Web-Performance
      - Web-Stat-Compression
      - Web-Dyn-Compression
      - Web-Security
      - Web-Filtering
      - Web-Basic-Auth
      - Web-CertProvider
      - Web-Client-Auth
      - Web-Digest-Auth
      - Web-Cert-Auth
      - Web-IP-Security
      - Web-Url-Auth
      - Web-Windows-Auth
      - Web-App-Dev
      - Web-Net-Ext45
      - Web-AppInit
      - Web-ASP
      - Web-Asp-Net45
      - Web-CGI
      - Web-ISAPI-Ext
      - Web-ISAPI-Filter
      - Web-WebSockets
      - NET-Framework-Features
      - NET-Framework-Core
      - NET-HTTP-Activation
      - NET-Non-HTTP-Activ
      - NET-Framework-45-Features
      - NET-Framework-45-Core
      - NET-Framework-45-ASPNET
      - NET-WCF-Services45
      - NET-WCF-HTTP-Activation45
      - NET-WCF-MSMQ-Activation45
      - NET-WCF-Pipe-Activation45
      - Web-Mgmt-Tools
      - Web-Mgmt-Compat
      - Web-Metabase
      - Web-Lgcy-Mgmt-Console
      - ManagementOdata
      - SMTP-Server
      - DSC-Service
      - WindowsPowerShellWebAccess
      - Web-WMI
    - source: {{ commonbase.temp_folder }}\

Refreshdb:
  module.run:
    - name: pkg.refresh_db

Install Packages:
  pkg.installed:
    - pkgs:
      - core3.1.5
      - core2.1
      - custompython3
      - custom7zip
      - connector8.0.13
      - dotnethosting2.0.0
      - dotnethosting3.0.1
      - dotnethosting6.0.1
    - refresh_db: True
    - require:
      - module: Refreshdb

Install wse3.0:
  module.run:
    - name: pkg.install
    - m_name: wse3.0

Install sqlxml4.0:
  module.run:
    - name: pkg.install
    - m_name: sqlxml4.0

Install routing3.0:
  module.run:
    - name: pkg.install
    - m_name: routing3.0

Install oledb18:
  module.run:
    - name: pkg.install
    - m_name: oledb18

Install iisurlrewrite:
  module.run:
    - name: pkg.install
    - m_name: iisurlrewrite

Install vcredist2019:
  module.run:
    - name: pkg.install
    - m_name: vcredist2019

Install dotnet4.8:
  module.run:
    - name: pkg.install
    - m_name: dotnet4.8

Install asp.netmvc4:
  pkg.installed:
    - pkgs:
      - asp.netmvc4
    - require:
      - module: Install dotnet4.8

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

Copy_Font:
  file.managed:
    - name: 'C:\Windows\Fonts\ARIALUNI.TTF'
    - source: {{ commonbase.dict['arialuni.ttf'] }}
    - skip_verify: True

Set Powershell Execution Policy:
  cmd.run:
    - name: 'set-executionpolicy remotesigned'
    - shell: powershell

Install_Font:
  cmd.run:
    - name: 'reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "ARIALUNI (TrueType)" /t REG_SZ /d ARIALUNI.TTF /f' 
    - shell: powershell
    - require:
      - cmd: Set Powershell Execution Policy

Enable Diffie-Hellman:
  cmd.run:
    - name: 'reg add HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\Diffie-Hellman /t REG_DWORD /d 4294967295 /f'
    - shell: powershell
    - require:
      - cmd: Set Powershell Execution Policy

Refresh Regedit:
  module.run:
    - name: reg.broadcast_change
    - require:
      - cmd: Enable Diffie-Hellman
