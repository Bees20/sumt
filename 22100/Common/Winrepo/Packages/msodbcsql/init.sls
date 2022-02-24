msodbcsql:
  '13.0.5026.0':
    full_name: 'Microsoft ODBC Driver 13 for SQL Server'
    installer: {{ installer }}
    install_flags: 'ACCEPTEULA=1 /qn /norestart IACCEPTMSODBCSQLLICENSETERMS=YES /L {{ log_folder }}\msodbcsql.log'
    uninstaller: {{ uninstaller }}
    uninstall_flags: '/qn /norestart'
    msiexec: True
    reboot: False
