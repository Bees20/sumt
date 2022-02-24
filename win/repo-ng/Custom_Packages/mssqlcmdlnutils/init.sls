mssqlcmdlnutils:
  '13.0.5026.0':
    full_name: 'Microsoft Command Line Utilities 13 for SQL Server'
    installer: http://LDCSALTREP001/21300/Prerequisites/MsSqlCmdLnUtils.msi
    install_flags: 'ACCEPTEULA=1 /qn /norestart IACCEPTMSSQLCMDLNUTILSLICENSETERMS=YES /L c:\saltlogs\mssqlcmdlnutils.log'
    uninstaller: http://LDCSALTREP001/21300/Prerequisites/MsSqlCmdLnUtils.msi
    uninstall_flags: '/qn /norestart'
    msiexec: True
    reboot: False
