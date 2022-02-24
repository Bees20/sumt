custompython3:
  '3.7.2':
    full_name: 'Python 3.7.2 (64-bit)'
    installer: {{ installer }}
    install_flags: '/qn /s /norestart /passive PrependPath=1 InstallAllUsers=1 /log {{ log_folder }}\custompython3.log'
    uninstaller: {{ uninstaller }}
    uninstall_flags: '/quiet /uninstall'
    msiexec: False
    locale: en_US
    reboot: False
