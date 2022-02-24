oledb18:
  '18':
    full_name: 'Microsoft OLE DB Driver for SQL Server'
    installer: http://LDCSALTREP001/21300/Prerequisites/msoledbsql.msi
    install_flags: 'IACCEPTMSOLEDBSQLLICENSETERMS=YES /qn /norestart /L c:\saltlogs\oledb18.log'
    uninstaller: http://LDCSALTREP001/21300/Prerequisites/msoledbsql.msi
    uninstall_flags: '/qn /norestart'
    msiexec: True
    reboot: False

