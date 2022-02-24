openjdk:
  '11.0.9.11':
    full_name: 'AdoptOpenJDK JDK with Hotspot 11.0.9.11 (x64)'
    installer: {{ installer }}
    uninstaller: {{ uninstaller }}
    install_flags: ' INSTALLLEVEL=3 /quiet /norestart /L {{ log_folder }}\OpenJDK.log'
    uninstall_flags: '/qn /norestart '
    msiexec: True
    locale: en_US
    reboot: False
