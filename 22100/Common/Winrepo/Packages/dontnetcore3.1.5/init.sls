core3.1.5:
  '3.1.5':
    full_name: 'Microsoft .NET Core Runtime - 3.1.5 (x64)'
    installer: {{ installer }}
    install_flags: '/install /quiet /norestart /L {{ log_folder }}\core3.1.5.log'
    uninstaller: {{ uninstaller }}
    uninstall_flags: '/uninstall /x86 /x64 /q /norestart'
    msiexec: False
    reboot: False
