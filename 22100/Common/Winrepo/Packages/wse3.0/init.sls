wse3.0:
  '3.0':
    full_name: 'Microsoft WSE 3.0'
    installer: {{ installer }}
    install_flags: ' /qn /norestart /L {{ log_folder }}\wse3.0.log'
    uninstaller: {{ uninstaller }}
    uninstall_flags: '/qn /norestart'
    msiexec: True
    reboot: False

