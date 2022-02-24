sqlxml4.0:
  '4.0':
    full_name: 'Microsoft SQLXML 4.0 SP1'
    installer: http://LDCSALTREP001/21300/Prerequisites/sqlxml_x64.msi
    install_flags: '/qn /norestart /L c:\saltlogs\sqlxml4.0.log'
    uninstaller: http://LDCSALTREP001/21300/Prerequisites/sqlxml_x64.msi
    uninstall_flags: '/qn /norestart'
    msiexec: True
    reboot: False
