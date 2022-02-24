dotnethosting2.0.0:
  '2.0.0':
    full_name: 'Microsoft .NET Core 2.0.0 - Windows Server Hosting'
    installer: {{ installer }}
    install_flags: '/install /quiet /norestart /L {{ log_folder }}\core3.1.5.log'
    uninstaller: {{ uninstaller }}
    uninstall_flags: '/uninstall /x86 /x64 /q /norestart'
    msiexec: False
    reboot: False
