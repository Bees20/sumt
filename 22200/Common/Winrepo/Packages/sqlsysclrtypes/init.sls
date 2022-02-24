sqlsysclrtypes:
  '13.0.5026.0':
    full_name: 'Microsoft System CLR Types for SQL Server 2016'
    installer: {{ installer }}
    install_flags: '/qn /norestart /L {{ log_folder }}\sqlsysclrtypes.log'
    uninstaller: {{ uninstaller }}
    uninstall_flags: '/qn /norestart'
    msiexec: True
    reboot: False
