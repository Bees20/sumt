dotnet4.8:
  '4.8.03761':
    full_name: 'Microsoft .NET Framework 4.8'
    installer: {{ installer }}
    install_flags: '/q /norestart /log {{ log_folder }}\dotnet4.8.log'
    uninstaller: {{ uninstaller }}
    uninstall_flags: '/uninstall /x86 /x64 /q /norestart'
    msiexec: False
    reboot: False