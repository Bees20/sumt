sqlncli:
  '13.0.5026.0':
    full_name: 'Microsoft SQL Server 2012 Native Client '
    installer: {{ installer }}
    install_flags: 'ACCEPTEULA=1 /qn /norestart IACCEPTSQLNCLILICENSETERMS=YES /L {{ log_folder }}\sqlncli.log'
    uninstaller: {{ uninstaller }}
    uninstall_flags: '/qn /norestart'
    msiexec: True
    reboot: False
