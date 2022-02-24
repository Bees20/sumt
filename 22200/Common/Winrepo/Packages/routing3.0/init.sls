routing3.0:
  '3.0':
    full_name: 'Microsoft Application Request Routing 3.0'
    installer: {{ installer }}
    install_flags: 'ACCEPTEULA=1 /qn /norestart /L {{ log_folder }}\routing3.0.log'
    uninstaller: {{ uninstaller }}
    uninstall_flags: '/qn /norestart'
    msiexec: True
    reboot: False
