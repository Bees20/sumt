ssdt14.0:
  '14.0.61021.0':
    full_name: 'Microsoft SQL Server Data Tools - enu (14.0.61021.0)'
    installer: {{ installer }}\SSDT\SSDTSETUP.EXE
    install_flags: 'INSTALLALL=1 /q /norestart /log {{ log_folder }}\ssdt14.0.log'
    uninstaller: {{ uninstaller }}\SSDT\SSDTSETUP.EXE
    uninstall_flags: '/uninstall /x86 /x64 /q /norestart'
    msiexec: False
    reboot: False
