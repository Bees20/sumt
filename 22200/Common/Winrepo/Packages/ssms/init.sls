ssms:
  '18.7.1':
    full_name: 'Microsoft SQL Server Management Studio - 18.7.1'
    installer: {{ installer }}
    install_flags: '/quiet /norestart /log {{ log_folder }}\ssms.log'
    uninstaller: {{ uninstaller }}
    uninstall_flags: '/uninstall /x86 /x64 /q /norestart'
    msiexec: False
    reboot: False