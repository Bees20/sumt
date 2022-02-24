mssqlcmdlnutils:
  '13.0.5026.0':
    full_name: 'Microsoft Command Line Utilities 13 for SQL Server'
    installer: {{ installer }}
    install_flags: 'ACCEPTEULA=1 /qn /norestart IACCEPTMSSQLCMDLNUTILSLICENSETERMS=YES /L {{ log_folder }}\mssqlcmdlnutils.log'
    uninstaller: {{ uninstaller }}
    uninstall_flags: '/qn /norestart'
    msiexec: True
    reboot: False
