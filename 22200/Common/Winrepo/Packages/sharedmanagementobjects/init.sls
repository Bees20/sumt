sharedmanagementobjects:
  '13.0.5026.0':
    full_name: 'Microsoft SQL Server 2016 Management Objects  (x64)'
    installer: {{ installer }}
    install_flags: '/qn /norestart /L {{ log_folder }}\sharedmanagementobjects.log'
    uninstaller: {{ uninstaller }}
    uninstall_flags: '/qn /norestart'
    msiexec: True
    reboot: False
