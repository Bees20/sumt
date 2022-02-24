powershelltools:
  '13.0.5026.0':
    full_name: 'PowerShell Extensions for SQL Server 2016 '
    installer: http://LDCSALTREP001/21300/Prerequisites/PowerShellTools.msi
    install_flags: '/qn /norestart /L c:\saltlogs\powershelltools.log'
    uninstaller: http://LDCSALTREP001/21300/Prerequisites/PowerShellTools.msi
    uninstall_flags: '/qn /norestart'
    msiexec: True
    reboot: False
