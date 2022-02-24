dotnethosting6.0.1:
  '6.0.1':
    full_name: 'Microsoft .NET Core 6.0.1 - Windows Server Hosting'
    installer: {{ installer }}
    install_flags: '/install /quiet /norestart /L {{ log_folder }}\dotnethosting6.0.1.log'
    uninstaller: {{ uninstaller }}
    uninstall_flags: '/uninstall /x86 /x64 /q /norestart'
    msiexec: False
    reboot: False
