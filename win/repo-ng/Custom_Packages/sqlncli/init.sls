sqlncli:
  '13.0.5026.0':
    full_name: 'Microsoft SQL Server 2012 Native Client '
    installer: http://LDCSALTREP001/21300/Prerequisites/sqlncli.msi
    install_flags: 'ACCEPTEULA=1 /qn /norestart IACCEPTSQLNCLILICENSETERMS=YES /L c:\saltlogs\sqlncli.log'
    uninstaller: http://LDCSALTREP001/21300/Prerequisites/sqlncli.msi
    uninstall_flags: '/qn /norestart'
    msiexec: True
    reboot: False
