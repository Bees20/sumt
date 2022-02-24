connector8.0.13:
  '8.0.13':
    full_name: 'MySQL Connector Net 8.0.13'
    installer: {{ installer }}
    install_flags: '/qn /norestart /L {{ log_folder }}\connector8.0.13.log'
    uninstaller: {{ uninstaller }}
    uninstall_flags: '/qn /norestart'
    msiexec: True
    reboot: False
