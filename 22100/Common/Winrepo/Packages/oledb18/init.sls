oledb18:
  '18':
    full_name: 'Microsoft OLE DB Driver for SQL Server'
    installer: {{ installer }}
    install_flags: 'IACCEPTMSOLEDBSQLLICENSETERMS=YES /qn /norestart /L {{ log_folder }}\oledb18.log'
    uninstaller: {{ uninstaller }}
    uninstall_flags: '/qn /norestart'
    msiexec: True
    reboot: False

