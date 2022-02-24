{%
set zippath = salt['reg.read_value'](
    'HKEY_LOCAL_MACHINE',
    'Software\\7-Zip',
    'Path64').vdata
%}

check iis list of roles and settings:
  module_and_function: win_servermanager.list_installed
  assertion: assertEqual
  expected_return: {'FileAndStorage-Services': 'File and Storage Services', 'Storage-Services': 'Storage Services', 'Web-Server': 'Web Server (IIS)', 'Web-WebServer': 'Web Server', 'Web-Common-Http': 'Common HTTP Features', 'Web-Default-Doc': 'Default Document', 'Web-Dir-Browsing': 'Directory Browsing', 'Web-Http-Errors': 'HTTP Errors', 'Web-Static-Content': 'Static Content', 'Web-Http-Redirect': 'HTTP Redirection', 'Web-Health': 'Health and Diagnostics', 'Web-Http-Logging': 'HTTP Logging', 'Web-Custom-Logging': 'Custom Logging', 'Web-Log-Libraries': 'Logging Tools', 'Web-ODBC-Logging': 'ODBC Logging', 'Web-Request-Monitor': 'Request Monitor', 'Web-Http-Tracing': 'Tracing', 'Web-Performance': 'Performance', 'Web-Stat-Compression': 'Static Content Compression', 'Web-Dyn-Compression': 'Dynamic Content Compression', 'Web-Security': 'Security', 'Web-Filtering': 'Request Filtering', 'Web-Basic-Auth': 'Basic Authentication', 'Web-CertProvider': 'Centralized SSL Certificate Support', 'Web-Client-Auth': 'Client Certificate Mapping Authentication', 'Web-Digest-Auth': 'Digest Authentication', 'Web-Cert-Auth': 'IIS Client Certificate Mapping Authentication', 'Web-IP-Security': 'IP and Domain Restrictions', 'Web-Url-Auth': 'URL Authorization', 'Web-Windows-Auth': 'Windows Authentication', 'Web-App-Dev': 'Application Development', 'Web-Net-Ext': '.NET Extensibility 3.5', 'Web-Net-Ext45': '.NET Extensibility 4.6', 'Web-AppInit': 'Application Initialization', 'Web-ASP': 'ASP', 'Web-Asp-Net45': 'ASP.NET 4.6', 'Web-CGI': 'CGI', 'Web-ISAPI-Ext': 'ISAPI Extensions', 'Web-ISAPI-Filter': 'ISAPI Filters', 'Web-WebSockets': 'WebSocket Protocol', 'Web-Mgmt-Tools': 'Management Tools', 'Web-Mgmt-Console': 'IIS Management Console', 'Web-Mgmt-Compat': 'IIS 6 Management Compatibility', 'Web-Metabase': 'IIS 6 Metabase Compatibility', 'Web-Lgcy-Mgmt-Console': 'IIS 6 Management Console', 'NET-Framework-Features': '.NET Framework 3.5 Features', 'NET-Framework-Core': '.NET Framework 3.5 (includes .NET 2.0 and 3.0)', 'NET-HTTP-Activation': 'HTTP Activation', 'NET-Non-HTTP-Activ': 'Non-HTTP Activation', 'NET-Framework-45-Features': '.NET Framework 4.6 Features', 'NET-Framework-45-Core': '.NET Framework 4.6', 'NET-Framework-45-ASPNET': 'ASP.NET 4.6', 'NET-WCF-Services45': 'WCF Services', 'NET-WCF-HTTP-Activation45': 'HTTP Activation', 'NET-WCF-MSMQ-Activation45': 'Message Queuing (MSMQ) Activation', 'NET-WCF-Pipe-Activation45': 'Named Pipe Activation', 'NET-WCF-TCP-Activation45': 'TCP Activation', 'NET-WCF-TCP-PortSharing45': 'TCP Port Sharing', 'ManagementOdata': 'Management OData IIS Extension', 'MSMQ': 'Message Queuing', 'MSMQ-Services': 'Message Queuing Services', 'MSMQ-Server': 'Message Queuing Server', 'RSAT': 'Remote Server Administration Tools', 'RSAT-Feature-Tools': 'Feature Administration Tools', 'RSAT-SMTP': 'SMTP Server Tools', 'FS-SMB1': 'SMB 1.0/CIFS File Sharing Support', 'SMTP-Server': 'SMTP Server', 'Windows-Defender-Features': 'Windows Defender Features', 'Windows-Defender': 'Windows Defender', 'Windows-Defender-Gui': 'GUI for Windows Defender', 'PowerShellRoot': 'Windows PowerShell', 'PowerShell': 'Windows PowerShell 5.1', 'PowerShell-V2': 'Windows PowerShell 2.0 Engine', 'DSC-Service': 'Windows PowerShell Desired State Configuration Service', 'PowerShell-ISE': 'Windows PowerShell ISE', 'WindowsPowerShellWebAccess': 'Windows PowerShell Web Access', 'WAS': 'Windows Process Activation Service', 'WAS-Process-Model': 'Process Model', 'WAS-NET-Environment': '.NET Environment 3.5', 'WAS-Config-APIs': 'Configuration APIs', 'WoW64-Support': 'WoW64 Support'}
  output_details: True

check_core3.1.5_installed:
  module_and_function: pkg.version
  args:
    - "core3.1.5"
  assertion: assertEqual
  expected_return: '24.84.28920,3.1.5.28920'

check_core2.1_installed:
  module_and_function: pkg.version
  args:
    - "core2.1"
  assertion: assertEqual
  expected_return: '16.72.26629,2.1.2.26629'

check_custompython3_installed:
  module_and_function: pkg.version
  args:
    - "custompython3"
  assertion: assertEqual
  expected_return: '3.7.2150.0'

check_custom7zip_installed:
  module_and_function: pkg.version
  args:
    - "custom7zip"
  assertion: assertEqual
  expected_return: '19.00.00.0'

check_connector8.0.13_installed:
  module_and_function: pkg.version
  args:
    - "connector8.0.13"
  assertion: assertEqual
  expected_return: '8.0.13'

check_dotnethosting2.0.0_installed:
  module_and_function: pkg.version
  args:
    - "dotnethosting2.0.0"
  assertion: assertEqual
  expected_return: '2.0.30727.142'

check_dotnethosting3.0.1_installed:
  module_and_function: pkg.version
  args:
    - "dotnethosting3.0.1"
  assertion: assertEqual
  expected_return: '3.0.1.19554'

check_wse3.0_installed:
  module_and_function: pkg.version
  args:
    - "wse3.0"
  assertion: assertEqual
  expected_return: '3.0.5305.0'

check_sqlxml4.0_installed:
  module_and_function: pkg.version
  args:
    - "sqlxml4.0"
  assertion: assertEqual
  expected_return: '10.1.2531.0'

check_routing3.0_installed:
  module_and_function: pkg.version
  args:
    - "routing3.0"
  assertion: assertEqual
  expected_return: '3.0.05311'

check_oledb18_installed:
  module_and_function: pkg.version
  args:
    - "oledb18"
  assertion: assertEqual
  expected_return: '18.5.0.0'

check_iisurlrewrite_installed:
  module_and_function: pkg.version
  args:
    - "iisurlrewrite"
  assertion: assertEqual
  expected_return: '7.2.1993'

check_asp.netmvc4_installed:
  module_and_function: pkg.version
  args:
    - "asp.netmvc4"
  assertion: assertEqual
  expected_return: '4.0.40804.0'

check_sqlsysclrtypes_installed:
  module_and_function: pkg.version
  args:
    - "sqlsysclrtypes"
  assertion: assertEqual
  expected_return: '13.2.5026.0'

check_sharedmanagementobjects_installed:
  module_and_function: pkg.version
  args:
    - "sharedmanagementobjects"
  assertion: assertEqual
  expected_return: '13.2.5026.0'

check_powershelltools_installed:
  module_and_function: pkg.version
  args:
    - "powershelltools"
  assertion: assertEqual
  expected_return: '13.2.5026.0'

check_sqlncli_installed:
  module_and_function: pkg.version
  args:
    - "sqlncli"
  assertion: assertEqual
  expected_return: '13.2.5026.0'

check_msodbcsql_installed:
  module_and_function: pkg.version
  args:
    - "msodbcsql"
  assertion: assertEqual
  expected_return: '13.2.5026.0'

check_mssqlcmdlnutils_installed:
  module_and_function: pkg.version
  args:
    - "mssqlcmdlnutils"
  assertion: assertEqual
  expected_return: '13.2.5026.0'

check_dotnet4.8_regkey:
  module_and_function: reg.key_exists
  args:
    - HKLM 
    - SOFTWARE\Microsoft\Net Framework Setup\NDP\v4\Client
  assertion: assertEqual
  expected-return: True
  output_details: True

check_SMTPSVC_running:
  module_and_function: service.status
  args:
   - SMTPSVC
  assertion: assertTrue

check_ARIALUNI.TTF_exists:
  module_and_function: file.file_exists
  args:
    - 'C:\Windows\Fonts\ARIALUNI.TTF'
  assertion: assertTrue

check_ARIALUNI_regkey:
  module_and_function: reg.value_exists
  args:
    - HKLM 
    - SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts\
    - ARIALUNI (TrueType)
  assertion: assertEqual
  expected-return: True
  output_details: True

check_Diffie-Hellman_regkey:
  module_and_function: reg.key_exists
  args:
    - HKLM 
    - SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\Diffie-Hellman
  assertion: assertEqual
  expected-return: True
  output_details: True

check_7zip_path:
  module_and_function: win_path.exists
  args:
    - {{ zippath }}
  assertion: assertEqual
  expected-return: True
  output_details: True