vcredist2019:
  '14.28.29325.2':
    full_name: 'Microsoft Visual C++ 2015-2019 Redistributable (x64) - 14.28.29913'
    installer: {{ installer }}
    install_flags: '/q /norestart /L {{ log_folder }}\vcredist2019.log'
    uninstaller: {{ uninstaller }}
    uninstall_flags: '/uninstall /x64 /q'
    msiexec: False
    reboot: False

