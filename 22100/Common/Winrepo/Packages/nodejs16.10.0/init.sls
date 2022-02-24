nodejs16.10.0:
  '16.10.0':
    full_name: 'Node.js'
    installer: {{ installer }}
    install_flags: '/qn /norestart /L {{ log_folder }}\nodejs16.10.0.log'
    uninstaller: {{ uninstaller }}
    uninstall_flags: '/qn /norestart'
    msiexec: True
    reboot: False