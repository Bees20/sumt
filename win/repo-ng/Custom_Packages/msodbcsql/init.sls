msodbcsql:
  '13.0.5026.0':
    full_name: 'Microsoft ODBC Driver 13 for SQL Server'
    installer: http://LDCSALTREP001/21300/Prerequisites/msodbcsql.msi
    install_flags: 'ACCEPTEULA=1 /qn /norestart IACCEPTMSODBCSQLLICENSETERMS=YES /L c:\saltlogs\msodbcsql.log'
    uninstaller: http://LDCSALTREP001/21300/Prerequisites/msodbcsql.msi
    uninstall_flags: '/qn /norestart'
    msiexec: True
    reboot: False
