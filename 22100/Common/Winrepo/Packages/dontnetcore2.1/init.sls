core2.1:
  '2.1.2.26629':
    full_name: 'Microsoft .NET Core Runtime - 2.1.2 (x64)'
    installer: {{ installer }}
    install_flags: '/q /norestart /L {{ log_folder }}\core2.1.log'
    uninstaller: {{ uninstaller }}
    uninstall_flags: '/uninstall /x86 /x64 /q /norestart'
    msiexec: False
    locale: en_US
    reboot: False
