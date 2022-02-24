sqlxml4.0:
  '4.0':
    full_name: 'Microsoft SQLXML 4.0 SP1'
    installer: {{ installer }}
    install_flags: '/qn /norestart /L {{ log_folder }}\sqlxml4.0.log'
    uninstaller: {{ uninstaller }}
    uninstall_flags: '/qn /norestart'
    msiexec: True
    reboot: False
