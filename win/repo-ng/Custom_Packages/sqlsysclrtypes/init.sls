sqlsysclrtypes:
  '13.0.5026.0':
    full_name: 'Microsoft System CLR Types for SQL Server 2016'
    installer: http://LDCSALTREP001/21300/Prerequisites/SQLSysClrTypes.msi
    install_flags: '/qn /norestart /L c:\saltlogs\sqlsysclrtypes.log'
    uninstaller: http://LDCSALTREP001/21300/Prerequisites/SQLSysClrTypes.msi
    uninstall_flags: '/qn /norestart'
    msiexec: True
    reboot: False
